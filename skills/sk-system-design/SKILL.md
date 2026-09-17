---
name: sk-system-design
description: Design or evaluate a distributed system from its constraints — service boundaries, synchronous versus event-driven communication, consistency, failure behaviour and capacity — and state the trade-off each choice buys. Use when splitting or merging services, choosing between a call and an event, deciding where data lives, reviewing an architecture proposal, or answering a system design question.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# System design

The failure mode is jumping to components. A design that names services before it names
constraints is a guess with boxes drawn around it, and it cannot be evaluated because nothing
says what it was supposed to achieve.

## 1. Constraints before components

Write these down first. Each one eliminates designs:

- **Load** — requests per second at peak, and the read-to-write ratio. Reads and writes scale by
  completely different means, so the ratio decides more than the absolute number.
- **Data** — total volume, growth rate, and the size of a single item.
- **Consistency** — what must be correct immediately, and what may be stale. Almost never "all of
  it"; naming the small part that must be strict is what makes the rest cheap.
- **Availability** — what happens to the business during an outage of this component, and what
  degraded behaviour is acceptable.
- **Latency** — the budget for the user-facing path, at a percentile rather than a mean.
- **Ownership** — which team deploys and pages for each part. A boundary that cuts across a team
  becomes a coordination cost on every change.

Estimate roughly and say so. An order of magnitude is enough to choose an architecture, and
precision you do not have is not worth performing.

## 2. Boundaries

Split by what changes together and who owns the data, not by noun. A service that cannot be
deployed without another service deploying at the same time is one service in two repositories,
with added network calls.

Each piece of data has exactly one owner that writes it. Everyone else reads through the owner's
interface or through a copy the owner publishes. Two services writing the same table is the
distributed monolith: independent deploys, shared failure, and no clear place to enforce an
invariant.

Prefer fewer, larger services until a real force requires a split — independent scaling, separate
ownership, genuinely different availability needs. Splitting is cheap to do and expensive to undo,
and every boundary converts a function call into a network call that can fail, retry, and arrive
twice.

## 3. Synchronous or event-driven

Call synchronously when the caller cannot proceed without the answer and the user is waiting.
Every synchronous dependency adds its downtime to yours and its latency to your budget, so count
them: a request that touches five services synchronously is less available than any one of them.

Publish an event when other parts of the system need to know something happened but the caller
does not need their response. This decouples availability — the consumer can be down without
failing the write.

Be honest about the cost. An event gives you eventual consistency, out-of-order and duplicate
delivery, and a debugging path that no longer appears in one stack trace. Take that trade when
you need the decoupling, not because it sounds modern.

When a write must update local state *and* tell someone else, the two must not be able to
diverge. Write the event into the same transaction as the state change and publish it from there,
rather than writing the row and then calling the broker — the gap between those two calls is
where the lost message lives.

## 4. Assume every remote call fails

For each one, decide in advance:

- **Timeout** — an explicit one, shorter than the caller's own budget. A call with no timeout
  turns a slow dependency into an outage as threads pile up.
- **Retry** — only for transient failures, only with backoff and jitter, and only when the
  operation is idempotent. Retrying a non-idempotent write duplicates it; synchronised retries
  from every client turn a blip into a stampede.
- **Idempotency** — a key the caller supplies, so a retry after a timeout is recognised. The
  caller cannot tell a lost request from a lost response, so it will retry.
- **Degrade** — what the user sees when this stays down. Serving a cached or partial result is
  usually better than an error page, and deciding it at design time is what makes it possible.

## 5. Consistency

Identify the invariant that must never break — money conserved, stock not oversold, no double
charge — and keep it inside a single transaction in a single service. This constraint, more than
any other, should decide your boundaries.

Everything outside that invariant can be eventually consistent. When a workflow spans services,
model it as a sequence of local transactions with a compensating action for each step, and accept
that the intermediate states are visible.

Distributed transactions across services are a last resort. The compensating-action design is
harder to think about and far easier to operate.

## 6. Write it down

```
Constraints   <load, data, consistency, availability, latency, ownership>
Design        <components and what each owns>
Flows         <the two or three important paths, in order>
Failure       <what happens when each dependency is down, and what the user sees>
Trade-offs    <what this design makes hard, and what you would change first at 10x>
Rejected      <the alternative and why not>
```

The `Failure` and `Rejected` rows are what separate a design from a drawing. A proposal that only
describes the happy path has not been evaluated.

## Do not

- Do not add a queue, cache or shard for a load you have not measured or estimated.
- Do not design for 100x when you are at 1x. Design so the known next step is possible, and say
  what breaks first beyond it.
- Do not present a single option as inevitable. Name what you rejected.
