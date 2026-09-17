---
name: sk-diagram
description: Produce Mermaid diagrams that show a real mechanism — architecture, request flow, sequence, state or data model — chosen from the source rather than from assumption. Use when a picture would explain a system faster than prose, when documenting a flow or architecture, or when asked for a diagram, flowchart or sequence diagram.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Diagrams

A diagram earns its place when the relationships matter more than the details — order, fan-out,
a cycle, a boundary. If the content is a list, write a list; a flowchart of five sequential steps
is harder to read than five numbered lines.

## Pick the type from the question

| The question | Diagram |
|---|---|
| What talks to what? | `flowchart` |
| In what order, and who waits? | `sequenceDiagram` |
| What states can this be in, and what moves it? | `stateDiagram-v2` |
| How is the data shaped and related? | `erDiagram` |
| What happens over time? | `gantt` or `timeline` |

Most "architecture diagram" requests are answered better by a sequence diagram, because the
useful information is the order and the failure points, not the boxes.

## Draw the real thing

Read the code first. A diagram drawn from what a system of this kind usually looks like is
confidently wrong, and a wrong diagram propagates further than wrong prose because nobody
re-derives it.

Show the mechanism, not the org chart. Label each edge with what actually crosses it — the call,
the event, the data — rather than leaving an unlabelled arrow that could mean anything.

Include the failure and the asynchrony. The error path, the retry, the timeout and the queue are
usually the reason someone is reading the diagram at all, and a happy-path-only picture hides
exactly what they came for.

## Keep it readable

One diagram answers one question. Two questions make two diagrams.

Around seven to ten nodes is the limit of what is read at a glance. Past that, collapse a
subsystem into one node and give it its own diagram.

Flow top-to-bottom or left-to-right consistently, and group related nodes with `subgraph` to make
the boundaries visible — a trust boundary, a service, a process.

Write labels a newcomer understands. `svc-ord-v2` means nothing outside the team that named it.

## Syntax

```mermaid
sequenceDiagram
    participant C as Client
    participant G as Gateway
    participant S as Order service
    participant D as Database

    C->>G: POST /orders
    G->>S: CreateOrder
    S->>D: BEGIN; insert order
    alt stock available
        D-->>S: ok
        S-->>G: 201 Created
    else out of stock
        D-->>S: constraint violation
        S-->>G: 409 Conflict
    end
    G-->>C: response
```

Quote a label containing punctuation: `A["Gateway (public)"]`. Use `-->` for a solid edge and
`-.->` for an asynchronous or optional one, consistently within a diagram.

## Verify

Render it before delivering. Mermaid fails on a single stray character, and an unrendered block
is worse than no diagram.

Then check it against the code once more: every node and edge should correspond to something you
actually read.
