---
name: explain
description: Explain a problem, a bug, a design gap or a proposal with named actors, a numbered timeline and one question. Use it when the user asks to explain something, to walk through something, why something happens, or what happens if. Use it in a debugging, exploration, review or planning discussion.
---

# /explain

Usage: `/explain [$ARGUMENTS]`

Explain one problem through a concrete example and a numbered timeline. Never
through a wall of text.

`$ARGUMENTS` names the topic. With no arguments, apply the format to the topic
of the current turn.

This skill shapes your message. It starts no engine and it needs no script.
Read the files you need, then write the message. Exactly one rule writes to
disk: `Record a ruling before you raise the next item`. Nothing else writes.

## When to use

Use it for any of these:

- The user asks you to explain a problem, an issue, a bug or a behaviour.
- The user asks to walk through something, why something happens, or what
  happens if.
- You report a bug, a review finding, a design gap or a race condition.
- You propose a change to code, to a document or to a design.
- You answer a question in a debugging, exploration or planning discussion.

Skip it for a one-line factual answer, a command result, or a file listing. The
format costs more than it returns when the answer fits in one sentence.

## Message mode

Pick one mode per message.

- **Explanation.** Write the full template below.
- **Restatement check.** The user restates the problem in their own words.
  Open with a short bulleted list that confirms or corrects each part. Add one
  sentence that names what the case is not, only when the restatement is wrong.
  This list replaces the conclusion. Then continue with the sections that the
  answer still needs.
- **Ruling acknowledgement.** The user answers the question. Record the ruling
  first. Then raise the next open item as a new explanation message. Report that
  no item remains when none remains, and stop.

## Message template

Write the sections in this order. Never reorder them. Section 1 and section 7
are mandatory. Every other section carries an inclusion criterion. Include the
section when its criterion holds. Skip it when the criterion fails.

1. **Conclusion.** Mandatory. One or two sentences. State the answer or the
   recommendation. No preamble, no restatement of the question.
2. **Existing behaviour.** Include it when the reader cannot follow section 3
   without the mechanism, and its steps differ from section 3. State the
   current logic, code, document or behaviour as a numbered list of sequential
   steps.
3. **Timeline without the fix.** Include it when the message names a failure, a
   bug, a gap or a cost. A numbered list of 4 to 8 steps. Show what happens
   today and where it breaks. The last step names the failure in plain words.
4. **Timeline with the fix.** Include it when the message proposes a fix. Skip
   it when the message diagnoses only. Name the divergence step first, for
   example `diverges at step 5`. Rewrite only the steps from the divergence
   onward.
5. **What changes.** Include it when the message proposes a change to a file or
   to a component. A bulleted list of the concrete changes. Each bullet names
   one file or one component.
6. **Recommendation and alternatives.** Include it when more than one option
   exists. State the recommended option first, with its cost. Then give each
   alternative one or two lines, with what it is and what it costs.
7. **Close.** Mandatory. One ruling question when an open item exists. The
   single next step and no question when no item is open. Nothing after it.

Section 5 and section 6 together are the proposal.

A proposal that fixes no bug still uses section 3 and section 4. The fix is the
proposed change. The failure step names the cost of the status quo.

A walk-through that names no failure uses one timeline. Name it `Timeline`, end
it at the outcome, and skip section 4 and section 5.

An uncertain diagnosis names the unverified step inside section 3. State what
evidence settles that step, then skip section 4 until the evidence arrives.

## Rules

### Names

- **Use concrete names, never abstract roles.** Take the names from the
  vocabulary examples of the project, for example the objective
  `Add password reset`, the worker binding `tdd-main`, the harness
  `claude-code`, pull request 42. Read the documents and the identifiers at
  hand to find them. Reuse one small invented set when the project gives no
  example names. Never write `the dependent node` when `Add recovery codes` is
  available.
- **Name yourself in the recommendation** when the instructions of the user
  give you a name, for example `Aelita recommends the stored key because ...`.

### Timelines

- **Keep one step to one or two short sentences.**
- **Bound a full timeline to 4 to 8 steps.** This covers section 2, section 3
  and every branch timeline. More than 8 steps means the scope is too large.
  Split the message, or raise the level of the steps.
- **Give the fixed timeline no minimum.** It starts at the divergence step and
  it holds the steps from there.
- **Match the numbers to the moments.** The same number names the same moment
  in every timeline of the message.
- **Number an inserted step with a letter suffix**, for example `5a`. A step
  that the fix removes keeps its number and states `removed`.
- **Rewrite every step when the divergence is step 1.** That is not a
  repetition.
- **Split a branch into two timelines.** A branch is a second reading of the
  scenario, or an option that changes the timeline. Write one complete pair per
  branch: the branch label, then its failing timeline, then its fixed timeline.
  Never nest an if-else inside one list. A bullet duplicated across two
  timelines is better than a branch inside one timeline.
