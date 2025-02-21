# How PostgreSQL physically stores data: tablespaces
## Gimme some space!

# Introduction
So far, we have discussed the high-level and logical aspects of data organization in PostgreSQL. We have seen how PostgreSQL organizes data at different levels of logical abstraction, such as databases, schemas, and system catalogs. 
But how does PostgreSQL physically store this data on disk? In this article, we will discuss the physical aspect of data storage in PostgreSQL. 

I initially planned to discuss tablespaces, forks, segments and pages in a single article. But as I started writing, I realized that it would be too much information to digest in a single article. So I decided to split it into multiple articles.

# Tablespaces
_In PostgreSQL, a tablespace is a location on disk where PostgreSQL stores data files containing database objects_. A tablespace allows you to control the physical location of the data stored in the database.
Unlike databases and schemas, which determine logical distribution of database objects, tablespaces define physical data layout.
Tablespaces are in essence a directory on the file system where PostgreSQL stores data files.

One tablespace can be used by different databases, and each database can store data in several tablespaces. It means that logical 
structure and physical data layout are independent of each other. In fact, one of the ways of optimizing PostgreSQL performance is to store different types of data on different disks.
For example, you can distribute data between tablespaces in such a way that archived data or rarely used data is stored on slower disks, while frequently accessed data
like OLTP tables or indexes is stored on faster disks.

During Postgres cluster initialization, 2 tablespaces are created by default:
1. `pg_default`: This is the default tablespace for the cluster. If you don't specify a tablespace when creating an object, PostgreSQL will place it in the `pg_default` tablespace.
This tablespace is created in the `PGDATA/base` directory.
2. `pg_global`: This tablespace is used for shared system catalogs. It is created in the `PGDATA/global` directory.

# Managing custom tablespaces
Creating a tablespace is quite simple. You can create a tablespace using the `CREATE TABLESPACE` command:
```sql
CREATE TABLESPACE my_tablespace LOCATION '/var/lib/postgresql/data/tspace';
```

Once the tablespace is created, it can be used for storing database objects. The tablespace can be specified while creating a database or while creating a database object.

```sql
CREATE DATABASE my_db TABLESPACE my_tablespace; -- create a database using the tablespace
CREATE TABLE my_table (id int) TABLESPACE my_tablespace; -- create a table using the tablespace
```

You can also change the default tablespace for a database or an object using the `ALTER DATABASE` or `ALTER ...` command:
```sql
ALTER DATABASE my_db SET TABLESPACE pg_default; -- set the default tablespace for the database
ALTER TABLE my_table SET TABLESPACE pg_default; -- set the tablespace for the table
```

To view the location of tablespaces, you can use the system catalog `pg_tablespace` with the `pg_tablespace_location` function:
```sql
select pt.spcname, pg_tablespace_location(pt.oid) from pg_tablespace pt;
```
response:

| spcname | pg\_tablespace\_location |
| :--- | :--- |
| pg\_default |  |
| pg\_global |  |
| my\_tablespace | /var/lib/postgresql/data/tspace |

> Note that the `pg_tablespace_location` function returns the location of the tablespaces in the file system except for the default tablespaces `pg_default` and `pg_global`.
> These 2 tablespaces are created in the `PGDATA/base` and `PGDATA/global` directories respectively and their location is hardcoded in the PostgreSQL source code.

To remove a tablespace, you can use the `DROP TABLESPACE` command:
```sql
DROP TABLESPACE my_tablespace;
```

# The bottom line
So we learned about the tablespaces. But it all boils down the one question: Should you even bother with tablespaces?
The short answer is: as an application developer, you most probably won't need to bother with tablespaces. 
As a DBA, you also probably shouldn't, but it depends.

1. Tablespaces can be used to distribute IO load or add more storage to a database. But there are better ways of achieving the same results on OS level without bothering the tablespace configuration.
2. Tablespaces can be used to put on a artificial size limit on a database if needed for what-so-ever reason. But it's not a common use case.
3. If you have multiple disks of varying performance and cost, tablespaces can be used to distribute data between them to optimize for cost and performance.
4. Tablespaces can be used for temporary DB objects to be created in a separate disk.
5. An interesting point to note is that all this can be achieved without tablespaces by using the file system itself in a virtualized environment.

References:
- https://postgrespro.com/community/books/internals
- https://www.cybertec-postgresql.com/en/when-to-use-tablespaces-in-postgresql/
- https://www.timescale.com/learn/understanding-postgresql-tablespaces