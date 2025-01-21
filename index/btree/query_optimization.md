# Select query optimization using B-Tree index In PostgreSQL
## The B in B-Tree stands for best ;-)

## Introduction
In the last section, we learned about B-tree index internals. Now, its time to put the theory into practice. We will see how B-tree index can be used to optimize select queries.
We'll jump straight to the demo and will optimize a query using B-tree index step by step.

## Demo

### Database schema and data setup
For the sake of brevity we will just use [this compose file](compose.yaml) to setup a Postgres container and create a table with some data.

The table schema is as follows:
```sql
CREATE TABLE IF NOT EXISTS process
(
    process_id     UUID                     NOT NULL,
    process_type   TEXT                     NOT NULL,
    process_status TEXT                     NOT NULL,
    mfa_id         TEXT                     NOT NULL,
    mfa_status     TEXT                     NOT NULL,
    mfa_type       TEXT                     NOT NULL,
    mfa_expiry     timestamp with time zone NOT NULL,
    user_id        TEXT                     NOT NULL,
    process_time   timestamp with time zone NOT NULL,
    CONSTRAINT process_pk PRIMARY KEY (process_id)
);
```
We populate this `process` table with 5 million rows with the startup script. Its not a lot of data, but its sufficient for our demo.

Lets try to optimize this query:
```sql
select process_id, process_type, mfa_id, mfa_expiry
from process
where process_status = 'initialized'
  and mfa_status in ('authorized', 'created')
order by process_time asc
limit 100;
```

### Performance without optimization
Lets run the query without any index and see how much time it takes. To benchmark the query we will use the `pgbench` tool.
`pgbench` is a simple program for running benchmark tests on PostgreSQL. It runs the same SQL command over and over and measures the time it takes to complete.
We'll run the benchmark for 100 transactions and check the average time per query and throughput (tps). We'll put our query in a file and run the benchmark as follows:
```bash
echo "select process_id, process_type, mfa_id, mfa_expiry from process where process_status = 'initialized' and mfa_status in ('authorized', 'created') order by process_time asc limit 100;" > query.sql
pgbench -f query.sql -t 100 -h localhost -d postgres -U postgres
```
For ease, I have also put this script in a file [pgbenchmark.sh](pgbenchmark.sh). You can run this script to benchmark the query. Let's execute this and check the result of our benchmark.
```
latency average = 680.113 ms
tps = 1.470344 (without initial connection time)
```
Also, for our curiosity, lets how much is the index size for this table.
```sql
select idx.indexrelname as index_name, pg_size_pretty(pg_relation_size(idx.indexrelid)) as index_size
from pg_stat_all_indexes idx
where idx.relname = 'process';
```
| index\_name | index\_size |
| :--- | :--- |
| process\_pk | 192 MB |

As we can see, so far there is only the `primary key` index on the `process` table with the size of 192 MB. So now that we have the base, lets improve the performance.

### Understanding the query plan

Before anything else, lets check the query plan using `Explain Analyze` to see how the query is being executed.
```sql
explain analyze
select process_id, process_type, mfa_id, mfa_expiry
from process
where process_status = 'initialized'
  and mfa_status in ('authorized', 'created')
order by process_time asc
limit 100;
```

This is the query plan:
```sql
Limit  (cost=140903.43..140915.10 rows=100 width=74) (actual time=1112.317..1116.441 rows=100 loops=1)
  ->  Gather Merge  (cost=140903.43..167793.94 rows=230474 width=74) (actual time=1105.087..1109.205 rows=100 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Sort  (cost=139903.41..140191.50 rows=115237 width=74) (actual time=1041.090..1041.094 rows=78 loops=3)
              Sort Key: process_time
              Sort Method: top-N heapsort  Memory: 47kB
              Worker 0:  Sort Method: top-N heapsort  Memory: 48kB
              Worker 1:  Sort Method: top-N heapsort  Memory: 47kB
              ->  Parallel Seq Scan on process  (cost=0.00..135499.13 rows=115237 width=74) (actual time=2.499..995.429 rows=91798 loops=3)
"                    Filter: ((mfa_status = ANY ('{authorized,created}'::text[])) AND (process_status = 'initialized'::text))"
                    Rows Removed by Filter: 1574869
Planning Time: 0.930 ms
JIT:
  Functions: 13
"  Options: Inlining false, Optimization false, Expressions true, Deforming true"
"  Timing: Generation 1.565 ms (Deform 0.870 ms), Inlining 0.000 ms, Optimization 1.035 ms, Emission 13.413 ms, Total 16.014 ms"
Execution Time: 1180.366 ms
```
I have written a separate article on [how to read the explain analyze](../../explain/readme.md). You can refer to that to understand the query plan structure.
However, some parts of it needs additional explanation:
* **Parallel Seq Scan**: At first the query is doing a sequential scan parallely (by 2 workers) on the `process` table. It is scanning all the rows and filtering out the rows which satisfy the `where` clause.
* **Sort**: After filtering the rows, the rows are sorted based on the `process_time` column.
* **Gather Merge**: 2 workers which are filtering and sorting the rows are merged to get the sorted resultset.
* **Limit**: Finally, the top 100 rows are selected from the sorted resultset.

