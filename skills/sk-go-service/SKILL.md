---
name: sk-go-service
description: Implement, extend or debug a handler, service or repository in a Go backend service, covering context propagation, error wrapping, transaction boundaries, tenancy scoping and table-driven tests. Use when writing or changing Go server code, adding an endpoint or gRPC method, touching a repository query, or diagnosing a panic, leak or flaky test in a Go service.
license: MIT
compatibility: Requires a Go toolchain; assumes a layered handler/service/repository codebase.
metadata:
  author: huydv
  version: "1.0"
---

# Go service work

Conventions that keep a layered Go service correct under concurrency and multi-tenancy. Read the
surrounding package first — a local pattern that is applied consistently wins over anything here.

## Before writing code

Check the toolchain. `go.mod` decides which standard library and language features are available,
and services in the same workspace often sit on different versions. A loop-variable capture is a
real bug below Go 1.22 and a non-issue above it; `errors.Join`, `slices` and `maps` need 1.21.
Read the version rather than assuming the newest.

Then find the layer that owns the decision you are about to change. Handlers translate transport
to domain and nothing else. Services hold the decision. Repositories hold the query. A validation
added in the handler is invisible to every other caller of the service.

## Context

The context belongs to the request and dies with it.

- Pass `ctx` as the first parameter, all the way to the database call. A function that takes no
  context cannot be cancelled and cannot carry a deadline.
- Never store a `context.Context` in a struct field.
- Never hand a request context to a goroutine that outlives the handler. Detached background
  work needs its own context with its own timeout, and the values it needs copied out explicitly
  before the handler returns.
- The same applies to any handle derived from the request — a transaction, a connection, a
  request-scoped database accessor. Using one after the handler returns is a use-after-free with
  a friendlier error message.

## Errors

- Wrap with `%w` and add what the caller cannot already know: the identifier, the operation.
  `fmt.Errorf("load order %d: %w", id, err)`. Do not prefix with the function name; a stack of
  those reads as noise.
- Compare with `errors.Is` and `errors.As`. A direct `==` breaks the moment anyone wraps.
- Translate to a transport status in exactly one place, at the handler boundary. A repository
  that returns an HTTP code has leaked two layers.
- `sql.ErrNoRows` is a domain outcome, not a failure. Map it to the domain's "not found" at the
  repository edge so the service never imports `database/sql`.
- Never discard an error to satisfy the compiler. If it is genuinely ignorable, assign to `_`
  with a comment saying why.

## Transactions

Open the transaction at the layer that owns the invariant — usually the service, never the
repository, because a repository that opens its own transaction cannot be composed into a larger
one. Pass the transaction handle down.

Commit and rollback on every path, including panic. The rollback after a successful commit must
be harmless; that is what makes `defer tx.Rollback()` safe.

Do no I/O inside a transaction that does not need to be atomic with it. An HTTP call to a payment
provider inside an open transaction holds database locks for the length of someone else's outage.

## Tenancy

If the service is multi-tenant, the tenant identifier is enforced in code, not by the database.
Every repository query — read and write — carries the tenant predicate. A query that filters only
by primary key will happily return another tenant's row. Derive the identifier from the request
context accessor the codebase already uses, and check which accessor is correct: a service acting
on behalf of a sub-tenant usually has two, and the obvious one is often the wrong one.

## Goroutines

Every goroutine needs a known lifetime and a known owner. Before writing `go`, answer: who waits
for it, how does it stop, and where does its error go? A goroutine whose error is dropped is a
silent failure.

Use `errgroup` when the caller waits. Use an explicit `sync.WaitGroup` plus a collected error
channel when it does not fit. A bare `go f()` in request handling is nearly always a defect.

## Tests

Table-driven, one `t.Run` per case, named for the behaviour rather than the input. Each case
states its input, its expectation, and nothing else; setup shared by every case belongs above
the table.

Always pass a timeout when running them:

```bash
go test -count=1 -timeout 60s ./...
```

`-count=1` defeats the result cache, which otherwise reports a pass for code you just changed.
The timeout matters more than it looks: a deadlocked test with no timeout consumes memory until
the machine stalls.

Test the exported behaviour of the package. A test that reaches into unexported internals locks
the implementation in place and fails on every honest refactor.

When a test is flaky, it is reporting a real race most of the time. Run it under `-race` before
concluding otherwise, and never fix it by adding a sleep.

## Before calling it done

Run the narrowest test that covers the change, then widen if a shared contract moved. Run
`golangci-lint run` in the service rather than a make target that may swallow the exit code.
Report failures with their output instead of weakening the test.
