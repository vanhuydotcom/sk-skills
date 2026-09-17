---
name: sk-perf
description: Diagnose and fix performance problems by measuring first, finding the dominant cost, and proving the improvement with the same measurement. Use when something is slow, memory or CPU use is growing, a query or endpoint degraded, or a change needs to be checked for a regression under load.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Performance

The discipline is short: **measure, find the dominant cost, fix that one thing, measure again.**
Everything below serves those four steps. Optimising without measuring reliably makes code harder
to read and no faster.

## 1. State the target

"Slow" is not actionable. Before touching anything, write down what is slow, for whom, and what
would be acceptable: which operation, at which percentile, with how much data, and the number
that ends the work.

Without a target you cannot tell when to stop, and performance work has no natural end.

## 2. Measure the real thing

Reproduce the slowness with production-shaped data. Most performance bugs are invisible on a
hundred rows and obvious on a million, because the defect is a complexity class, not a constant.

Measure the whole operation before profiling any part of it. Knowing that a request takes 4
seconds and the database accounts for 3.8 of them decides the entire investigation.

Look at the distribution, not the mean. A p50 of 40ms with a p99 of 9 seconds is a different
problem from a uniform 400ms, and the average hides both.

## 3. Find the dominant cost

Profile rather than guess. Intuition about where time goes is wrong often enough that checking is
always cheaper than acting on it. Use the language's profiler for CPU and allocation, the
database's plan for queries, and the browser's profiler for rendering.

The usual dominant costs, roughly in order of how often they turn out to be the answer:

- **A query issued per row of a previous result.** Fast in development, fatal in production.
  Collapse it into one query, or batch the lookups.
- **A missing or unusable index**, so a filter scans the table. Confirm with the query plan, not
  by reading the query.
- **Work repeated inside a loop** that could be hoisted, or a lookup in a list where a map
  belongs. This is the case where complexity, not constants, is the problem.
- **Serial I/O that could be concurrent**, where each call waits for the previous one.
- **Transferring far more data than is used** — unbounded result sets, oversized payloads,
  columns nobody reads.
- **Allocation pressure** in a hot path, visible as garbage collection time rather than as any
  single slow function.

Fix the dominant cost only. A 5% improvement on a component that accounts for 2% of the time is
indistinguishable from noise, and you will have spent real complexity to buy it.

## 4. Prove it

Re-run the original measurement, unchanged, and compare against the number you recorded. Report
both numbers and the conditions.

Then check you did not trade correctness for speed: run the tests around the change. A cache
introduces staleness, concurrency introduces races, and batching changes error handling — each of
those is a correctness change wearing a performance costume.

Be honest about noise. On a shared or thermally throttled machine a single run proves very
little; repeat enough to see whether the difference is real.

## Caching

Reach for a cache after the cheaper fixes, not before. A cache adds an invalidation problem, a
staleness window, and a second source of truth, and it often hides a query that should simply
have had an index.

When you do add one, decide up front what invalidates it and what a stale read costs. If you
cannot answer the second question, do not cache that value.

## Do not

- Do not micro-optimise code that runs once.
- Do not report an improvement you did not measure.
- Do not leave the profiling instrumentation, verbose timing logs, or the debug endpoint in the
  committed change.
