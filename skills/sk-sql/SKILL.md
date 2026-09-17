---
name: sk-sql
description: Design schemas, write and index queries, and run migrations and data changes safely with a rollback path and a dry run. Use when adding or altering tables and columns, writing a non-trivial query, diagnosing a slow one, or executing any operational SQL against real data.
license: MIT
compatibility: Examples use PostgreSQL syntax; the principles apply to any relational database.
metadata:
  author: huydv
  version: "1.0"
---

# SQL and migrations

Schema and data changes are the least reversible thing an engineer does. The discipline below is
proportional to that, not to the size of the diff.

## Schema design

Let the database enforce what must always be true. A constraint holds against every writer,
including the script someone runs at midnight; application-level validation holds only against
the paths that remembered it. Use `NOT NULL`, foreign keys, `UNIQUE`, and `CHECK` for real
invariants.

Pick types for the domain, not for convenience. Money is an exact type, never a float. Time is
timestamptz with an explicit zone policy. An identifier that is never arithmetic is text.

Nullable means "this can legitimately be absent". If absent is impossible, forbid it now — adding
`NOT NULL` later means backfilling rows you cannot reason about.

Name things so a join reads out loud: singular column, plural table, `<table>_id` for a foreign
key, and the same name for the same concept everywhere.

## Queries and indexes

Read the plan before believing anything about performance:

```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT ...;
```

`ANALYZE` executes the statement, so use a transaction you roll back when the statement writes.
Compare estimated against actual rows — a large gap means the planner is working from stale
statistics, and the fix is `ANALYZE` on the table, not a rewritten query.

Index the columns the query filters and joins on, in the order the query uses them; a composite
index serves a prefix of its columns, not an arbitrary subset. Every index costs write throughput
and storage, so add one for a measured query, not a hypothetical one.

Watch for the query issued once per row of a previous result. That is the single most common
cause of an endpoint that is fast in development and slow in production, and it is invisible in
the plan of any individual statement.

Never build SQL by concatenating user input. Parameterise. If an identifier genuinely must be
dynamic, validate it against a fixed allow-list.

## Migrations

Every migration needs a rollback that actually undoes it. A rollback you have not thought through
is the same as none.

Separate the change of shape from the change of data. Adding a column, backfilling it, and making
it required are three deploys, not one — the middle one is where you discover the rows that do
not fit.

Compatibility during deploy matters because old and new code run at the same time. Add before you
remove: a renamed column is a new column, a dual write, a backfill, then a drop in a later
release. A migration that drops or renames in one step takes the running system down.

On a large table, an unqualified rewrite locks it. Add indexes concurrently, add columns without
a volatile default, and backfill in batches with a pause between them.

## Operational SQL

For anything run by hand against real data:

1. **Back up first**, and confirm the backup exists and is restorable. Not "there is a nightly".
2. **Select before you mutate.** Run the `WHERE` clause as a `SELECT COUNT(*)` and confirm the
   number matches what you expect. A count that surprises you is the change surprising you.
3. **Dry run in a transaction** you roll back, with errors made fatal:

   ```sql
   BEGIN;
   UPDATE orders SET status = 'cancelled' WHERE id = 42 AND tenant_id = 7;
   -- verify the row count, then:
   ROLLBACK;
   ```

4. **Scope every statement.** A bare `UPDATE` or `DELETE` with no `WHERE`, or a `WHERE` missing
   the tenant predicate, is the incident. Write the `WHERE` before the `SET`.
5. **Run it for real** only after the dry run matched, inside a transaction, and check the
   affected row count before committing.

Never run destructive SQL against production because it worked in staging. The data differs, and
the data is the whole risk.
