---
name: evidence-first
description: Load this skill FIRST, before any tool call, when the task gives a Slack link, a ticket or a document, or when the result goes to other people: a Slack message or draft, a reply, a tag or mention, an email, a status update, meeting notes, a decision page or artifact, a plan, a review, or any date, deadline, count, retention period or "can we ship" answer. It gates context collection, cited evidence for every number and decision, and a search of the given sources before asking or tagging anyone.
---

# /evidence-first

Usage: `/evidence-first [$ARGUMENTS]`

`$ARGUMENTS` names the task. With no arguments, apply the rules to the task of
the current turn.

The skill has three gates. Pass each gate before the step that it guards.

1. **Context gate.** Pass it before you plan, write, edit or delegate.
2. **Evidence gate.** Pass it before you state a number, a fact or a decision.
3. **Ask gate.** Pass it before you ask, tag or assign a person.

**Scale the gates to the message.** For a message with no number, date,
decision, question or tag, pass only the context gate and the reader rules.
A short thank-you is such a message.

**Keep the work out of the sent message.** Keep the source list, the unread
list and the labels in the report to the user. In the message that other
people read, write "not checked yet" in plain words.

## 1. Context gate

**Read every source the user gave.** A Slack link, a ticket, an email, a
document or an artifact is a source. Read the whole thread, not only the
linked message. Read each report, artifact and ticket in the thread that
touches the task. List the other links as unread.

**List the sources before you write.** A source is a place that holds a fact
of the task. Write the list first. Each item names its location and its owner.
Cover each kind that applies:

- **The conversation.** The whole thread, the earlier threads that it cites,
  and the tickets and documents that it links.
- **What each person said.** What each person already stated, decided,
  promised or asked, with the date. A later message of the same person wins.
- **The work of other people.** Each feature, pull request and report that a
  person names in the thread. Name its owner.
- **The time of people.** The open tasks and the calendar of each person when
  the message names a date for that person.
- **The system.** When the message makes a claim about a system, take the
  systems from the repository map of the project. Include each service that
  keeps its own copy of the data. Read the code on its trunk branch, the
  deployment values per environment and region, and the infrastructure code.
  Read the downstream copies: warehouses, caches, exports, audit logs and
  backups.

**Record each source that you cannot read.** Name the reason, for example
"repository not on this machine". Name the person who can answer.

**Know the reader.** Before you write, name the reader and the channel. Take
the language, the length and the format from the stated rule of the user
first. Then take them from recent messages in the channel. Match the tone of
the user in that channel. Name what the reader already knows from the thread.
Do not repeat it.

**Brief a subagent with the list.** Give each subagent its sources, the facts
that the thread already settles, and the claims to test. Ask it to label each
claim VERIFIED or UNVERIFIED.

## 2. Evidence gate

**Close every gap before you report.** For each gap, split the evidence
into two parts. The first part is what the tools and sources at hand
prove. The second part is what only a live action or a person can confirm.
Tools and sources at hand include code, logs, tickets, data, and
read-only calls. State the verdict for the first part even when the
second is still open. An unknown sub-part does not block a verdict that
the readable part proves. Mark a gap UNVERIFIED only when no tool or
source at hand addresses it. Do not ask "should I check it?" for a gap
the tools at hand can close.

**Cite each claim.** A citation names a source at its exact point: a message
with its author and date, a ticket, a document section, a `file:line`, a pull
request, a query with its output, or a deployment value. A claim with no
citation is a guess. Label it UNVERIFIED.

**Prefer the primary source.** For a fact about a system, the code and the
deployment values win over a document. For what a person decided or promised,
that person's own message wins over a summary of it. A document wins over a
summary. A subagent report is a summary.

**Check each load-bearing claim yourself.** A claim is load-bearing when a
decision, a recommendation or a number depends on it. Read the cited source
before you use the claim. Do this also for a subagent claim.

**Check the scope of each quote.** Confirm that the quote covers the same
object, number and population as the claim.

