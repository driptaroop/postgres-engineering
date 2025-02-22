# How PostgreSQL physically stores data: forks and segments
## We need to go deeper

# Introduction
Welcome back to my postgres series. [In the previous article](tablespaces.md), we discussed the physical aspect of data storage in PostgreSQL, focusing on tablespaces. We saw how tablespaces allow you to control the physical location of the data stored in the database.
But how does PostgreSQL store data within tablespaces? You may have already guessed that it is stored in some form of files on disk. But how exactly is this data organized within these files? 
In this article, we will try to answer this question.

# Forks
In PostgreSQL, all information related to a relation(table, index etc.) is stored in several different **forks**, each containing data of a specific type.

Initially, a fork is a single file. The filename of this is made up of a numeric ID (OID) and a suffix that indicates the type of fork. 
This file grows over time. When the file reaches 1GB, another file of the same fork is created. These files are called **segments** of the fork. 
A sequence number of the segment is appended to the filename to distinguish between different segments of the same fork.
This 1GB size was historically established to support various file systems that could not handle large files. You can only change this limit when you are building Postgres.

So, a single relation is represented on disk by several files. Even a small table without indexes will have at least three files, by the number of mandatory forks.

# See the forks in action
Before proceeding, lets start a postgres docker container with a volume mounted to the host. This will allow us to inspect the data directory from the host OS.

```yaml
services:
  data-org:
    image: 'postgres:17'
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: postgres
    ports:
      - "5432:5432"
    container_name: 'data-org'
    volumes:
      - ./data:/var/lib/postgresql/data:rw
```

Let's start the container and we see that a data directory is created in the host OS. This directory contains the data files for the postgres cluster.
Let's now create a table and insert some data and then perform a `vacuum`.

```sql
CREATE UNLOGGED TABLE t(a integer, b numeric, c text, d jsonb);
INSERT INTO t VALUES (1, 2.0, 'foo', '{}');
vacuum t;
```

So far so good. Now let's see the files created for this table. For this, we need to call the `pg_relation_filepath` function with the relation name.

```sql
SELECT pg_relation_filepath('t');
```

This will return the file path of the relation `t`. The output will be something like this:

| pg\_relation\_filepath |
| :--- |
| base/5/16388 |

> Note: This path might not be the same in your case. But the format will be the same. We will see how to interpret this path in a moment.

So the relation `t` is stored in the file `16388` in the `base/5` directory. We can confirm this by going to the mounted volume and checking the file.
You will see that file `16388` is created in the `base/5` directory. In fact, you will see multiple files with the same prefix but different suffixes like `_init` , `_fsm` and `_vm`. These are the different forks of the relation `t`.
But before we dive into the details of these forks, let's first understand where this `base/5/16388` path comes from.

## Understanding the file path
The `base/5/16388` path is made up of three parts:
1. `base`: The first part of the path is the `tablespace` directory. This is the directory where the tablespace is located. In this case, it is the default tablespace `pg_default` since we are not specifying otherwise.
If you remember from [the previous article](tablespaces.md), the `pg_default` tablespace is created in the `PGDATA/base` directory.
2. `5`: The second part of the path is the `database` directory. This is the directory where the database is located in the tablespace. In this case, it is the `postgres` database since we are not specifying otherwise.
The database directory is created in the tablespace directory with the name of the database OID. The OID of the `postgres` database is `5`. We can confirm this by querying the `pg_database` system catalog.
    ```sql
    SELECT datname, oid FROM pg_database WHERE datname = 'postgres';
    ```
   | datname  | oid |
   |:---------|:----|
   | postgres | 5   |

3. `16388`: The third part of the path is the `relation` file. This is the file where the relation (in this case a table) is stored in the database directory. The relation file is created in the database directory with the name of the relation `relfilenode`. The `relfilenode` of the `t` relation is `16388`. We can confirm this by querying the `pg_class` system catalog.
    ```sql
    SELECT relname, relfilenode FROM pg_class WHERE relname = 't';
    ```
   | relname | relfilenode |
   |:--------|:------------|
   | t       | 16388       |

So the file path `base/5/16388` is made up of the tablespace directory, the database directory, and the relation filepath. 

## Forks for a relation
As mentioned earlier, a relation is stored in several files, each containing data of a specific type. These files are called **forks**.
If we check the filepath `base/5/16388`, we will find 4 files are created for the relation `t`: `16388`, `16388_init`, `16388_fsm` and `16388_vm`.
These files are the different forks of the relation `t`. Let's see what each of these forks contains:

* **Main Fork**: The main fork contains the actual data of the relation. This is the file `16388`. It contains the actual data rows of the table.
This fork is available for all relations except views since they contain no data. It is created when the relation is created and is always present.
We can read the stat of this file using the `pg_stat_file` function.
    ```sql
    SELECT * FROM pg_stat_file('base/5/16388');
    ```
    This will return the statistics of the file `16388`. The output will be something like this:

  | size | access                            | modification                      | change                            | creation | isdir |
  |:-----|:----------------------------------|:----------------------------------|:----------------------------------|:---------|:------|
  | 8192 | 2025-02-22 08:07:19.000000 +00:00 | 2025-02-22 08:06:44.000000 +00:00 | 2025-02-22 08:06:44.000000 +00:00 | null     | false |

