# Logical Replication

Logical replication is a method of replicating data objects and their changes, based on their replication identity. It is implemented as a PostgreSQL extension and is available as of PostgreSQL 10.

Logical replication is based on the concept of publishing and subscribing to data changes. The publisher publishes changes to a publication, and the subscriber subscribes to the publication to receive the changes. The changes are transported using the logical replication protocol, which is a message-based protocol.

Logical replication is a powerful feature that allows you to replicate only the data you need. It has benefits over physical replication, 
such as the ability to replicate only a subset of the data, the ability to replicate data between different PostgreSQL versions, and the 
ability to replicate data between different PostgreSQL instances.

its disadvantages include the fact that it cannot replicate DDL changes, such as table creation, deletion, or schema changes, and that it
requires more resources than physical replication.

## setup

In this demo, we are going to set up logical replication between two PostgreSQL instances. We will use two instances of PostgreSQL 17.
Check [docker compose file](compose.yml) for more details.

### Step 1: Create a table in the publisher

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
```

### Step 2: Create a publication in the publisher

```sql
CREATE PUBLICATION users_pub FOR TABLE users;

```

### Step 3: Create the same table in the subscriber

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
```

### Step 3: Create a subscription in the subscriber

```sql
CREATE SUBSCRIPTION users_sub 
    CONNECTION 'host=postgres_publisher dbname=postgres user=postgres password=password' 
    PUBLICATION users_pub
    WITH (copy_data = true);
```

### Step 4: Insert some data in the publisher

```sql
INSERT INTO users (name) VALUES ('Alice');
INSERT INTO users (name) VALUES ('Bob');
```

### Step 5: Check the data in the subscriber

```sql
SELECT * FROM users;
```

