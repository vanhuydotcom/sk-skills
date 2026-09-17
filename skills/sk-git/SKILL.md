---
name: sk-git
description: Stage, commit, branch and publish changes using conventional commits, splitting unrelated work into separate commits and checking for secrets before anything leaves the machine. Use when committing, pushing, opening a merge request or pull request, or cleaning up a branch before review.
license: MIT
compatibility: Requires git; publishing steps assume a GitHub or GitLab remote.
metadata:
  author: huydv
  version: "1.0"
---

# Git

## Before staging anything

Read the diff. `git status` lists names; `git diff` shows what you are about to publish. This is
the step that catches a debug print, a commented-out block, a changed timeout, or a credential.

Scan for secrets every time, not only when you think you touched one:

```bash
git diff --cached | grep -niE 'password|secret|token|api[_-]?key|private[_-]?key|BEGIN [A-Z ]*PRIVATE KEY|postgres://|mysql://'
```

Never commit a `.env` file, a key, a token, a database URL with credentials, a dump, or personal
data. If one is already committed locally, remove it from the commit before pushing — once it
reaches a remote, treat the value as compromised and rotate it.

## Commit messages

```
<type>(<scope>): <what changed, imperative, lower case>

<why it changed, when the reason is not obvious from the diff>
```

Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`.

The subject says what the change does, not what you did: `fix(order): reject cancel on dispatched
order`, not `fixed the bug`. Keep it under about 72 characters, with no trailing period.

The body is for the reason, the trade-off, or the constraint — the things a reader cannot
reconstruct from the code. Skip it when the subject is complete.

Do not put plan identifiers, phase numbers, ticket-internal codes or audit labels in the message.
Describe the behaviour; a link belongs in the merge request.

## One commit, one concern

If the subject needs "and", split it. A refactor mixed into a bug fix makes the fix impossible to
review and impossible to revert cleanly.

Stage selectively with `git add -p` when one file holds two concerns. Commit the mechanical
change first and the behavioural change second, so a reviewer can skim the first and read the
second.

## Branches

Branch from the base your project actually merges into, and confirm which that is before
starting — a repository with separate release and integration branches will silently accept the
wrong base and surface it as conflicts later.

Name it `<type>/<short-slug>`. Keep it rebased on its base rather than merging the base back in
repeatedly; a branch whose history is half merge commits is unreadable in review.

## Publishing

Push, then open the request with a description that a reviewer can act on: what changes, why,
what you verified, and what you deliberately left out. Link the issue; do not paste the diff back
as prose.

Before requesting review, read your own diff one final time as if you did not write it.

## Ask first

Committing, pushing, force-pushing, opening a request, and merging are the user's calls. Do them
when asked. Never force-push a shared branch, rewrite published history, amend someone else's
commit, or merge on your own initiative.
