---
name: evidence-first
description: Load this skill FIRST, before any tool call, when the task gives a Slack link, a ticket or a document, or when the result goes to other people: a Slack message or draft, a reply, a tag or mention, a status update, a decision page or artifact, a plan, a review, or any date, deadline, count, retention period or "can we ship" answer. It gates context collection, cited evidence for every number and decision, and a search of the given sources before asking or tagging anyone.
---

# /evidence-first

Usage: `/evidence-first [$ARGUMENTS]`

`$ARGUMENTS` names the task. With no arguments, apply the rules to the task of
the current turn.

The skill has three gates. Pass each gate before the step that it guards.

1. **Context gate.** Pass it before you plan, write, edit or delegate.
2. **Evidence gate.** Pass it before you state a number, a fact or a decision.
3. **Ask gate.** Pass it before you ask, tag or assign a person.

## 1. Context gate

**Read every source the user gave.** A Slack link, a ticket, a document or an
artifact is a source. Read the whole thread, not only the linked message. Read
each report, artifact and ticket in the thread that touches the task. List
the other links as unread.

**List the surfaces before you read code.** A surface is a place that holds
the data or the behaviour of the task. Write the list first. Each item names
its location and its owner. Cover each kind:

- **The code of each service.** Take the services from the repository map of
  the project. Read the trunk branch, for example `git show origin/main:<path>`.
- **The work of other people.** Each feature, pull request and report that a
  teammate names in the thread is a surface. Name its owner.
- **The deployment values.** Read the values per environment and per region,
  for example `argocd-apps`. A schedule, a switch or a retention period lives
  there, not in the code.
- **The infrastructure.** Bucket lifecycle rules, object locks, backups and
  log retention live in infrastructure code.
- **The downstream copies.** Warehouses, caches, exports, search indexes, audit
  logs and backups hold a copy of the data.

**Record each surface that you cannot read.** Name the reason, for example
"repository not on this machine". Name the person who can answer. Show the
list of unread surfaces in the result.

**Brief a subagent with the list.** Give each subagent its surfaces, the facts
that the thread already settles, and the claims to test. Ask it to label each
claim VERIFIED or UNVERIFIED.

## 2. Evidence gate

**Cite a source for each claim.** A source is a `file:line`, a pull request, a
message with its author and date, a query with its output, or a deployment
value. A claim with no source is a guess. Label it UNVERIFIED.

**Prefer the primary source.** Code and deployment values win over a document.
A document wins over a summary. A subagent report is a summary.

**Check each load-bearing claim yourself.** A claim is load-bearing when a
decision, a recommendation or a number depends on it. Read the cited line
before you use the claim. Do this also for a subagent claim.

**Reconcile each conflict before you write.** Two sources disagree when two
reports, a report and the code, or a person and the code differ. Read the
primary source that settles it. Name the conflict when no source settles it.

**Back each number.** Give its value, its unit, its source and the date of the
reading. Take an environment-specific number from the environment that the
claim is about, and name that environment.

**Back each count with its population.** Quote the wording and the date of the
count. Do not reuse a count for a population that it does not name.

**Back each recommendation.** Name the facts that it depends on. Name the
result of each option. Name the person who decides.

**Back each commitment of a person's time.** A date, a deadline, "can be
built by" and "can be done this week" are commitments. A code fact proves that
the work is small. It does not prove that the person has the time. Before you
write a commitment for a person:

1. Read the open tasks of that person in the ticket system for the window.
2. Read the calendar of that person for the window.
3. Give an estimate with build hours and test hours.
4. Use estimate wording, for example "estimate: 1.5 days, 0.5 of them tests".
   Never use promise wording, for example "yes, it can ship on 13 Nov".
5. List the work that other people own on the path, for example a release of
   another service.
6. Get the confirmation of that person before the commitment goes to anyone
   else. When the person is the user, mark each date in the result as "needs
   your confirmation".

If you cannot read the tasks or the calendar, state the size of the work only.
Leave the date to the person.

## 3. Ask gate

**Search the sources first.** Before you ask or tag a person, search the whole
thread, the linked tickets and the linked reports for the answer. Search by
the topic words and by the name of the person.

**Use an answer that exists.** Quote it with its author and date. Remove the
question.

**Check the scope of the answer.** Confirm that the answer covers the same
store, number and population as the item. An answer about another object is
not an answer. Then the item stays open.

**Ask only for an answer that does not exist.** Write the search that found
nothing, for example "the thread has no answer since Matt asked on 19 Oct".

**Explain the item instead of a bare question.** When the `explain` skill is
loaded, write each item in its format. Otherwise each open item carries:

- **Today.** What the system does now, with its source.
- **Example.** One concrete case or a short timeline.
- **Why it matters.** The decision or the commitment that the item blocks.
- **Options.** Each option with its result.
- **Recommendation.** The option that you recommend, and why.
- **Decider.** The person who decides.

**Tag the owner of each item.** Take the owner from the sources, for example
"Sang builds the trigger" in the thread. Tag each person with only their own
items. Name an item without an owner as "no owner yet". Do not guess an owner.

## Result check

Run this check before you send the result.

1. Each claim carries a source or the label UNVERIFIED.
2. Each load-bearing claim was read in its primary source.
3. No two claims conflict.
4. The result lists the unread surfaces.
5. No question has an answer in the sources, and each quoted answer covers
   the same object as its item.
6. Each open item carries the six parts of the ask gate.
7. Each tag names the owner that the sources give.
8. No commitment of a person's time goes out without the tasks, the calendar,
   an estimate with test hours and the confirmation of that person.