From, the `cost` attribute in the query plan, we can see that the most costly part of the query is the `Parallel Seq Scan`. This is because it is scanning all the rows in the table and then filtering out the rows which satisfy the `where` clause. This is where the B-tree index can help us.

### Create individual B-Tree indexes
We will create a B-tree index on the `process_status`, `mfa_status` and `process_time` columns. This will help because the query can skip the sequential scan and directly jump to the rows which satisfy the `where` clause. Also, the rows should be already sorted based on the `process_time` column without the need to sort the entire resultset.

```sql
create index process_status_idx on process using btree (process_status);
create index mfa_status_idx on process using btree (mfa_status);
create index process_time_idx on process using btree (process_time);
```

Now lets benchmark the query again and see the result.
```
latency average = 1.646 ms
tps = 607.419016 (without initial connection time)
```
and size of the index:

| index\_name | index\_size |
| :--- | :--- |
| process\_pk | 192 MB |
| process\_status\_idx | 33 MB |
| mfa\_status\_idx | 33 MB |
| process\_time\_idx | 107 MB |

Welp thats a huge improvement. We can already call it a day and go home. But lets try to see the query plan to see whats happening.

```sql
Limit  (cost=0.43..207.18 rows=100 width=74) (actual time=0.161..17.655 rows=100 loops=1)
  ->  Index Scan using process_time_idx on process  (cost=0.43..571805.58 rows=276577 width=74) (actual time=0.161..17.643 rows=100 loops=1)
"        Filter: ((mfa_status = ANY ('{authorized,created}'::text[])) AND (process_status = 'initialized'::text))"
        Rows Removed by Filter: 1656
Planning Time: 1.141 ms
Execution Time: 17.733 ms
```

Hmm... it looks like it is only using the index `process_time_idx` and filtering out the rows based on the `mfa_status` and `process_status` columns. Its not using the other indexes. This is because the 3 indexes do not intersect with each other. The query planner is not able to use the indexes to filter out the rows based on the `mfa_status` and `process_status` columns. It can only use the `process_time_idx` index to filter out the rows based on the `process_time` column.
we can confirm this by dropping the other indexes and checking the query plan again.

Drop the indexes:
```sql 
drop index process_status_idx;
drop index mfa_status_idx;
```

Query plan: 
```sql
Limit  (cost=0.43..207.18 rows=100 width=74) (actual time=0.168..15.735 rows=100 loops=1)
  ->  Index Scan using process_time_idx on process  (cost=0.43..571805.58 rows=276577 width=74) (actual time=0.167..15.723 rows=100 loops=1)
"        Filter: ((mfa_status = ANY ('{authorized,created}'::text[])) AND (process_status = 'initialized'::text))"
        Rows Removed by Filter: 1656
Planning Time: 0.263 ms
Execution Time: 15.787 ms
```

As expected, the query plan is the same. This is slightly better because we are not wasting space on the indexes which are not being used. But we can do better.

### Create a composite B-Tree index

Lets create a composite index on `process_status`, `mfa_status` and `process_time` columns. This will help the query planner to find the intersection between all our sort and filter queries and directly jump to the rows which satisfy the `where` clause and are already sorted based on the `process_time` column.

```sql
-- drop the previous index first
drop index process_time_idx;
-- create composite index
create index process_status_mfa_status_process_time_idx on process using btree (process_status, mfa_status, process_time);
```

