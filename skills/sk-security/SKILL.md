---
name: sk-security
description: Review code for real security defects — broken access control, injection, secret exposure, unsafe deserialization and vulnerable dependencies — starting from what the code actually protects. Use when reviewing security-sensitive changes, auditing a service, handling authentication, authorization or payments, or triaging a reported vulnerability.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Security review

Start by naming what this code holds and who must not reach it. A finding that does not map to an
asset and an attacker is noise, and a review full of noise gets ignored — including the one
finding that mattered.

## Threat model in four questions

1. What does this store, move, or authorise? Money, personal data, credentials, another tenant's
   records, the ability to act as someone else.
2. Who can reach it? Anonymous internet, any authenticated user, a user of another tenant, an
   internal service, an operator.
3. What is the worst single request? Not the worst imaginable breach — the worst thing one
   crafted call achieves.
4. What already stops it, and is that control on the path an attacker uses, or only on the path
   the UI uses?

## Access control

This is where the real defects are, and it is the category a scanner cannot find.

Check authorization at the point that performs the action, not in the handler that usually calls
it. A check in the UI, in middleware that only covers some routes, or in a service the attacker
can bypass by calling a sibling endpoint is not a control.

For every query that reads or writes a scoped resource, confirm the owner or tenant predicate is
present. An object identifier taken from the request and used directly in a lookup lets any
authenticated user read any row by changing the number.

Confirm the identity is derived from the verified session or token, never from a request body,
header or parameter the caller controls. Check the same for the acting-as identity when a user
can operate on behalf of another account, because the obvious accessor is often the wrong one.

Verify that a privileged operation checks the privilege on every path that reaches it, including
batch endpoints, admin tooling and internal RPC.

## Input and injection

Parameterise every database query. Concatenating input into SQL is the defect; escaping it by
hand is the same defect with extra steps. The same rule applies to shell commands, template
rendering, LDAP filters and constructed file paths.

Validate at the trust boundary against an allow-list of what is acceptable, not a deny-list of
what is known bad. Deny-lists lose to encoding.

Treat a path built from user input as hostile until it is resolved and confirmed to sit inside
the intended directory.

Never deserialize attacker-controlled data into a format that can instantiate arbitrary types.

## Secrets

Look for credentials in code, config committed to the repository, test fixtures, log statements,
error messages returned to the caller, and URLs. A token in a query string is recorded by every
proxy and access log on the path.

Read secrets from the environment or a secret manager. If one has been committed, rotate it —
removing it from the working tree does not unpublish it.

Check what the error handler returns to an unauthenticated caller. A stack trace, a driver error,
or a distinction between "no such user" and "wrong password" is a free map of the system.

## Dependencies and transport

Run the ecosystem's audit tool and triage by whether the vulnerable path is actually reachable,
not by the advisory's severity alone.

Confirm TLS verification is enabled — a disabled certificate check left over from debugging is
common and invisible in normal operation.

Check that authentication tokens have a bounded lifetime and that logout or revocation actually
invalidates them server-side.

## Reporting

Rank by exploitability against this system, not by category name. For each finding, state the
asset, the request that reaches it, and the minimal fix.

Say explicitly what you checked and found sound. A review that lists only problems leaves the
reader unable to tell thorough coverage from a quick skim.

Do not report a theoretical weakness in code that holds nothing, and do not escalate a defence-
in-depth suggestion into a vulnerability. Call it what it is.
