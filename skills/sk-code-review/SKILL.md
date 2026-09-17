---
name: sk-code-review
description: Review a diff, branch, commit or merge request for correctness defects, and report each finding with the concrete input that makes it fail. Use before opening or merging a change, when asked to review code, or when a change touches shared contracts, auth, money, tenancy or data migrations.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Code review

Find defects a reader would otherwise ship. A review that lists style preferences and misses the
nil dereference has failed, so correctness comes first and everything else is optional.

## Establish the diff first

Review a change, never a snapshot. Resolve the target before reading anything:

| Target | Command |
|---|---|
| Uncommitted work | `git diff HEAD` |
| A branch | `git diff $(git merge-base HEAD <base>)...HEAD` |
| One commit | `git show <sha>` |
| A merge request | fetch the source branch, then diff against its base |

Read the full body of every changed function, not only the changed lines. Most real defects live
in the interaction between a changed line and the unchanged lines around it.

## What to look for, in priority order

1. **Correctness.** Nil and bounds, off-by-one, inverted conditions, an error assigned but not
   returned, a wrong operator precedence, a case the new branch no longer reaches.
2. **Concurrency and lifetime.** A value captured by a goroutine or closure that outlives its
   owner. A request-scoped handle (transaction, context, connection) used after the request
   ends. A lock held across I/O.
3. **Contract breakage.** A changed signature, JSON field, enum value, error code or default
   that an existing caller still relies on. Check the callers; do not assume the author did.
4. **Data safety.** A migration with no rollback, a bulk `UPDATE`/`DELETE` without a scoping
   predicate, a write that skips the tenancy filter, a unique constraint added over data that
   may already violate it.
5. **Resource leaks.** An opened file, row set, ticker or connection whose close is skipped on
   the error path.
6. **Test gap.** A behaviour introduced or repaired with no test that would fail without the
   change. Report it; do not write the test unless asked.

See [references/checklist.md](references/checklist.md) for the per-language specifics.

## The evidence rule

State a finding only when you can name the input or state that triggers it. Write the trigger
into the finding itself:

> `order.Items` is indexed at `[0]` on line 88 before the empty check on line 94, so a cart
> submitted with zero items panics instead of returning the validation error.

If you cannot produce that sentence, you have a suspicion, not a finding. Either verify it — read
the caller, check the schema, run the test — or leave it out. A review padded with hedged
maybes trains the reader to ignore the real ones.

## What not to report

- Formatting a formatter owns, and naming that matches the surrounding file.
- A pattern the codebase uses consistently elsewhere. If you believe the pattern itself is wrong,
  that is a separate conversation, not a finding against this diff.
- A rewrite of working code into your preferred shape.
- A concern already answered by a test in the diff. Read the tests before writing the finding.
- Anything outside the diff, unless the diff breaks it.

## Report format

```
<One sentence: is this safe to merge, and what is the single biggest risk.>

BLOCKING
  path/to/file.go:88   <defect> — <the input that triggers it>

NON-BLOCKING
  path/to/file.go:140  <defect> — <why it matters>

Verified and fine
  <invariant you actively checked and found correct>
```

`BLOCKING` means it is wrong or unsafe, not that you dislike it. If nothing is blocking, say
so plainly in the first line rather than promoting a nit to fill the section.

The "Verified and fine" section is not filler — it tells the author which risks you actually
checked, so they know what the review does and does not cover.
