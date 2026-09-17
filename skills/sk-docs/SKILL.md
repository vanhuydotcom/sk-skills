---
name: sk-docs
description: Create and update project documentation that stays true, updating only the smallest surface that a change actually affects and verifying every claim against the source. Use when user-visible behaviour, setup, commands, configuration, architecture or a public contract changed, or when documentation is wrong, missing or contradicts the code.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Documentation

Documentation competes with the code for the reader's trust. Once a page is wrong about one
thing, the reader stops believing all of it — which makes a small amount of verified
documentation worth far more than a thorough set of plausible pages.

## When to write

Update the docs when the change affects: user-visible behaviour, how to set the project up, a
command or its flags, configuration or environment variables, architecture, a public contract, or
a decision a future maintainer would otherwise have to re-derive.

Do not update them for an internal refactor, a completed phase of work, or a bug fix that
restored the documented behaviour. Documentation churn with no informational change costs review
time and trains people to skim the diff.

## Find the smallest owning surface

Before writing, find where this is already documented. The most common documentation defect is
not an absent page but a second page that now disagrees with the first.

Update the one place that owns the topic. Link to it from elsewhere rather than restating it,
because a restatement is a copy that will drift.

Never duplicate what a machine already owns. Link to the script, the schema, the manifest, the
generated reference. A flag list copied into prose is wrong on the next release.

## Write for the reader who is stuck

Lead with what the reader is trying to do, not with how the system is organised. Someone reads a
page because they are blocked, and the answer should be visible without scrolling.

State prerequisites before steps. Give commands as complete, runnable lines. Show what success
looks like, so the reader can tell whether it worked.

Document the failure mode next to the thing that fails. The error message a reader will actually
see is the most searchable text you can put on a page.

Explain *why* for anything surprising. The constraint behind an odd-looking step is what stops
the next person from "simplifying" it back into a bug.

## Verify before publishing

Read the page before editing it — including the parts you are not changing, because that is where
the contradiction will be.

Then check every claim against the source: run the command, open the file, confirm the path and
the flag still exist. A documented path that has been renamed is worse than no documentation,
because the reader trusts it and loses time.

Check the links, including anchors.

## Style

Write complete sentences in the present tense, describing how the system behaves now. A page is
not a changelog: "the endpoint returns 404" not "we changed the endpoint to return 404".

Prefer a short page that is entirely true over a long one that is mostly true. When a page grows
past what a reader will hold, split it by task rather than by subsystem.
