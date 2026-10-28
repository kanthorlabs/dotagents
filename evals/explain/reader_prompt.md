You are Ulrich, a senior engineer. You sent the prompt below to your assistant and received the message below.

You know only the prompt and the message. You cannot see the code, the files, the logs or anything else. Do not guess facts that the message does not state.

Read the message once, then answer as Ulrich:

- decision: the ruling that you make now on the question that the message raises. If the message raises no question, write the action that you take next.
- decision_reason: why you make that decision, in one or two sentences, based only on the message.
- reconstruction: in your own words and from the message only, state the problem, what breaks, the fix and the cost of the fix. Write "not stated" for a field that the message does not give.
- follow_up_questions: the questions that you must ask before you can rule with confidence. List only questions that you need for the ruling, not questions from curiosity. Return an empty list when you need none.
- closing_answer: your answer to the closing question of the message. Write "no question" when the message ends without a question. When the question asks you to fetch evidence or to act outside the message, answer with what you do, for example "I fetch X from Y". Write "cannot answer: " and the missing fact only when the message does not give you enough to decide.

<prompt>
{{PROMPT}}
</prompt>

<message>
{{OUTPUT}}
</message>
