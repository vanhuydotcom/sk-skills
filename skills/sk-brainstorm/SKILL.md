---
name: sk-brainstorm
description: Pressure-test a raw idea before any plan exists, by interrogating the actual problem, challenging the premise, generating genuinely different approaches and naming what would make each one fail. Use when a request is vague, when the proposed solution may not fit the problem, when several designs seem plausible, or when the outcome and acceptance criteria cannot yet be stated.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Brainstorm

This is the divergent step, and its whole value is resisting the first plausible answer. Once the
outcome and the approach are settled, stop and plan.

Skip this entirely when the request is clear and there is one obvious way to do it. Applying it
to a two-line fix is theatre.

## 1. Find the actual problem

The stated request is a proposed solution. Work backwards to the problem it is meant to solve,
because the problem often has a cheaper answer than the one being asked for.

Ask, in this order:

- What goes wrong today, concretely, and to whom? A problem nobody can point at is a preference.
- How often, and what does it cost when it happens?
- What happens if nothing is built? This is the honest baseline, and sometimes it is acceptable.
- What has already been tried, and why did it not hold?
- What does success look like six months out — what will be observably different?

Ask **one question at a time** and use the answer to choose the next one. A list of eight
questions gets eight shallow answers, and it hands the synthesis work back to the person who
asked you for help.

Ask only what you cannot discover. Read the code, the data and the running system first; arriving
with "the current implementation does X, is that the part that hurts?" is worth more than an open
question.

## 2. Challenge the premise

This is the highest-value move in the whole skill, and the one that requires actual nerve.

Say so plainly when the request looks like the wrong solution, when it solves a symptom, when the
cost clearly exceeds the pain, or when the real constraint lies somewhere the request does not
touch. State it once, in a sentence or two, with the reason.

Then, if the person reaffirms it, treat that as the decision, say so, and proceed with the full
request. Their context is not all in the room, and repeating an objection after it has been heard
is not diligence.

Agreeing with everything is the failure mode here. If you have raised no objection and named no
risk, you have not brainstormed — you have transcribed.

## 3. Generate options that actually differ

Three variants of the same idea is one option wearing three hats. Force real distance by reaching
for different *mechanisms*:

- **Do nothing**, or solve it with process rather than code. Always include it; it is the
  baseline everything else is measured against.
- **The smallest thing that could work** — the version you could ship this week and withdraw next
  week.
- **Buy, adopt, or reuse** something that exists instead of building.
- **Change the constraint** rather than working within it. Often the cheapest answer is upstream
  of where the problem appears.
- **The thorough version**, so the cost of doing it properly is visible and can be chosen or
  declined deliberately.

Never present an option you would refuse to build. A decoy exists to make another look good, and
it wastes the reader's judgement.

## 4. Examine each honestly

For each surviving option, state four things:

```
<Option>
  Buys       <what it actually gets you>
  Costs      <effort, complexity, operational burden, what it commits you to>
  Fails when <the condition that breaks it — every option has one>
  Makes hard <what becomes expensive later if you choose this>
```

The `Fails when` row is the point of the exercise. An option with no named failure condition has
not been examined, and the failure you did not name is the one you will meet.

Run a pre-mortem on the leading candidate: it is six months later and this was a mistake — what
happened? The answer usually names a risk that the optimistic framing hid.

## 5. Converge

Recommend one, and say why in a sentence. A survey with no recommendation pushes the decision
back to the person who asked, which is the thing they were trying to avoid.

Name the assumption your recommendation rests on, and what you would choose instead if it turned
out false. That is what lets someone with more context overrule you correctly.

Prefer the reversible option when the evidence is thin. Being able to withdraw a decision cheaply
is worth more than being right about it in advance.

## Hand off

Brainstorming is finished when these four can be written down. This is exactly what the planning
step needs as input:

```
Outcome              <what is true afterwards, as observable behaviour>
Constraints          <what cannot change>
Non-goals            <the tempting adjacent work that is excluded>
Acceptance criteria  <the checks that decide it is done, each able to fail>
```

If they cannot be written, brainstorming is not finished — say which one is still open and what
would settle it.

## Do not

- Do not produce a long list of ideas. Three real options beat ten variations.
- Do not converge in the first reply. The value is in the divergence, and it is lost the moment
  you commit early.
- Do not present preference as evidence. Say when a judgement is taste rather than analysis.