**Reconcile each conflict before you write.** Two sources disagree when two
reports, two messages, or a message and the system differ. Read the primary
source that settles it. Name the conflict when no source settles it.

**Back each number.** Give its value, its unit, its source and the date of the
reading. Take an environment-specific number from the environment that the
claim is about, and name that environment.

**Back each count with its population.** Quote the wording and the date of the
count. Do not reuse a count for a population that it does not name.

**Back each recommendation.** Name the facts that it depends on. Name the
outcome of each option. Name the person who decides.

**Check each step that you tell a reader to do.** Read what the step changes
for the reader. Give the smallest step that does only the task. For example,
link one skill. Do not tell the reader to run an installer that also changes
their settings.

**Back each commitment of a person's time.** A date, a deadline, "can be
done by" and "can be done this week" are commitments. A small task does not
prove that the person has the time. Before you write a commitment for a
person:

1. Read the open tasks of that person in the ticket system for the window.
2. Read the calendar of that person for the window.
3. Give an estimate with work hours and test or review hours.
4. Use estimate wording, for example "estimate: 1.5 days, 0.5 of them tests".
   Never use promise wording, for example "yes, it can ship on 13 Nov".
5. Name the work that other people own on the path, as a fact with its owner
   and date. Do not call it a risk.
6. Get the confirmation of that person before the commitment goes to anyone
   else. When the person is the user, mark each date in the report as "needs
   your confirmation".

If you cannot read the tasks or the calendar, state the size of the work only.
Leave the date to the person.

## 3. Ask gate

**Collect all user-needed gaps first.** Before you ask the user anything,
list every gap that needs a credential, a permission, a write approval,
or a decision. Write one ask section at the end of your response. Each
item: "Need [X] to unblock [condition N]." Ask nowhere else in the
response.

**Search the sources first.** Before you ask or tag a person, search the whole
thread, the linked tickets and the linked reports for the answer. Search by
the topic words and by the name of the person.

**Use an answer that exists.** Quote it with its author and date. Remove the
question.

**Check the scope of the answer.** Confirm that the answer covers the same
object, number and population as the item. When the answer covers another
object, keep the item open.

**Ask only for an answer that does not exist.** Write the search that found
nothing, for example "the thread has no answer since Matt asked on 19 Oct".

**Explain the item instead of a bare question.** When the `explain` skill is
loaded, write each item in its format. Otherwise each open item carries:

- **Today.** What is true now, with its source.
- **Example.** One concrete case or a short timeline.
- **Why it matters.** The decision or the commitment that the item blocks.
- **Options.** Each option with its outcome.
- **Recommendation.** The option that you recommend, and why.
- **Decider.** The person who decides.

**Fit the items to the channel.** When the six parts exceed the length of the
channel, put them on a linked page. Give each item one line in the message.

**Tag the owner of each item.** Take the owner from the sources, for example
"Sang builds the trigger" in the thread. Tag each person with only their own
items. Name an item without an owner as "no owner yet". Do not guess an owner.
In a draft for several owners, write one block per owner. The one-item rule
of `explain` does not apply to that draft.

## Result check

Run this check before you send the result.

1. Each claim carries a citation or the label UNVERIFIED.
2. You read each load-bearing claim in its primary source.
3. No two claims conflict.
4. The report to the user lists the unread sources.
5. No question has an answer in the sources. Each quote covers the same object
   as its claim or its item.
6. Each open item carries the six parts of the ask gate, on the message or on
   a linked page.
7. Each tag names the owner that the sources give.
8. Each commitment of a person's time carries the tasks, the calendar and an
   estimate with test hours. It also carries the confirmation of that person.
9. Each number names its unit, source, date and environment. Each count names
   its population.
10. Each step for a reader does only the task.
11. The message fits the reader: the language, the length, the format and the
    tone, with nothing that the reader already knows. It holds no internal
    labels or source lists.
12. No gap is marked UNVERIFIED or left as "should I check this?" when the
    tools at hand can close it.
13. Read the required record location. State whether it exists and what
    its current state is (for example, that result cells are empty). When
    it does not exist, name the step to create it.
