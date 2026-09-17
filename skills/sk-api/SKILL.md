---
name: sk-api
description: Design and change API contracts (REST, gRPC, protobuf, events) so existing callers keep working, covering resource and method shape, error models, pagination, versioning and the deploy order a breaking change requires. Use when adding or altering an endpoint, message or event, or when judging whether a proposed change breaks a consumer.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# API contracts

A contract is a promise to code you do not control and cannot fix. That is what makes API changes
different from internal refactoring: the cost of getting it wrong is paid by someone else, at a
time you do not choose.

## Design

Name resources as nouns and let the method carry the verb. Model the thing, not the screen that
currently displays it — a payload shaped around today's UI becomes wrong at the next redesign.

Be deliberate about what you expose. Every field you return is a field you must keep returning.
Internal identifiers, row versions and implementation details leak your schema into the caller's
code and freeze it there.

Make operations idempotent where the caller may retry, which is any operation reachable over a
network. Give the caller an idempotency key for anything that creates or charges, so a retry
after a timeout cannot double it.

Return a consistent error model: a stable machine-readable code, a human-readable message, and
the field a validation failure refers to. Callers branch on the code, so it is part of the
contract — changing a code is a breaking change even though the shape is unchanged.

Paginate every list, from the first version. An endpoint that returns everything works until the
table grows and then fails for the customer with the most data. Prefer a cursor over an offset
when rows are inserted concurrently.

## What breaks a caller

Breaking, whatever the schema language allows:

- Removing or renaming a field, an endpoint, a method, or an enum value.
- Making an optional request field required, or narrowing what a field accepts.
- Changing a type, including integer to string and a single value to a list.
- Changing the meaning of an existing field while keeping its name and type — the worst kind,
  because nothing fails loudly and the data is quietly wrong.
- Adding a new required field to a request.
- Changing an error code, or an HTTP status, for an existing condition.
- Tightening a default, or changing what happens when a field is omitted.

Safe: adding an optional request field, adding a response field, adding a new endpoint or method,
adding an enum value **only if** every consumer already tolerates unknown values — verify that
rather than assuming it.

In protobuf, never reuse or renumber a field tag, and reserve the tag and the name when you
remove a field. A reused tag decodes old data into the new field and corrupts it silently.

## Changing a contract safely

Add before you remove, and let both work for at least one release:

1. Add the new field or method alongside the old one.
2. Write both, read the new one with a fallback to the old.
3. Migrate the consumers, and confirm each one has moved.
4. Remove the old path in a later release.

Version when the resource genuinely changes meaning, not for every addition. A version per change
multiplies the surface you must keep alive.

## Deploy order

Generated code and servers deploy separately, and the gap is where the outages live. Roll out the
side that tolerates both shapes first: consumers that accept the new field before producers emit
it, producers that accept the new request before callers send it.

When a schema is shared through a gateway, a proxy, or generated clients, every component in the
path needs regenerating and redeploying. A field added to the service but not to the layer in
front of it disappears before it reaches the caller, and the service's own tests will not notice.

## Verify

Check the actual consumers before changing a shape — grep the callers rather than trusting the
contract's documentation.

Test the contract itself: a test that asserts the serialized shape catches an accidental rename
that a unit test on the handler will miss entirely.
