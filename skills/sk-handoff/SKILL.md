---
name: sk-handoff
description: Capture in-progress work as a self-contained continuation brief so another session, agent runtime or person can resume without the original conversation, recording what is done, what is verified, what is assumed and what is blocked. Use when switching sessions, models or runtimes, when context is running out, or when passing work to someone else.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Handoff

The successor has the repository and this document, and nothing else. Every judgement that lives
only in the conversation is lost unless it is written down — so the test for this document is
whether someone could resume from it cold.

## What actually gets lost

Not the code; the code is in the diff. What disappears is the reasoning:

- Why the obvious approach was rejected.
- Which things were verified, and how, versus which were assumed.
- What is deliberately unfinished, as opposed to overlooked.
- The dead ends, so nobody spends an hour rediscovering them.

Write those. Skip anything the successor can read from `git diff` or the file tree.

## Format

```
GOAL
  <the outcome being pursued, and the acceptance criteria that end the work>

STATE
  Done          <what works now, with the paths>
  In progress   <what is half-finished, and in what way it is half-finished>
  Not started   <remaining scope>

VERIFIED
  <claim> — <the command run and what it printed>

ASSUMED
  <assumption> — <why it was reasonable, and what breaks if it is wrong>

DECISIONS
  <what was chosen, what was rejected, and the reason>

BLOCKED
  <the blocker, what has been tried, and what would unblock it>

NEXT
  1. <the first concrete action, with the path to start from>
```

Keep `VERIFIED` and `ASSUMED` strictly separate. Collapsing them is the single most expensive
error in a handoff: the successor trusts an assumption as a checked fact and builds on it.

## Rules

Give exact paths with line numbers, never "the auth module".

Record the working state honestly. If tests fail, say which and paste the output. A handoff that
reports green work as finished sends the successor looking for a bug in their own changes.

Name the environment the work depends on: the branch, the checked-out state of any sibling
repository, running services, seeded data, an environment variable that must be set.

Redact secrets. Reference the variable name and where it comes from, never its value.

Keep it to one page. A handoff long enough to need skimming will be skimmed, and the important
line will be the one skipped.

## Before handing off

Commit or explicitly describe the uncommitted work — a successor who cannot see your changes
cannot continue them. Say which branch, and whether it is pushed.

Then re-read the document as the successor: given only this and the repository, is the first
action in `NEXT` unambiguous? If not, that is the part to rewrite.
