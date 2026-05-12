# Portfolio Readiness — AppSec Red Team Copilot

Status: **portfolio/recruiter review-ready on branch**

This project already has a strong portfolio story: a local-first AppSec copilot that analyzes risky code changes before merge and returns explicit `allow` / `warn` / `block` verdicts with evidence, reports, and an operator dashboard.

## Best Demo Path

Keep the demo narrow and evidence-driven:

1. Open `/dashboard`.
2. Show the project/workspace is configured.
3. Introduce or point to a risky added line such as `os.system(user_input)`.
4. Run **Analyze Pre-Change Hunks**.
5. Show verdict, findings, evidence, and human-readable impact.
6. Run **Eval** or show the latest eval/proof-pack result.
7. Show generated markdown report / PR-comment-ready output.
8. Explain the core value in one sentence:

> AppSec Red Team Copilot catches risky code changes before they become merges.

## Strongest Portfolio Claims

- Pre-change diff hunk analysis, not just after-the-fact scanning.
- Explicit gate verdicts: `allow`, `warn`, `block`.
- Evidence-backed findings from local advisory data.
- Eval harness and persisted reports.
- Dockerized local deployment.
- Operator-facing dashboard.
- Safety posture docs that state guarantees and limits clearly.

## Claims To Keep Precise

Do not claim complete host-level security.

Safer wording:

- “Governs integrated brokered mutation workflows.”
- “Complements OS controls, sandboxing, and endpoint protection.”
- “Provides pre-change security triage and evidence-backed review gates.”

Avoid:

- “Prevents all malicious commands.”
- “Secures the whole machine.”
- “Replaces sandboxing/EDR/OS policy.”

## Current Gaps Before Promotion

These are small validation/hygiene items, not a redesign:

1. Complete or update `release/V0_4_TAG_CHECKLIST.md`.
2. Capture fresh validation evidence for:
   - safety regression check
   - audit verification
   - safety metrics / broker coverage
   - demo walkthrough
3. Decide how to handle generated runtime artifacts. See `docs/RUNTIME_ARTIFACTS.md`.
4. Keep the demo focused; do not try to explain every subsystem at once.

## Recommended Next Step

Use the current proof pack for portfolio/recruiter review.

The local validation checklist is complete. Release/tag promotion should remain a human decision after branch review.

Do not add features until the current story is easy to verify and explain.
