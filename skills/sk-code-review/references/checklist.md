# Per-language review specifics

Load this when the diff touches one of these languages. It lists the defects that are easy to
miss on a first read, not general advice.

## Go

- `err` assigned and then shadowed by a later `:=`, so the first error is silently dropped.
- `defer` inside a loop: the close runs at function exit, not iteration exit.
- A loop variable captured by a goroutine. Fixed by the language in Go 1.22; still a defect on
  every older toolchain, so check `go.mod` before dismissing it.
- `context.Context` stored in a struct, or a request context passed to work that outlives the
  request. The context is cancelled when the handler returns.
- A nil map written to. Reading a nil map is fine; writing panics.
- A slice retained from a larger backing array, keeping the whole array alive.
- `rows.Err()` unchecked after a `sql.Rows` loop, so a mid-iteration failure reads as success.
- An interface holding a nil pointer is not `== nil`.
- Errors compared with `==` where the callee wraps with `%w`; needs `errors.Is` / `errors.As`.

## TypeScript and React

- `any` or a type assertion introduced to silence an error the compiler was right about.
- A `useEffect` whose dependency array omits a value it reads, or includes an object literal
  rebuilt every render.
- State derived from props in `useState`, which then goes stale when the prop changes.
- An `async` function passed where a cleanup function is expected.
- A promise rejection with no `catch`, inside an event handler or effect.
- A list keyed by array index where the list reorders.
- A `next build` that passes proves neither lint nor types when the project disables those
  checks in its config — verify the config before treating a green build as evidence.

## SQL and migrations

- No rollback path, or a rollback that cannot undo the forward step.
- `UPDATE` or `DELETE` with no `WHERE`, or a `WHERE` that omits the tenancy column.
- An index added without `CONCURRENTLY` on a table large enough to matter.
- A `NOT NULL` column added without a default over existing rows.
- A type widened in the database but not in the application's scan target.
