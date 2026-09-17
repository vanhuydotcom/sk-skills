---
name: sk-plan
description: Turn a settled outcome into an executable plan by splitting the work into phases that each leave the system working and can be verified on their own. Use once the approach is chosen and the acceptance criteria are known, before starting multi-step delivery. If the outcome or the approach is still open, brainstorm first.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Plan

A plan exists to prevent building the wrong thing and to make "done" checkable. If the work is
one obvious change with one obvious verification, skip this and do it.

## 1. Start from a settled outcome

A plan needs these four before it can be written:

- **Outcome** — what is true after this ships, stated as observable behaviour rather than as a
  task list. "Operators can cancel a dispatched order" is an outcome; "add a cancel endpoint"
  is a task.
- **Constraints** — what cannot change: compatibility, deadline, data volume, dependencies you
  do not own.
- **Non-goals** — what a reasonable reader might expect but will not be delivered. This is the
  field that prevents scope creep, so name the tempting adjacent work explicitly.
- **Acceptance criteria** — the checks that decide the work is finished. Each must be able to
  fail.

If they already exist — from an accepted design, a ticket, or an earlier conversation — reuse
them and move on. If you cannot write them, the approach is not settled yet: brainstorm first,
because planning an unsettled outcome produces phases for the wrong work.

Discover what you can from the repo and the running system before asking. Ask only about a
decision that cannot be recovered from evidence. State the assumption and continue when an answer
would not change the next step.

## 2. Confirm the approach

The approach should already be chosen. Restate it in one sentence, along with the assumption it
rests on, so a reader who disagrees can object before the phases are built on it.

Reject an approach that is easiest to write but hardest to verify. Reversibility is worth more
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
