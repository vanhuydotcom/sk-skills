---
name: sk-implement
description: Write the code for work whose scope is already settled, matching the conventions of the surrounding module and verifying the result before reporting it done. Use when executing an agreed plan, adding a feature whose shape is clear, or making a change whose requirements need no further decisions.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Implement

For work where the decisions are made and what remains is writing it correctly. If the shape is
still open, plan first; if something is broken, diagnose first.

## Read before writing

Open the module you are about to change and the nearest existing example of what you are about
to add. Match what you find: naming, error handling, how the layer boundaries are drawn, how the
tests are structured, how dependencies are injected.

A change that reads like the surrounding code is reviewable. One that imports a new pattern for
the same job forces every future reader to hold two conventions, so introduce a new pattern only
when the existing one genuinely cannot express the requirement — and say so.

Check how the thing you are changing is used today. Grep for the callers before altering a
signature, a JSON field, a default value, or an error case. The callers, not the author's
intent, define the contract.

## Scope

Deliver the whole requested scope, and nothing beyond it.

- Do not quietly narrow the work because part of it is awkward. If something is blocked, finish
  everything else and say exactly what you left and why.
- Do not add the option, hook, or abstraction nobody asked for. A second caller is the earliest
  honest moment to generalise.
- Do not reformat, rename, or restructure code you did not otherwise need to touch. It buries
  the real change in noise.

## Write it

Prefer the change that is easy to delete. Local, direct, obvious beats clever and general.

Handle the error paths as you go rather than afterwards — the cleanup, the partial write, the
early return. Retro-fitting error handling is where the leaks come from.

Use the helpers and test utilities the repo already has. A new one-off helper that duplicates an
existing utility is a defect in waiting, because only one of them will get fixed.

If you implement something real behind a placeholder — a stub, fake data, a hard-coded value —
either finish it or state plainly that it is a stub. Never present scaffolding as working
behaviour.

## Verify before reporting

Run the narrowest test that covers the change. Widen to the package, then to lint, types or
build, when a shared contract moved.

Then check the result against the acceptance criteria you started with, not against your memory
of the request.

Report honestly:

- Say what you ran and what it printed. "Tests pass" without a command is not evidence.
- If something fails, show the output. Do not weaken, skip, or delete a test to get a green run.
- If you made an assumption, name it where the reader can object to it.
