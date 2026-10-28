---
name: explain
description: Explain a problem, a bug, a design gap or a proposal with named actors, a numbered timeline and one question. Use it when the user asks to explain something, to walk through something, why something happens, or what happens if. Use it in a debugging, exploration, review or planning discussion.
---

# /explain

Usage: `/explain [$ARGUMENTS]`

Explain one problem through a concrete example and a numbered timeline. Never
through a wall of text. A paragraph that holds a sequence is a timeline.

`$ARGUMENTS` names the topic. With no arguments, apply the format to the topic
of the current turn.

Read the files that hold the facts before you write any message, in every
mode. Write to disk only to record a ruling.

Skip the format for a one-line factual answer, a command result, or a file
listing. Give that answer in plain prose.

## Message mode

Pick one mode per message.

- **Explanation.** Write the full template below.
- **Restatement check.** The user restates the problem in their own words.
  Open with a short bulleted list that confirms or corrects each part. When the
  restatement is wrong, add one sentence that names what the case is not. The
  list replaces the conclusion. Then add the sections that the answer needs.
- **Ruling acknowledgement.** The user answers the question. Record the ruling
  first. Then raise the next open item as a new explanation message. Report that
  no item remains when none remains, and stop.

## Message template

Write the sections in this order. Section 1 and section 7 are mandatory.
Include every other section only when its criterion holds.

1. **Conclusion.** One or two sentences. State the answer or the
   recommendation. No preamble, no restatement of the question, no praise.
2. **Existing behaviour.** Include it when the reader cannot follow section 3
   without the mechanism, and its steps differ from section 3. State the
   current logic, code, document or behaviour as numbered steps.
3. **Timeline without the fix.** Include it when the message names a failure, a
   bug, a gap or a cost. Show what happens today and where it breaks. The last
   step names the failure in plain words.
4. **Timeline with the fix.** Include it when the message proposes a fix. Name
   the divergence step first, for example `diverges at step 5`. It is the first
   step that changes. Rewrite only the steps from there.
5. **What changes.** Include it when the message proposes a change to a file or
   to a component. One bullet per file or component.
6. **Recommendation and alternatives.** Include it when the message proposes a
   change. State the recommended option first: what it is, why, its cost and
   what can break. Then add each alternative that the self-debate keeps. An
   alternative is a correct option with a different trade-off, ranked below
   the recommendation for this task. Give it one or two lines: what it is,
   where it beats the recommendation, its cost, and the task condition that
   makes it the primary.
7. **Close.** One ruling question when an open item exists. The question asks
   the reader to approve the recommendation or to pick an alternative. Never
   ask for a fact that you can check. With no open item, state the single next
   step and ask no question. Nothing after the close.

- A proposal that fixes no bug still uses section 3 and section 4. The fix is
  the proposed change. The failure step names the cost of the status quo.
- A walk-through that names no failure uses one timeline. Name it `Timeline`,
  end it at the outcome, and skip section 4 and section 5.
- An uncertain diagnosis names the unverified step inside section 3. State what
  evidence settles that step, then skip section 4 until the evidence arrives.

## Timelines

- **Keep one step to one or two short sentences.**
- **Bound a full timeline to 4 to 8 steps.** This covers section 2, section 3
  and every branch timeline. Above 8 steps, split the message.
- **Match the numbers to the moments.** The same number names the same moment
  in every timeline of the message.
- **Split a branch into two timelines.** A branch is a second reading of the
  scenario, or an option that changes the timeline. Write one complete pair per
  branch: the branch label, then its failing timeline, then its fixed timeline.
  Never nest an if-else inside one list.
- **Give an alternative no timeline.** Promote it to a branch when the user
  asks for its timeline.

## Self-debate

Run these steps before you write a recommendation. The message shows the
result, not the debate.

1. Ask why the thing exists. Name the root cause. Add two options to the
   debate: the option that removes the cause, and the option that changes
   nothing.
2. State the pros and the cons of each option for this task.
3. Drop each option that does not produce the correct result. This covers an
   option that the user proposes. A dropped option is never an alternative.
4. Rank the remaining options by their pros against their cons for this task.
   An option that removes the root cause ranks above a guard against the
   symptom, unless a checked fact blocks the removal. The first option is the
   recommendation. Each other option is an alternative. Another task can swap
   the ranking of the same options.
5. Attack your choice with its strongest objection. If no checked fact
   answers the objection, change the choice.
6. Check now each fact that your choice depends on. Never leave a dependent
   fact for later, and never write `check X before the PR`. Search the files
   before you call a fact unverified. Name it unverified only when no file
   settles it.
7. Predict the next three questions of the reader. Typical questions are:
   why, why not the option of the user, how it works now, what is removed,
   what stays, what can break. Answer each one in the message.

## The proposal

- **Quote the exact edit.** For text, quote the old and the new sentence. For
  code, name the exact symbol, function or line with its old and new behaviour.
  State `add` when no old text exists, and `delete` when no new text exists.
- **Prefer forbidding to mechanism.** Forbid a configuration change that creates
  an edge case, instead of a mechanism that handles the edge case. Add the
  mechanism only when the configuration change is required, and state why.

## The conversation

- **Raise one open item per message.** Say that the next item follows after
  the answer. Never batch two rulings into one question. One question that
  hides two decisions counts as two rulings.
- **Record a ruling before you raise the next item.** Write it to the decision
  register or the handoff file of the project. Quote the ruling back in one
  line when the project holds no such file.
- **Present a review finding in this format.** One bullet per item:
  `<B1/S1> - status:<FIXED/OPEN> - action:<YES/NO> - <name> - <description> -
  fix:<recommended change> - why:<reason>`. `B` is a blocker and `S` is a
  suggestion. The global instructions of the user win on any difference.

## Style

These rules govern the message you write. Quoted text, a file name and a code
identifier stay exact.

- Write short sentences, about 20 words. Use simple tenses and active voice.
  State one idea per sentence.
- Use no em-dash and no parenthetical aside. Split the sentence instead.
- Open every section, paragraph and bullet with a bold lead-in. The conclusion
  carries no label. A change bullet opens with its file name in backticks.
- Add a header only when the message passes 500 words. Use at most three.
- Write no flattery and no filler.
- Use concrete names, never abstract roles. Take the names from the files and
  the identifiers at hand. Never write `the caller` when `charge-retry` is
  available. Invent one small set only when the project gives no names.
- Name yourself in the recommendation when the user gives you a name, for
  example `Aelita recommends the stored key because ...`.
- Put an enumeration, a line reference and a measurement inside a list. An
  identifier with a number, for example order 4471, is a name in prose.

## Worked example

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

- `services/checkout/retry.ts` old behaviour: `buildCharge` calls `randomKey()`
  per attempt. New behaviour: `buildCharge` reads `order.chargeKey`.

**Recommendation.** Aelita recommends the stored key, because `stripe-live`
already knows it. It costs one query. An order without `chargeKey` breaks it.

**Alternative: look up the charge before the retry.** `charge-retry` asks
`stripe-live` for a charge tagged with order 4471 and skips the retry when one
exists. It needs no stored key. It costs one API call per retry. It becomes the
primary when orders older than `chargeKey` must retry too.

**Question.** Does `charge-retry` reuse the stored key, or look up the charge
before each retry?
```
