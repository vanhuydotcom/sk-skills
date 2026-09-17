---
name: sk-react
description: Build and fix React and TypeScript components, covering state placement, effect dependencies, data fetching, list rendering and the re-render traps that cause stale or looping UI. Use when writing or changing a React component or hook, debugging stale data, an infinite render loop or a lost input, or reviewing frontend code.
license: MIT
compatibility: Assumes React 18 or later with function components and TypeScript.
metadata:
  author: huydv
  version: "1.0"
---

# React and TypeScript

## Put state in one place

Every value should have exactly one owner. Most React bugs are two copies of the same fact
disagreeing.

Derive instead of storing. If a value can be computed from props and state during render,
compute it — do not mirror it into `useState`, because the copy goes stale the moment its source
changes. `const total = items.reduce(...)` needs no state and can never be wrong.

State copied from a prop is the same bug with a longer fuse: the initial value of `useState` is
read once and ignored forever after. If the component must reset when a prop changes, give it a
`key` and let React remount it.

Lift state only as far as the nearest common parent that needs it. Lifting further makes every
sibling re-render on every keystroke.

## Effects

An effect synchronises with something outside React: a subscription, a timer, the document, an
imperative library. It is not the place to compute values or to respond to a click — the event
handler is.

The dependency array must list everything the effect reads. Omitting a value to stop a loop
freezes it at its first value and produces the stale-closure bug. If the effect loops because a
dependency is an object or function rebuilt every render, fix the dependency — `useCallback`,
`useMemo`, or move it out of the component — rather than deleting it from the array.

Return a cleanup function whenever the effect starts anything that can outlive it. Subscriptions,
timers and in-flight requests all need to stop when the component unmounts or the dependencies
change, and under StrictMode in development the effect runs twice specifically to expose a
missing cleanup.

An `async` function cannot be an effect body — it returns a promise, and React expects a cleanup
function. Declare the async work inside and call it.

## Data fetching

Prefer the project's data library over hand-rolled fetching in an effect; it already solves
caching, deduplication, retry and the race you are about to write.

When fetching by hand, handle all four states — loading, empty, error, success — and cancel the
request on cleanup. Two requests started in order can still resolve out of order, so either abort
the previous one or ignore a response that is no longer current.

Never swallow a rejection. An unhandled rejection in a handler or effect fails silently and the
UI simply stops updating.

## Rendering

Key lists by a stable identity from the data. Index keys are correct only for a list that never
reorders, inserts or deletes; when it does, React reuses the wrong DOM node and inputs keep the
previous row's value.

Reach for `memo`, `useMemo` and `useCallback` after measuring with the profiler. Applied
everywhere by default they add allocation and dependency arrays that go wrong, and they solve
nothing when the real cost is a parent re-rendering the whole tree.

Never call a hook conditionally, in a loop, or after an early return. The order must be identical
on every render.

## TypeScript

Treat `any` and a type assertion as an unresolved question, not a fix. Both silence the compiler
at exactly the place it had something useful to say. When a type is genuinely unknown, use
`unknown` and narrow it.

Type what crosses a boundary: API responses, form values, URL parameters. Data from the network
is not the type you declared until something checks it, so validate at the edge and let the rest
of the app trust the result.

## Verify

A green build proves less than it looks like. Many projects configure the framework to ignore
lint and type errors during build, so check the config before treating the build as evidence, and
run the type check and linter explicitly.

Then use the component: the empty state, the error state, a slow network, and a second rapid
interaction before the first finishes.
