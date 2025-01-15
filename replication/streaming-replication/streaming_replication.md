# Streaming Replication

## Introduction
For streaming replication, servers will be either a primary or a standby server. Primaries can send data, while 
standbys are always receivers of replicated data. When cascading replication is used, standby servers can also be 
senders, as well as receivers. Parameters are mainly for sending and standby servers, though some parameters have 
meaning only on the primary server. Settings may vary across the cluster without problems if that is required.

## Setup
In this demonstration, we will have a primary server and two standby replica. The primary server will send data to
the two standby replicas. The primary server will have read-write access, while the standby replicas will have read-only.
An asynchronous replication job will be used to send data from the primary server to the standby replicas using 
WAL shipping.

## Configuration

### Docker Compose 
The [docker compose file](compose.yml) will have three services, postgres-primary, postgres-replica-1, and postgres-replica-2.

### Primary Server
The primary server will have the following configurations:
```yaml
# wal_level determines how much information is written to the WAL. 
# The default value is replica, which writes enough data to support WAL archiving and replication, 
# including running read-only queries on a standby server.
# Other possible values are minimal and logical.
wal_level: replica 

# max_wal_senders sets the maximum number of concurrent connections from standby servers or streaming base backup clients.
max_wal_senders: 10

# As WAL already contains all sufficient information it can also be used to organize data transfer from primary instance to the replica. 
# Using data stored in primary instance’s WAL, replica is able to sustain the same state of own data by replaying all changes that are present in the log. 

# However, a challenge arises due to the primary instance needing to periodically clear older WAL segments to manage limited disk space. 
# That can potentially cause deletion of the WAL segment that is not replayed by some replica yet (taking into account a replication delay). 
# To deal with this issue replication slots exist.

# max_replication_slots sets the maximum number of replication slots that the server will support.
max_replication_slots: 10

# hot_standby enables read-only queries on a standby server.
hot_standby: on

# hot_standby_feedback enables the standby server to send information back to the primary server about which WAL segments are still required.
hot_standby_feedback: on
```

### Standby Replica
The standby replica will run the `pg_basebackup` command to create a base backup of the primary server. 
This will stream the WAL logs from the primary server to the standby replica. The standby replica will have the following configurations:
```bash
pg_basebackup --pgdata=<data-dir> -R --slot=<replication slot of primary server> --host=<primary host> --port=<primary port>
```
pg_basebackup normally asks for an username and password, but we can set the `PGUSER` and `PGPASSWORD` environment variables to avoid the prompt.


## Running the Demo
```bash
docker compose up postgres-primary postgres-replica-1 postgres-replica-2
```