Lets check the benchmark first this time.
```
latency average = 766.391 ms
tps = 1.304816 (without initial connection time)
```

| index\_name | index\_size |
| :--- | :--- |
| process\_pk | 192 MB |
| process\_status\_mfa\_status\_process\_time\_idx | 230 MB |

What happened? The performance is worse than before. Lets check the query plan to see whats happening.

```sql
Limit  (cost=140801.23..140812.89 rows=100 width=74) (actual time=1271.436..1276.348 rows=100 loops=1)
  ->  Gather Merge  (cost=140801.23..167692.44 rows=230480 width=74) (actual time=1260.376..1265.285 rows=100 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Sort  (cost=139801.20..140089.30 rows=115240 width=74) (actual time=1163.512..1163.518 rows=80 loops=3)
              Sort Key: process_time
              Sort Method: top-N heapsort  Memory: 47kB
              Worker 0:  Sort Method: top-N heapsort  Memory: 48kB
              Worker 1:  Sort Method: top-N heapsort  Memory: 47kB
              ->  Parallel Bitmap Heap Scan on process  (cost=9176.02..135396.81 rows=115240 width=74) (actual time=66.960..1128.927 rows=91798 loops=3)
"                    Recheck Cond: ((process_status = 'initialized'::text) AND (mfa_status = ANY ('{authorized,created}'::text[])))"
                    Rows Removed by Index Recheck: 496848
                    Heap Blocks: exact=22289 lossy=11416
                    ->  Bitmap Index Scan on process_status_mfa_status_process_time_idx  (cost=0.00..9106.88 rows=276577 width=0) (actual time=154.601..154.601 rows=275394 loops=1)
"                          Index Cond: ((process_status = 'initialized'::text) AND (mfa_status = ANY ('{authorized,created}'::text[])))"
Planning Time: 0.747 ms
JIT:
  Functions: 13
"  Options: Inlining false, Optimization false, Expressions true, Deforming true"
"  Timing: Generation 5.034 ms (Deform 1.870 ms), Inlining 0.000 ms, Optimization 2.523 ms, Emission 14.448 ms, Total 22.005 ms"
Execution Time: 1279.667 ms
```

Postgres is doing the index scan (with filters) followed by sorting the results. This is happening because in the composite query, the `process_time` column is the last column in the index.
That means that the index is currently sorted in the priority of `process_status`, `mfa_status` and `process_time`... in that order. The query planner is not able to use the index to sort the rows based on the `process_time` column. 
It is sorting the rows after filtering them out. This is not efficient. 
It can be more efficient if postgres sorts first and then filter because we are only interested in top 100 rows. 

### Create a composite B-Tree index with proper order

Lets create a composite index on `process_status`, `mfa_status` and `process_time` columns in the order of `process_time`, `process_status` and `mfa_status`.

```sql
-- drop the previous index first
drop index process_status_mfa_status_process_time_idx;
-- create composite index
create index process_time_process_status_mfa_status_idx on process using btree (process_time asc, process_status, mfa_status);
```

Lets check the benchmark first.
```
latency average = 0.534 ms
tps = 1873.185352 (without initial connection time)
```

| index\_name | index\_size |
| :--- | :--- |
| process\_pk | 192 MB |
| process\_time\_process\_status\_mfa\_status\_idx | 229 MB |

This is a huge improvement. Lets check the query plan to see whats happening.

```sql
Limit  (cost=0.43..212.67 rows=100 width=74) (actual time=0.152..3.116 rows=100 loops=1)
  ->  Index Scan using process_time_process_status_mfa_status_idx on process  (cost=0.43..586993.14 rows=276577 width=74) (actual time=0.151..3.105 rows=100 loops=1)
"        Index Cond: ((process_status = 'initialized'::text) AND (mfa_status = ANY ('{authorized,created}'::text[])))"
Planning Time: 1.020 ms
Execution Time: 3.221 ms
```

Now the query planner is behaving as expected. It is using the index retrieve sorted rows and then filtering them out based on conditions.
However, we can still do better. We are indexing a lot of unnecessary values.
For example, in the query we are only interested in `process_status = 'initialized'` and `mfa_status in ('authorized', 'created')` but we are indexing all the `process_status` and `mfa_status` values. 
This is useless and it will,
1. Increase the size of the index.
2. Increase the time to update the index when the table is updated even when updating the index is not required.

