# Reviewer Guide — AppSec Red Team Copilot

This guide is for portfolio reviewers, recruiters, and technical interviewers who want the shortest path through the project.

## What This Project Is

AppSec Red Team Copilot is a local-first security copilot for coding workflows.

It watches code changes, analyzes risky git diff hunks before merge, and produces explicit gate verdicts:

- `allow`
- `warn`
- `block`

The goal is not to replace full AppSec tooling. The goal is to show practical security automation: clear risk triage, evidence-backed findings, operator UX, and validation discipline.

## Why It Matters

Security review often happens too late. This project moves review closer to the developer workflow by checking risky changes before they become merges.

It also demonstrates a stronger engineering habit: safety claims are backed by regression checks, audit verification, and proof-pack evidence.

## Best 5-Minute Review Path

1. Read the portfolio one-pager: `docs/PORTFOLIO_ONE_PAGER.md`.
2. Read the main README overview and quick self-test.
3. Open the screenshot guide: `docs/SCREENSHOTS.md`.
4. Read the 2-minute demo script: `docs/DEMO_SCRIPT.md`.
5. Review proof evidence: `release/proof-pack/validation-evidence-2026-05-12.md`.
6. Review safety limits: `docs/SECURITY_GUARANTEES_AND_LIMITS.md`.

## What To Look For

### Product / UX

- Dashboard-first workflow
- Clear verdicts and findings
- PR-comment-ready report output
- Beginner-friendly install and verification scripts

### Security Engineering

- Pre-change diff hunk analysis
- Broker-only mutation path
- Capability-scoped execution
- One-time approval tokens
- Protected path and workspace containment checks
- Hash-chained audit verification

### Evidence / Maintainability

- `scripts/safety_regression_check.sh`
- `scripts/verify_install.sh`
- `release/V0_4_TAG_CHECKLIST.md`
- `release/proof-pack/`
- runtime artifact policy in `docs/RUNTIME_ARTIFACTS.md`

## Validated Claims

Validated locally on 2026-05-12:

- install/dashboard check passed
- safety regression passed: 11/11
- audit chain verified: `ok=true`
- broker coverage reported: `1.0`, status `SAFE`
- eval harness returned: `riskAccuracy=1.0`, `typeCoverage=1.0` on 4 labeled cases
- emergency override lifecycle tested and cleaned up inactive

See: `release/proof-pack/validation-evidence-2026-05-12.md`

## Claims Kept Intentionally Narrow

This project does **not** claim to secure the whole machine.

Safer framing:

- governs integrated brokered mutation workflows
- complements OS controls, sandboxing, and endpoint protection
- provides pre-change security triage and evidence-backed review gates

Avoid claiming:

- prevents every malicious command
- replaces EDR/sandboxing/OS policy
- guarantees complete host security

## Suggested Interview Walkthrough

Use this framing:

> “I built a local AppSec copilot that reviews risky code changes before merge. It analyzes git diff hunks, assigns allow/warn/block verdicts, shows evidence in a dashboard, and validates its own safety path with regression checks and audit verification.”

Then show:

1. Dashboard screenshot
2. Pre-change findings screenshot
3. Safety regression proof
4. One-time approval-token fix as an example of validation catching a real bug

## Current Review Status

Portfolio/recruiter review quality: **ready for branch review**.

Local v0.4 validation status: **complete**.

Strict release/tag promotion remains a human decision.
