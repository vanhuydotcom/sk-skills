---
name: hd-scout
description: Locate the files and call paths relevant to a task before changing anything, and report them as a short map with exact paths and line numbers. Use when starting work in an unfamiliar area, tracing who calls or writes something, answering "where is X handled", or gathering context before planning, reviewing or debugging.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Scout

Turn a vague target ("the checkout flow", "where tenancy is enforced") into a short list of
exact paths worth reading. Scouting is read-only: it never edits, never runs migrations, and
never starts servers.

## When to stop

Scouting is done when you can name the entry point, the owner of the behaviour, and the tests
that cover it. Finding more files after that is waste. If the answer is one file you already
know, skip this skill and open the file.

## Procedure

**1. Fix the vocabulary before searching.** The user's words are rarely the code's words. Turn
the request into 2-4 candidate identifiers: a route or URL fragment, a type or table name, an
error string, a config key. Search for the identifiers, not the description.

**2. Search widest-signal first.** Order matters, because each step narrows the next:

- Exact strings that cannot appear by accident: error messages, route literals, column names,
  env var names. These land on the owner directly.
- Type and function definitions, to find the declaration rather than the call sites.
- Call sites, once you know the declaration's exact name.

Run independent searches in parallel rather than one at a time. Prefer a literal match over a
clever regex; a regex that needs debugging costs more than two literal searches.

**3. Read only enough to confirm ownership.** Open a file to answer one question: does this own
the behaviour, or merely reference it? Read the function, not the file. A file that only imports
and forwards is a signpost, not an owner — follow it and drop it from the report.

**4. Find the tests.** The test that covers a behaviour documents its contract and its edge
cases more honestly than any comment. A behaviour with no test is itself a finding worth
reporting.

## Handling a dead end

If the identifiers return nothing, the vocabulary guess was wrong — do not widen the same search
with more regex. Re-derive the vocabulary from a different angle: the UI label the user quoted,
the database table, the API path, a recent commit touching that area. Say which angle you tried
and which one worked.

If the search returns hundreds of hits, the identifier is too generic. Narrow by directory
(the owning module) or by combining two identifiers that must co-occur.

## Report format

Lead with the answer, then the evidence. Keep it under 20 lines.

```
<One or two sentences: where the behaviour lives and how control reaches it.>

Entry point   path/to/handler.go:142
Owner         path/to/service.go:88        <what it actually decides>
Data          path/to/repository.go:210    <the query or write>
Tests         path/to/service_test.go:31
Related       path/to/config.yaml:12       <only if it changes behaviour>
```

Rules for the report:

- Every path carries a line number. A path without one has not been verified.
- Name what each file decides, not what it is called. "validates tenancy before the query" beats
  "service layer".
- List at most 7 paths. If more seem necessary, the scope is too wide — say so and propose
  splitting the task.
- State what you did **not** find. An absent test, an absent validation, or a second code path
  that also writes the same table are the findings that change a plan.

## Do not

- Do not propose a fix. Scouting establishes where; deciding what belongs to the next step.
- Do not summarise a file's contents at length. Paths and one-line roles are the deliverable.
- Do not report a path you have not opened.
