# Btree Index

Btree is the default index method in postgres. It is a balanced tree data structure that stores sorted data and allows searches, sequential access, insertions, and deletions in logarithmic time. The tree is kept balanced by splitting and merging nodes as needed.

## How it works

A Btree is a tree data structure where each node contains a fixed number of keys and pointers to child nodes. The keys in each node are sorted, and the pointers point to child nodes that contain keys within a certain range. This allows for efficient searches, insertions, and deletions.

![Btree](btree.png)

## Advantages

- Efficient searches: Btrees allow for efficient searches by traversing the tree in logarithmic time.
- Sorted data: Btrees store data in sorted order, which allows for efficient range queries.
- Balancing: Btrees are kept balanced by splitting and merging nodes as needed, which ensures that the tree remains efficient.

## Disadvantages

- Overhead: Btrees have some overhead in terms of memory and disk space due to the need to store pointers to child nodes.
- Slower insertions: Btrees can be slower to insert data compared to some index methods like hash indexes due to the need to rebalance the tree.

## Demo

We start the database with [this docker compose file](compose.yaml).
