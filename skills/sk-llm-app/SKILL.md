---
name: sk-llm-app
description: Build features on top of language models — prompting, structured output, retrieval, tool use and agent loops — with an evaluation set that decides whether changes help, and controls for cost, latency and prompt injection. Use when adding an LLM-backed feature, building RAG or an agent, debugging inconsistent model output, or deciding whether a model is the right tool at all.
license: MIT
compatibility: Provider-agnostic; examples assume a chat completion API with tool calling.
metadata:
  author: huydv
  version: "1.0"
---

# LLM applications

The discipline that separates a working feature from a demo is measurement. Model output is
non-deterministic, so without an evaluation set every change is an opinion, and the usual failure
is a system that is tuned by vibes and degrades silently.

## Start with the evaluation set

Before writing the prompt, collect 20 to 50 real inputs with the output you would accept. This
takes an hour and it is the only thing that will tell you whether tomorrow's prompt change helped
or quietly broke a case that used to work.

Grade automatically where the answer is checkable: exact match, valid JSON against a schema, a
required field present, a number within tolerance, a retrieved document among the expected ones.
Reserve human or model-based judging for open-ended text.

Judging with a model is useful but biased — it prefers long, confident, similar-sounding answers.
Give the judge a rubric and concrete criteria rather than "is this good", and spot-check its
verdicts against your own before trusting it.

Run the set on every prompt or model change and compare. A change that improves your three
favourite examples and regresses six others is a regression.

## Prompting

Say exactly what you want, in the order it should be done. Vague instructions produce averaged,
hedged output because that is the safest completion.

Two or three examples of the exact input-to-output mapping outperform a paragraph describing it,
especially for format. Show an edge case among them.

Ask for structured output through the provider's schema or tool-calling mechanism rather than
asking for JSON in prose, and validate what comes back before using it. Handle the parse failure
explicitly; do not assume it cannot happen.

Tell the model what to do when it does not know — return a specific marker, an empty result, a
low confidence. Left unspecified, a model produces a plausible answer, which is the worst
possible failure because it is indistinguishable from a correct one.

Put the stable, reusable part of the prompt first so it can be cached, and the request-specific
part last.

## Retrieval

Retrieval quality is almost the whole problem. When a RAG answer is wrong, the cause is usually
that the right document never reached the model, so measure retrieval on its own — did the
correct chunk appear in the top k — before touching the generation prompt.

Chunk at semantic boundaries such as sections or paragraphs rather than fixed character counts,
and keep the document title and section heading with the chunk. An orphaned paragraph is
unretrievable and unciteable.

Combine keyword and vector search. Pure vector search reliably misses exact identifiers, error
codes, product names and numbers — which is often what the user actually typed.

Retrieve widely, then rerank down to the few chunks you send. Filling the context with marginal
matches lowers answer quality rather than raising it.

Have the model cite which chunk it used, and show that to the user. It is the cheapest
verification available and it makes hallucination visible.

## Agents and tools

Most tasks do not need an agent. A single call, or a fixed chain of two or three, is more
reliable, cheaper, easier to debug and easier to evaluate. Use a loop only when the steps genuinely
depend on intermediate results in a way you cannot enumerate in advance.

When you do:

- Give few tools with unambiguous names and descriptions. Overlapping tools produce wrong
  choices, and the description is the only thing the model sees.
- Bound the loop — a maximum number of iterations, a cost ceiling, a wall-clock timeout. An
  unbounded loop is an unbounded bill.
- Return errors to the model as text it can act on. A raw stack trace wastes a turn.
- Make tools idempotent where possible, and require confirmation for anything destructive or
  outward-facing.
- Log every step. An agent failure is unreadable without the full trace of what it saw and chose.

## Cost and latency

Measure tokens per request before optimising. The cost is usually a context that grew by
accretion, not the model tier.

Route by difficulty: a small model for classification, extraction and routing; a large one only
where reasoning quality actually changes the outcome. Validate the split against your evaluation
set rather than assuming.

Cache the stable prompt prefix, and cache whole responses for repeated identical inputs.

Stream when a person is waiting. Perceived latency is what they experience, and first-token time
matters more than total time.

## Safety

Treat everything the model reads as untrusted data, never as instructions. A retrieved document,
a web page, a file, a tool result and a user message can all contain text directed at the model,
and a system that acts on it will be made to act against its user.

Keep the authority outside the model. Check permissions in your own code before executing a tool
call; a model that decides its own authorisation has none.

Never put secrets in a prompt. Validate and constrain any model-produced value before it reaches
a query, a shell, a file path or a URL.

## Do not

- Do not ship without an evaluation set, and do not tune prompts by looking at one example.
- Do not treat model output as verified. Check what is checkable.
- Do not add retrieval, agents or fine-tuning before a plain prompt has failed a measurement.
