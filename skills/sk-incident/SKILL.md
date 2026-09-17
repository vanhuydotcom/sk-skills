---
name: sk-incident
description: Triage a production problem under time pressure by establishing a timeline and blast radius, mitigating before root-causing, and capturing the evidence that will disappear. Use when something is broken or degraded in a live environment, an alert fires, or a customer reports behaviour that cannot be reproduced locally.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Incident triage

An incident is not a debugging session with more urgency. The goal order is different: **stop the
harm, then understand it.** A perfect diagnosis delivered after an hour of downtime is a worse
outcome than a rollback in five minutes and the diagnosis afterwards.

## 1. Establish the shape, in three questions

- **What is broken?** The observable symptom, in terms a user would recognise, not the alert name.
- **Who is affected?** Everyone, one tenant, one region, one endpoint, or requests with a
  particular input. The blast radius decides how aggressively to mitigate.
- **When did it start?** Find the first occurrence, not the first report. Users report late, and
  the gap between the two is where the cause lives.

Write these down as you learn them. An incident that runs long will involve someone who was not
there at the start.

## 2. Look for what changed

Most incidents are caused by a change. Before theorising, check what happened just before the
start time: a deploy, a config or feature-flag change, a migration, a dependency's incident, a
certificate expiry, a scheduled job, a traffic spike.

If the start time lines up with a deploy, treat that deploy as the cause until the evidence says
otherwise. Being wrong about this costs a rollback; being slow about it costs the outage.

## 3. Mitigate before root-causing

Choose the fastest action that stops the harm and is itself safe to reverse: roll back, disable
the flag, drain the bad instance, block the pathological input, scale the constrained resource.

Resist fixing forward under pressure. A patch written during an incident is unreviewed code
deployed to a system already in a bad state.

Say explicitly when the mitigation is in place and what it did to the symptom. An incident with
an unclear current status is an incident that stays open.

## 4. Capture evidence before it expires

Logs roll over, metrics lose resolution, pods restart, and a rollback destroys the state that
explains the failure. Before you clean up, save: the error with its full stack, a request
identifier that reaches across services, the query plan or slow query, the resource graphs across
the start time, and the exact version that was running.

A single trace or correlation identifier followed end to end across services is worth more than
any amount of aggregate log reading — it shows the actual path, in order, including the hop that
failed.

## Reading logs without drowning

Anchor on time first: narrow to a window around the start, before filtering by anything else.
Then filter to one request or one identifier and read that one story completely. Aggregate error
counts tell you the size of a problem; a single complete trace tells you its mechanism.

Distinguish the first error from the loudest. A downstream timeout repeated ten thousand times
drowns the one upstream error that caused it, and the first occurrence in the window is usually
closer to the cause.

## 5. Afterwards

Once the symptom is gone, the incident is not over — it is now a debugging problem with the
evidence you saved. Find the real cause, and fix it in a reviewed change.

Write down the timeline, what actually caused it, and the one control that would have caught it
earlier — a test, an alert, a validation, a safer deploy order. Skip blame; it changes nothing
about whether it recurs.

## Safety while investigating

Read-only until proven otherwise. Prefer queries with an explicit limit, and never run an
unscoped mutation against production data to "reset" something — that is how an incident becomes
a data-loss incident.
