---
name: sk-python
description: Write and debug Python with attention to the traps that produce silent wrong behaviour — mutable defaults, late-binding closures, shallow copies, swallowed exceptions — plus typing, environment and packaging with uv or venv, and pytest structure. Use when writing a Python script, service or library, setting up a Python project, or debugging behaviour that looks impossible.
license: MIT
compatibility: Targets Python 3.10+; packaging guidance assumes pyproject.toml with uv or pip.
metadata:
  author: huydv
  version: "1.0"
---

# Python

Python is easy to write and easy to be subtly wrong in. This covers the traps that fail silently
and the project setup that avoids a broken environment.

## Traps that fail silently

**Mutable default arguments** are evaluated once, at definition, and shared by every call:

```python
def add(item, bucket=[]):   # wrong: bucket persists across calls
def add(item, bucket=None): # right
    bucket = [] if bucket is None else bucket
```

**Closures bind late.** A lambda created in a loop captures the variable, not its value, so every
one of them sees the final value. Bind it explicitly with a default argument, or use
`functools.partial`.

**`is` is identity, not equality.** It works for `None`, `True` and `False`, and for nothing else.
It appears to work for small integers and short strings because those are interned, which is
exactly what makes the bug survive testing.

**Copies are shallow.** `list(xs)`, `xs[:]` and `dict(d)` copy the container and share the
elements. Nested structures need `copy.deepcopy`.

**A bare `except:` catches everything**, including `KeyboardInterrupt` and `SystemExit`. Catch the
specific exception, and never write `except Exception: pass` — if it is truly ignorable, log it
and say why.

**Integer division and float equality.** `/` always produces a float; `//` floors toward negative
infinity, so `-7 // 2` is `-4`. Never compare floats with `==`; use `math.isclose`, or `Decimal`
for money.

**Iterating a collection while mutating it** skips elements. Build a new list, or iterate a copy.

**Generators are consumed once.** A second pass over the same generator yields nothing, which
reads as an empty result rather than an error.

## Environment and packaging

Never install into the system interpreter. Create a virtual environment per project and activate
it, or let `uv` manage it:

```bash
uv venv && uv pip install -e ".[dev]"     # or: python -m venv .venv
```

Declare dependencies in `pyproject.toml`, and commit a lock file so the environment is
reproducible. A `requirements.txt` with unpinned versions is not reproducible and will break on a
future machine.

Pin the Python version the project supports and state it in `pyproject.toml`. Behaviour differs
across minor versions more than people expect.

When something imports in one place and not another, the cause is almost always the interpreter
rather than the code. Check `which python` and `python -c "import sys; print(sys.executable)"`
before debugging the import.

## Types

Annotate function signatures — parameters and return. The body rarely needs annotation; the
boundary always does, because that is what other code depends on.

Run a type checker in CI. Annotations that nothing verifies drift out of date and become
misleading documentation.

Use `X | None` rather than a bare optional-by-convention, and make the optionality visible in the
signature. Prefer specific types over `Any`; when the type is genuinely unknown, use `unknown`'s
equivalent — `object` — and narrow it, so the checker forces the narrowing.

For structured data prefer a `dataclass`, or a validating model at the boundary where data
arrives from outside. A dictionary of strings passed between functions loses every guarantee at
the first typo.

## Idioms that matter

Use a comprehension when it maps or filters, and a loop when it does anything else. A
comprehension with a side effect or three clauses is harder to read than the loop it replaced.

Use `pathlib.Path` rather than string paths, and a context manager for anything that must be
closed — files, connections, locks, temporary directories.

Yield from a generator instead of building a list when the input is large or unbounded; this is
the difference between a script that streams and one that exhausts memory.

Use `enumerate`, `zip`, and `dict.get` with a default instead of index arithmetic and membership
checks. They are faster and they remove a class of off-by-one.

## Tests

`pytest`, with plain `assert`. Use `@pytest.mark.parametrize` for table-driven cases rather than
a loop inside one test, so each case reports separately.

Put shared setup in a fixture with the narrowest scope that works. A session-scoped fixture that
holds mutable state leaks between tests and produces order-dependent failures.

Assert the specific exception with `pytest.raises`, including the message when it matters.

## Performance, when it matters

Measure before optimising — `time.perf_counter` for a rough number, `cProfile` for where it goes.

The usual win is moving work out of the interpreter: a built-in, a comprehension, `str.join`
instead of repeated concatenation, a `set` or `dict` lookup instead of scanning a list, or a
vectorised library call for numeric work.

For I/O-bound concurrency use `asyncio` or threads; for CPU-bound work use processes, because the
global interpreter lock means threads will not help.