* **Initialization Fork**: The initialization fork contains the initialization data of the relation and is created with `_init` suffix. This is the file `16388_init`.
This fork is only available for the unlogged relations (this was the reason we create table `t` as unlogged). This fork has no size and only acts as differentiator for postgres to denote if a relation is logged or unlogged.
We can read the stat of this file using the `pg_stat_file` function.
    ```sql
    SELECT * FROM pg_stat_file('base/5/16388_init');
    ```
    This will return the statistics of the file `16388_init`. The output will be something like this:
  
  | size | access                            | modification                      | change                            | creation | isdir |
  |:-----|:----------------------------------|:----------------------------------|:----------------------------------|:---------|:------|
  | 0    | 2025-02-22 08:06:44.000000 +00:00 | 2025-02-22 08:06:44.000000 +00:00 | 2025-02-22 08:06:44.000000 +00:00 | null     | false |

  Unlogged relations are not written to the WAL(write ahead log). This makes the write operations considerably faster. But the downside is that the data is not recoverable in case of a crash.
  Therefore, PostgreSQL simply deletes all forks of such objects during recovery and overwrites the main fork with the initialization fork, thus creating a dummy file.

* **Free Space Map Fork**: The main fork of the relation is actually chunked into smaller blocks of equal size. These blocks are called **pages**. 
They are a very important concept in PostgreSQL and deserves an article of its own. 
The free space map fork is a fork that keeps track of the availability of free space inside pages. and is created with `_fsm` suffix. This is the file `16388_fsm`.
    
    This space is constantly changing: it decreases when new versions of rows are added and increases during vacuuming. The 
  free space map is used to quickly find a page that can accommodate new data being inserted. Initially, no such files are created; they appear only when necessary. The easiest way to get them is to vacuum a table.
  This is the reason we vacuumed the table `t` after inserting some data. We can check the stat of this file using the `pg_stat_file` function again.
    ```sql
    SELECT * FROM pg_stat_file('base/5/16388_fsm');
    ```
    This will return the statistics of the file `16388_fsm`. The output will be something like this:
  
  | size  | access                            | modification                      | change                            | creation | isdir |
  |:------|:----------------------------------|:----------------------------------|:----------------------------------|:---------|:------|
  | 24576 | 2025-02-22 08:09:59.000000 +00:00 | 2025-02-22 08:09:59.000000 +00:00 | 2025-02-22 08:09:59.000000 +00:00 | null     | false |

  To speed up search, the free space map is organized as a tree; it takes at least three pages (hence its file size for an almost empty table).
  The Free Space Map is organized as a tree of FSM pages. The bottom level FSM pages store the free space available on each heap (or index) page, 
  using one byte to represent each such page. The upper levels aggregate information from the lower levels. Within each FSM page is a binary tree, 
  stored in an array with one byte per node. Each leaf node represents a heap page, or a lower level FSM page. In each non-leaf node, the higher of 
  its children's values is stored. The maximum value in the leaf nodes is therefore stored at the root.

* **Visibility Map Fork**: The visibility map fork is a fork that shows whether a page needs to be vacuumed or frozen. It is created with `_vm` suffix. This is the file `16388_vm`.
  It provides 2 bits per table page. The first bit is set for pages that contain only up-to-date row versions, and the second bit indicates if the page is all-frozen. 
  Thus, a visibility map enhances vacuum processing and SELECT operations. It identifies pages with dead rows, enabling efficient vacuuming and faster disk space reclamation. 
  For SELECT queries, it helps the database scan only relevant pages instead of the entire table, improving query performance and reducing retrieval time.

  The second bit is set for pages that contain only frozen row versions.
  
    We can check the stat of this file using the `pg_stat_file` function again.
  ```sql
    SELECT * FROM pg_stat_file('base/5/16388_vm');
    ```

  | size | access                            | modification                      | change                            | creation | isdir |
  |:-----|:----------------------------------|:----------------------------------|:----------------------------------|:---------|:------|
  | 8192 | 2025-02-22 08:09:59.000000 +00:00 | 2025-02-22 08:09:59.000000 +00:00 | 2025-02-22 08:09:59.000000 +00:00 | null     | false |

## Data format
The data in the main fork is stored in a binary format. The format is not human-readable and is optimized for fast access and storage.
The data format on disk is exactly the same as the data representation in RAM. The page is read into the buffer cache "as is", without whatever conversions. Therefore, data files from one platform turn out incompatible with other platforms.

# Conclusion
In this article, we discussed the deeper physical aspect of data storage in PostgreSQL, focusing on forks and segments. We saw how a relation is stored in several files, each containing data of a specific type. These files are called forks. 
We also saw how the data is organized within these files and how the data format is optimized for fast access and storage.

# References
- [PostgreSQL Documentation](https://www.postgresql.org/docs/current/index.html)
- [PostgreSQL Internals Book](https://postgrespro.com/community/books/internals)
- https://postgrespro.com/blog/pgsql/5967858
