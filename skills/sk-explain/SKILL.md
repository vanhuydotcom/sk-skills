---
name: sk-explain
description: Explain a concept, a piece of code, a system or an error in terms grounded in the actual source, building the mental model first and citing exact paths as evidence. Use when asked how something works, why something behaves as it does, what an error means, or to bring someone up to speed on an unfamiliar area.
license: MIT
metadata:
  author: huydv
  version: "1.0"
---

# Explain

An explanation succeeds when the listener can predict what the system will do next. Recalling
your summary is not the goal; being able to reason without you is.

## Ground it in the source

Read the code before explaining it. A plausible explanation of how a system of this kind usually
works is worse than no answer, because it is confidently wrong in exactly the places that matter.

Cite the evidence as you go, with `path:line`. This lets the reader verify you, and it keeps you
honest about the difference between what you read and what you assumed.

Say which parts you did not check. "The retry lives in the client wrapper; I have not read how it
chooses the backoff" is a useful, complete answer. Hedged vagueness across the whole explanation
is not.

## Build the model before the detail

Answer in this order, and stop as soon as the question is answered:

1. **The one-sentence answer.** What it does, or why it behaved that way.
2. **The mental model.** The two or three moving parts and how they relate. This is the part the
   reader keeps.
3. **The path through the code.** What calls what, where the decision is made, where the data
   goes.
4. **The detail.** Only what the question needs.

Most explanations fail by starting at step 3 and never reaching step 2. A reader who has the
model can read the code themselves; a reader who has the call chain and no model cannot.

## Make it concrete

Trace one real example end to end rather than describing the general case. A single request, with
actual values, teaches the shape faster than an abstract description of all requests.

Explain the *why* behind anything that looks arbitrary. A strange-looking guard usually encodes a
failure someone already suffered, and knowing that converts it from noise into information.

Name the thing that is genuinely surprising, and warn about the trap the reader is heading for.
That is often the most valuable sentence in the answer.

## Use analogies carefully

An analogy is a loan against precision. Use one to get the reader moving, then say where it
breaks before they lean on it. An unqualified analogy becomes the reader's model, including the
parts that are wrong.

## Errors

For an error, answer four things: what the message literally means, what in this codebase
produces it, why it is happening in this case, and what to check first. The last one is what the
reader needs most.

Point at the line that raises it. An error explained in general terms, without locating it, leaves
the reader exactly where they started.

## Calibrate

Match the depth to what the reader already knows, and ask if that is genuinely unclear rather
than guessing.

Do not explain what was not asked. A complete tour of the module when the question was about one
function buries the answer.
