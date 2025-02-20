# Postgres Internals: Schemas and System Catalogs
## In the grand schema of things

# Introduction
In the [previous article](databases_and_templates.md), we discussed the high-level aspects of data organization in PostgreSQL, 
focusing on the `database` abstraction. In this article, we'll dive deeper into the `schema` and `system catalogs` in PostgreSQL.
The next level of abstraction in PostgreSQL's data organization setup is the `schema`.

# Schemas
In short, a `schema` is a namespace that contains all objects in the database. It is a named logical collection of database objects, 
such as tables, views, indexes, data types, functions, stored procedures, and operators.

Hierarchically, each `instance` or `cluster` of PostgreSQL can have multiple `databases`, each `database` can have multiple `schemas`
and each `schema` can have multiple `tables`, `views`, etc. So, in the grand hierarchy of PostgreSQL, `schema` sits somewhere between `database` and `tables`.

## Creating and deleting a Schema
Creating and deleting a schema is quite simple. You can create a schema using the `CREATE SCHEMA` command and delete it using the `DROP SCHEMA` command.
To rename a schema or change its owner, you use the `ALTER SCHEMA` statement.

```sql
CREATE SCHEMA schema_name;
DROP SCHEMA schema_name;
```

## Predefined Schemas
When a new database is created, PostgreSQL automatically creates some schemas. The most important of these are:

* `public`: This is the default schema for a new database. PostgreSQL automatically creates this schema for every new database. If you don't specify a schema name when creating an object, PostgreSQL will place it in the `public` schema.
* `pg_catalog`: This schema contains the system catalog tables, views, and functions that are used by the database system internally.
* `information_schema`: This schema contains views that provide information about objects in the database. Typically, these views provide an alternative to the system catalog tables and are in place to comply with the SQL standard.
* `pg_toast`: This schema contains objects related to Toasts (More on this in a later post).
* `pg_temp`: When a session creates a temporary table, it is created in the schema called `pg_temp_N` where `N` is the ID of the session. This schema is automatically dropped at the end of the session. The eponymous `pg_temp` schema is actually an alias to the current session's temporary schema.
That's why, although different sessions create temporary tables in different temp schemas, everyone refers to their objects using the `pg_temp` alias.

To access any object in the schema, you need to qualify the object name with the schema name. For example, to access a view named `views` in the schema `information_schema`, you would write:

```sql
SELECT * FROM information_schema.views;
```

## Schema search path
Even though accessing objects with schema names is one way to do it, PostgreSQL provides a way to avoid specifying the schema name every time you access an object. This is done using the `search_path` parameter.
The value of the `search_path` parameter is called the `schema search path`. When you access an object without specifying the schema name, PostgreSQL searches for the object in the schemas listed in the `search_path` parameter, in order.
The `search_path` value is a comma-separated list of schema names. To print the current `search_path`, you can run:

```sql
SHOW search_path;
``` 
which will return something like:

| search\_path |
| :--- |
| "$user", public |

This means that PostgreSQL will first search for objects in the schema with the same name as the current user, and then in the `public` schema.
So if you are logged in as the user `postgres` and you use an object, postgres will search in the `postgres` schema first and then in the `public` schema.

> **⚠️ IMPORTANT:** Even though its not shown, the search path is implicitly extended with pg_catalog and (if necessary) pg_temp schemas.
> That's why you can access system catalog tables and the temp tables without specifying the schema name.

Also note that, when creating an object without specifying the schema name, PostgreSQL will place it in the first schema in the search path that exists. 
Let's see this in action:

```sql
-- create a new schema
CREATE SCHEMA test_schema;

-- set the search path to the new schema
SET search_path TO test_schema, public, information_schema;

-- create a table without specifying the schema
CREATE TABLE test_table (id integer);

-- check the schema of the table (check how we are using information_schema.tables without specifying the schema because of the search path)
SELECT table_schema FROM tables WHERE table_name = 'test_table';
```

The response looks as expected:

| table\_schema |
| :--- |
| test\_schema |