To solve this, we can create a partial index.

### Create a partial B-Tree index

Lets create a partial index on `process_time`, `process_status` and `mfa_status` columns where `process_status = 'initialized'` and `mfa_status in ('authorized', 'created')`.

```sql
-- drop the previous index first
drop index process_time_process_status_mfa_status_idx;
-- create partial index
create index process_time_process_status_mfa_status_idx on process 
    using btree (process_time asc, process_status, mfa_status) 
    where process_status = 'initialized' and mfa_status in ('authorized', 'created');
```

Lets check the query plan now.
```sql
Limit  (cost=0.42..155.10 rows=100 width=74) (actual time=0.214..1.700 rows=100 loops=1)
  ->  Index Scan using process_time_process_status_mfa_status_idx on process  (cost=0.42..427806.10 rows=276577 width=74) (actual time=0.213..1.692 rows=100 loops=1)
Planning Time: 4.698 ms
Execution Time: 1.854 ms
```

Now we don't need to do the filter anymore on the index because it is already filtered. Lets check the benchmark now.
```
latency average = 0.453 ms
tps = 2209.602934 (without initial connection time)
```

| index\_name | index\_size |
| :--- | :--- |
| process\_pk | 192 MB |
| process\_time\_process\_status\_mfa\_status\_idx | 13 MB |

We see a marginal improvement in the performance. The index size is 17 times smaller. This is because we are only indexing the values which are required.
this is arguably the most efficient solution. However, there can be one final optimization. To understand that we need to understand how the index is accessed by postgres.

While running the query postgres first figures out which indexes would be used by `statstics` (which is a topic for another day). It then uses the indexes to get the `ctid` of the rows which satisfy the `where` clause. It then uses the `ctid`(the physical location of the row version within its table) to get the actual rows from the table. 
This is called a `heap fetch`. This is an additional step which can be avoided if we include the columns in the index itself. Introducing the `covering index`.

### Create a covering B-Tree index

Lets create a covering index. The index will be created like the partial index but will also `include` the columns which are required in the query (i.e. `process_id`, `process_type`, `mfa_id`, `mfa_expiry` columns) 
This will help to avoid the `heap fetch` step.

```sql
-- drop the previous index first
drop index process_time_process_status_mfa_status_idx;
-- create covering index
create index process_time_process_status_mfa_status_idx on process
    using btree (process_time asc, process_status, mfa_status)
    include (process_id, process_type, mfa_id, mfa_expiry)
    where process_status = 'initialized' and mfa_status in ('authorized', 'created');
```

Lets check the query plan now.
```sql
Limit  (cost=0.42..8.15 rows=100 width=74) (actual time=0.295..0.438 rows=100 loops=1)
  ->  Index Only Scan using process_time_process_status_mfa_status_idx on process  (cost=0.42..21359.16 rows=276577 width=74) (actual time=0.294..0.431 rows=100 loops=1)
        Heap Fetches: 0
Planning Time: 14.016 ms
Execution Time: 0.509 ms
```

This we get `Index Only Scan` compared to the `Index Scan` in the previous case. This means that the index contains all the required columns and the `heap fetch` step is avoided. Lets check the benchmark now.
```
latency average = 0.414 ms
tps = 2413.768133 (without initial connection time)
```

| index\_name | index\_size |
| :--- | :--- |
| process\_pk | 192 MB |
| process\_time\_process\_status\_mfa\_status\_idx | 33 MB |

We can see that the performance is almost similar (or marginally better) to the partial index. The difference will be more appaarent with larger amount of data. 
The index size however has increased from the partial index to accommodate all the extra included rows.
This is the most efficient solution for this query. We have squeezed out all the performance we can from the query using the btree index.

## Conclusion
In this article we saw,
1. How to optimize a query using B-tree index.
2. How and when to create individual B-tree indexes.
3. How and when  to create a composite B-tree index.
4. How and when  to create a partial B-tree index.
5. How and when  to create a covering B-tree index.
6. How to check the query plan to understand the query execution.
7. How to benchmark the query using `pgbench`.
8. How to check the index size.

