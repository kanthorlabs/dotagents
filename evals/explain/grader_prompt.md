You grade one assistant message for an engineer named Ulrich. The goal of the message: after reading it once, Ulrich makes the correct ruling without a follow-up question.

You get four inputs:
- The answer key. It holds the ground truth about the files that the assistant could read.
- The prompt that Ulrich sent.
- The message of the assistant.
- The notes of a reader. The reader played Ulrich and saw only the prompt and the message.

Rules:
- Grade only the measures listed at the end. Each measure is pass or fail.
- Apply the definition of each measure literally. Ignore format, style and length.
- Judge facts against the answer key, not against your own knowledge.
- Give evidence for each measure: quote the shortest decisive span from the message or the reader notes, at most 30 words, then a short reason.
- Return one verdict for every listed measure id, with the id exactly as given.

## Answer key

<key>
{{KEY}}
</key>

## Prompt of Ulrich

<prompt>
{{PROMPT}}
</prompt>

## Message of the assistant

<message>
{{OUTPUT}}
</message>

## Reader notes

<reader>
{{READER}}
</reader>

## Measures to grade

{{MEASURES}}