## Schema Ownership and Privileges
Schemas can be owned by a role, and the owner of a schema has all privileges on the schema. But they cannot access any objects in the schemas that do not belong to them.
To allow users to access objects in a schema, you need to grant them the necessary privileges.

```sql
GRANT USAGE ON SCHEMA schema_name TO role_name;
```

> by default, every user has the CREATE and USAGE on the public schema.

# System Catalogs
System catalogs form the metadata backbone of a Postgres instance. These catalogs form a centralized repository that stores metadata about 
the database itself, such as tables, indexes, columns, constraints, functions, users, privileges, extensions, query statistics, and more. 
All the system catalog tables and views are organized under the `pg_catalog` schema. Alternatively, the `information_schema` schema provides
a more SQL standard-compliant view of the system catalogs.

To list the tables in the system catalog, you can execute the following command:
```sql
SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname = 'pg_catalog' order by 1;
```

To list all the views in the system catalog, you can execute the following command:

```sql
SELECT viewname FROM pg_catalog.pg_views WHERE schemaname = 'pg_catalog' order by 1;
```

Attributes that are common for the system catalog objects,
1. there are a lot of tables and views in the system catalog. These tables and views are used and amnaged by the database system internally to manage the database.
2. The system catalogs should be treated as read-only. Modifying the system catalogs can lead to database corruption and data loss and should not be done unless you have a very compelling reason and expertise. 
3. A good portion of the tables we can query in the catalog are 'system-wide' tables, where it doesn’t matter what database we are connected to, the data represents the whole cluster, no singular database.
4. Names of all system catalog tables begin with `pg_`, like in `pg_database`. Column names start with a three-letter prefix that usually corresponds to the table name, like in `datname`.
5. In all system catalog tables, the column declared as the primary key is called oid (object identifier). its type, which is also called oid, is a 32-bit integer.

Some of the most important system catalog tables and views are:
* `pg_database` and `pg_stat_database`: Contains information about databases and their statistics in the cluster.
* `pg_namespace`: Contains metadata information about schemas, including schema names, owner information, and associated privileges.
* `pg_class`: Contains metadata information about ttables, views, indexes, sequences, and other relation types in the database.
* `pg_attribute`: Stores information about the columns (attributes) of all relations in the database.
* `pg_index`: stores detailed metadata about indexes, including details such as the indexed columns, index types, and index properties like uniqueness and inclusion of nullable values.
* `pg_constraint`: Contains information about constraints defined on tables, such as primary keys, foreign keys, unique constraints, and check constraints.
* `pg_user`: A view that contains information about database users, including user names, roles, and user privileges.
* `pg_views`: A view that contains information about views in the database, including view names, view definitions, and owner information.
* `pg_tables`: A view that contains information about tables in the database, including table names, table owner information, and table privileges.
* `pg_locks`: Contains information about locks held by current transactions in the database, including lock types (for example, shared, exclusive), lock modes, and the associated database objects being locked.
* `pg_settings`: Provides a centralized location for retrieving information about current configuration settings, including database-related parameters and their respective values. It is essentially an alternative interface to the SHOW and SET commands.
* `pg_proc`: Contains information about functions and stored procedures in the database, including function names, function definitions, and function owner information.

More details about these tables and views can be found in the [PostgreSQL documentation](https://www.postgresql.org/docs/current/catalogs.html).

# Conclusion
In this article, we discussed the `schema` and `system catalogs` in PostgreSQL. We learned that a `schema` is a namespace that contains all objects in the database,
and that system catalogs form the metadata backbone of a Postgres instance. We also discussed the predefined schemas in PostgreSQL and the system catalog tables and views.

# References
- [Postgres Internals Book](https://postgrespro.com/community/books/internals)
- https://neon.tech/postgresql/postgresql-administration/postgresql-schema
- https://hasura.io/learn/database/postgresql/core-concepts/1-postgresql-schema/
- https://docs.yugabyte.com/preview/architecture/system-catalog/#settings
- https://severalnines.com/blog/understanding-and-reading-postgresql-system-catalog/