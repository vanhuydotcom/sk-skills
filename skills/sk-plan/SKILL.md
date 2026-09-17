---
name: sk-plan
description: Turn a vague request into an agreed outcome and an executable plan, by fixing the outcome, constraints, non-goals and acceptance criteria, comparing the viable approaches, and splitting the work into phases that can each be verified. Use before starting multi-step work, when a request has more than one reasonable interpretation, or when several designs would all technically work.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Plan

A plan exists to prevent building the wrong thing and to make "done" checkable. If the work is
one obvious change with one obvious verification, skip this and do it.

## 1. Fix the outcome before anything else

Write four things down. If you cannot, you do not yet understand the request.

- **Outcome** — what is true after this ships, stated as observable behaviour rather than as a
  task list. "Operators can cancel a dispatched order" is an outcome; "add a cancel endpoint"
  is a task.
- **Constraints** — what cannot change: compatibility, deadline, data volume, dependencies you
  do not own.
- **Non-goals** — what a reasonable reader might expect but will not be delivered. This is the
  field that prevents scope creep, so name the tempting adjacent work explicitly.
- **Acceptance criteria** — the checks that decide the work is finished. Each must be able to
  fail.

Discover what you can from the repo and the running system before asking. Ask only about a
decision that cannot be recovered from evidence — a product trade-off, a priority, a deadline.
State the assumption and continue when an answer would not change the next step.

## 2. Compare approaches, then commit

Only when more than one design genuinely works. For each candidate name the mechanism, the cost,
and the thing it makes hard later. Then recommend one and say why. A list of options with no
recommendation pushes the decision back to the reader and is not a plan.

Reject the approach that is easiest to write but hardest to verify. Reversibility is worth more
than elegance: prefer the design you can withdraw in one commit.

## 3. Split into phases

A phase is a unit that leaves the system working and can be verified on its own. Two phases that
must land together are one phase.

For each phase record:

```
Phase N — <the outcome of this phase>
  Files      <paths you expect to touch>
  Steps      <what changes, briefly>
  Verify     <the command or check that proves it, and what a failure looks like>
  Rollback   <how to undo it, if it touches data, contracts or config>
```

Order phases so the riskiest assumption is tested first. A plan that proves the hard part in
phase 4 has wasted the three phases before it.

## Sizing

If a phase has no verification you can name, it is not a phase — it is a wish. Split it until
each part can be checked.

If the plan exceeds roughly six phases, the scope is too large to hold. Deliver the first
coherent slice and re-plan with what you learn.

## Do not

- Do not plan the implementation line by line. The plan sets direction and checkpoints; the
  implementer chooses the code.
- Do not restate the codebase back to the reader. Reference paths instead.
- Do not silently drop a requirement because it is inconvenient. Move it to non-goals, visibly,
  so the reader can object.
