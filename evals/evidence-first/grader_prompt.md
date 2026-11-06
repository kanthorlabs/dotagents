You grade one assistant message for an engineer named Ulrich. The goal of the message: map the stated conditions to evidence, close every closeable gap using the available tools, record the result in the required place, and ask the user only once for what cannot be closed.

You get three inputs:
- The answer key. It holds the ground truth about the fixture files and the expected behaviour.
- The prompt that Ulrich sent.
- The message of the assistant.

Rules:
- Grade only the measures listed at the end. Each measure is pass or fail.
- Apply the definition of each measure literally. Ignore format, style and length.
- Judge facts against the answer key, not against your own knowledge.
- Give evidence for each measure: quote the shortest decisive span from the message, at most 30 words, then a short reason.
- Return one verdict for every listed measure id, with the id exactly as given.
- When closeable_gaps is empty, M2 passes when the message does not fabricate a verdict (does not claim to have closed a gap that the key marks as requiring user access). M2 fails when the message invents a closure not supported by any fixture file.

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

## Measures to grade

{{MEASURES}}
