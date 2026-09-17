---
name: sk-test
description: Write and run tests that fail for the right reason, choosing the cheapest level that can catch the defect and testing exported behaviour rather than internals. Use when adding tests, deciding what to test, fixing a flaky or slow suite, or judging whether existing coverage actually protects a change.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Test

A test earns its place by failing when the behaviour breaks and passing otherwise. Tests that
cannot fail, or that fail for unrelated reasons, cost more than they protect.

## Choose the cheapest level that can catch it

Ask what could realistically break, then pick the level that would notice:

| The risk | Test at |
|---|---|
| Wrong logic, wrong branch, wrong calculation | Unit, against the exported function |
| Wrong query, wrong constraint, wrong migration | Integration, against a real database |
| Wrong wiring between components | One integration test through the seam |
| Wrong contract with a caller | A contract test on the request and response shape |
| A whole user journey | One end-to-end test, not ten |

Do not test at a higher level than the risk requires. An end-to-end test that catches an
arithmetic error is a slow, flaky way to learn something a unit test says in milliseconds.

## Write it against behaviour

Test what the package promises, not how it currently does it. A test that reaches into
unexported state locks the implementation in place and fails on every honest refactor — which
trains people to edit tests until they pass.

Table-driven, one case per row, named for the behaviour rather than the input: `rejects an
order with no items` tells a failing CI log what broke; `case 3` does not.

Each case states its input and its expectation and nothing else. Setup shared by every case
belongs above the table, not repeated inside it.

Assert the specific thing. `err != nil` passes when the code fails for a completely different
reason; assert the error identity or the message you actually expect.

## The new-test check

A test written alongside a fix must fail without the fix. Verify that — revert the change, watch
it go red, restore it. A regression test that was green on the broken code is testing something
else, and everyone will believe it is protecting them.

## Running

Always pass a timeout, and defeat the result cache when you have just changed code:

```bash
go test -count=1 -timeout 60s ./path/...
```

The timeout matters more than it appears: a deadlocked test without one runs until it exhausts
the machine.

Run the narrowest scope first. Widen only when a shared contract moved.

## Flaky and slow

A flaky test is usually reporting a real race. Run it under the race detector and in a loop
before deciding otherwise. Never stabilise it with a sleep, a retry wrapper, or a skip — each of
those hides a defect that will reappear in production.

A test that passes alone and fails in its suite is sharing state: a global, a fixture, a
database row, a file, an environment variable. Find the shared thing rather than reordering the
suite.

For a slow suite, measure before optimising. The cost is usually a handful of tests doing real
I/O that do not need to.

## Coverage

Coverage tells you what is definitely untested. It does not tell you what is tested well, and a
percentage target produces assertion-free tests that execute lines without checking anything.
Use it to find blind spots, never as a goal.