- **Give an alternative of section 6 no timeline.** Promote it to a branch when
  the user asks for its timeline.

### The proposal

- **Quote the exact edit.** Quote the old sentence and the new sentence for
  text. Name the exact symbol, function or line and state the old behaviour and
  the new behaviour for code. State `add` when there is no old text, and state
  `delete` when there is no new text.
- **Prefer forbidding to mechanism.** A configuration change creates an edge
  case. Prefer to forbid that configuration change over a mechanism that
  handles the edge case. Add the mechanism only when the configuration change
  is required, and state why.
- **Never present a bare option name.** Every option states what it is and what
  it costs. This covers the recommended option.

### The conversation

- **Raise one open item per message.** Several open items need several
  messages. Raise the first one, then say that the next one follows after the
  answer. Never batch two rulings into one question. One question that hides
  two decisions counts as two rulings. An answer can change the scope of the
  next item.
- **Ask no question when no ruling is open.** Close with the single next step
  instead.
- **Record a ruling before you raise the next item.** Write it to the decision
  register or the handoff file of the project. Quote the ruling back in one
  line when the project holds no such file.
- **Present a review finding in this format.** One bullet per item:
  `<B1/S1> - status:<FIXED/OPEN> - action:<YES/NO> - <name> - <description> -
  fix:<recommended change> - why:<reason>`. `B` is a blocker and `S` is a
  suggestion. The global instructions of the user own this format, and they win
  on any difference.

### Style

These rules govern the message you write. They do not govern quoted text, a
file name or a code identifier, which stay exact.

- Write short sentences, about 20 words. Use simple tenses and active voice.
  State one idea per sentence.
- Use no em-dash and no parenthetical aside. Split the sentence instead.
- Use a bold lead-in on a paragraph and on a bullet. Open a change bullet with
  its file name in backticks, which serves as the lead-in.
- Mark every section with a bold lead-in. The conclusion is the exception: it
  opens the message and it carries no label.
- Add a header only when the message passes 500 words. Use at most three
  headers.
- Write no flattery and no filler.
- Put an enumeration, a line reference and a measurement inside a list. An
  identifier that holds a number, for example order 4471, is a name and stays
  in prose.

## Worked example

A message for a bug, with the sections that the topic needs:

```
`charge-retry` charges Mara Feld twice for order 4471 because it generates a
new idempotency key instead of the key that `checkout-api` stored. Aelita
recommends that `charge-retry` reads the stored key. It costs one query.

**Timeline without the fix**

1. Mara Feld submits order 4471. `checkout-api` stores `chargeKey` on the order.
2. `checkout-api` sends the charge to `stripe-live` with `chargeKey`.
3. `stripe-live` charges the card. The network drops the response.
4. `checkout-api` leaves order 4471 in state `unpaid`.
5. `charge-retry` reads order 4471 after 30 seconds. It generates a new key.
6. `charge-retry` sends the second charge. `stripe-live` sees a new key and
   charges the card again. Mara Feld pays twice for order 4471.

**Timeline with the fix**, diverges at step 5.

5. `charge-retry` reads order 4471 after 30 seconds. It reads `chargeKey`.
6. `charge-retry` sends the second charge with `chargeKey`. `stripe-live`
   matches the key and returns the first charge. Mara Feld pays once.

**What changes**

- `services/checkout/retry.ts` old behaviour: `buildCharge` calls
  `randomKey()` per attempt. New behaviour: `buildCharge` reads
  `order.chargeKey`.
- `docs/payments.md` old sentence: `The retry worker generates an idempotency
  key per attempt.` New sentence: `The retry worker reuses the idempotency key
  of the order.`

**Recommendation.** Aelita recommends the stored key. It costs one query on the
order row and no new service.

**Alternative: a lock per order.** A lock service blocks the second attempt. It
adds a service and a lock timeout failure mode.

**Alternative: a charge lookup before each retry.** It needs no schema change.
It still double-charges when `stripe-live` reports the charge late.

**Question.** Does `charge-retry` fail the attempt when `chargeKey` is absent,
or does it write a key and continue?
```

## Do not

- Do not write a wall of text. A paragraph that holds a sequence is a timeline.
- Do not name an abstract role. `the dependent node` and `the caller` are
  banned when a concrete name exists.
- Do not nest a branch inside a timeline step. Write a second timeline.
- Do not put two rulings in one question.
- Do not name an option without its description and its cost.
- Do not repeat an unchanged step in the fixed timeline. Name the divergence
  step, then rewrite from there. Repeat a step only when clarity needs it.
- Do not claim a divergence step that is later than the first changed step.
- Do not add a mechanism for an edge case that a forbidden configuration
  removes.
- Do not open with a preamble, a summary of the request, or praise.
