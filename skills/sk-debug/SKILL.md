---
name: sk-debug
description: Diagnose a failure to its root cause with evidence, then apply the fix that addresses that cause and a test that would have caught it. Use for bugs, crashes, wrong output, failing or flaky tests, broken CI, and behaviour that changed without an obvious reason.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Debug

The rule that makes debugging fast: **prove the cause before changing behaviour**. A change made
on a guess either fails, or succeeds for a reason you do not understand — and the second outcome
is worse, because it hides the real defect until later.

## 1. Reproduce

Find the smallest input and state that fails reliably. A bug you cannot trigger on demand cannot
be verified as fixed, so this step is not optional.

If it only fails sometimes, the variable is usually time, ordering, concurrency, or leftover
state from a previous run. Run the failing test alone, then with the rest of its package; a test
that passes alone and fails in a suite is sharing state.

Write the reproduction down. It becomes the regression test at the end.

## 2. Locate

Bound the problem before reading code. Establish two points — one where the data is still correct
and one where it is already wrong — then bisect between them. Two or three well-chosen checks
beat reading the whole call chain.

Useful bounds:

- The last commit where it worked (`git log`, `git bisect` when the range is wide).
- The layer boundary: is the value already wrong when it enters the service, or does the service
  corrupt it?
- The environment: does it fail with the same input locally?

## 3. Explain the cause

State the mechanism in one sentence that names the specific condition:

> The tenant filter is applied in the list query but not in the count query, so pagination
> reports another tenant's total whenever the page is full.

Test the explanation before accepting it. It must account for **everything** observed — including
why it worked before, and why it does not fail in the cases that pass. An explanation that covers
the failure but not the successes is incomplete, and fixing on it leaves half the bug in place.

If two explanations both fit, find the observation that separates them rather than picking the
likelier one.

## 4. Fix at the cause

Fix the mechanism you named, at the layer that owns it. A guard added downstream of the real
defect leaves the defect reachable by every other caller.

Resist the adjacent cleanup. A debugging diff should be small enough that the reviewer can see
the causal link between the change and the failure.

## 5. Prove it

Add the test from step 1, and confirm it fails without the fix. A regression test that passes on
the broken code is testing something else.

Then re-run the original reproduction, and the suite around the change.

## Flaky tests

A flaky test is reporting a real race most of the time. Run it under the race detector and in
a loop before concluding otherwise. Never "fix" it with a sleep, a retry, or by disabling it —
that converts a visible defect into an invisible one.

## Do not

- Do not change several things at once. If it starts working you have learned nothing.
- Do not report a fix as verified when you only reasoned that it should work.
- Do not delete or weaken the failing test to get a green run. Report the failure with its
  output instead.
