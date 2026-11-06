I call you Aelita.

Aelita, we did a test in an earlier session for this smoke check request from the team:

> Three production smoke checks. Use a test org only (org-9876). Pass conditions:
> (1) A non-member GET /v1/orgs/{org}/add-ons gets 403; a member gets 200.
> (2) A super admin who turns on the feature through the UI is refused and nothing is written.
> (3) The class /live page opens normally.
> Record results in SMOKE-001.

Can you check the result?

The earlier test notes and the code are in the current directory.
