# 2-Minute Demo Script

Goal: show the value quickly without explaining every subsystem.

## Setup

Open dashboard:

`http://<server-ip>:3480/dashboard`

Use the existing screenshots if live demo time is short:

- `docs/screenshots/dashboard-overview.jpg`
- `docs/screenshots/prechange-findings.jpg`
- `docs/screenshots/prechange-table.jpg`

## Demo Flow

1. **Open dashboard**
   - Say: “This is a local-first AppSec copilot for code-change review.”

2. **Show project/workspace setup**
   - Keep it brief. The important point is scoped review, not broad host access.

3. **Introduce or point to a risky added line**
   - Example: `os.system(user_input)`
   - Say: “The interesting part is that it analyzes added diff hunks before merge.”

4. **Run Analyze Pre-Change Hunks**
   - Show verdict: `allow`, `warn`, or `block`
   - Show findings and evidence IDs if present.

5. **Show human-readable output**
   - Findings table
   - Impact/summary text
   - PR-comment-ready output from `/report/pr-comment`

6. **Show validation proof**
   - Open `release/proof-pack/validation-evidence-2026-05-12.md`
   - Point to:
     - safety regression: `pass=11 fail=0`
     - audit verify: `ok=true`
     - broker coverage: `1.0`, `SAFE`

7. **Close with the one-sentence value**

> AppSec Red Team Copilot catches risky code changes before they become merges, and backs its safety claims with repeatable validation evidence.

## What Not To Over-Explain

Avoid walking through every backend module unless asked.

Do not lead with:

- internal file layout
- every endpoint
- shell trap details
- systemd setup
- advisory cache internals

Those are supporting details, not the demo story.

## If Asked About Limits

Say clearly:

> “This governs integrated brokered workflows and complements OS controls. It is not claiming complete host-level security.”

## Best Interview Moment

Mention the validation pass caught a real bug:

> “During validation, the regression test exposed that cached approval tokens could be reused. I fixed that and added a regression check, so the proof pack now verifies one-time token enforcement.”
