# AppSec Red Team Copilot

## Summary

AppSec Red Team Copilot is a local-first security copilot for code-change review.

It analyzes risky git diff hunks before merge, assigns clear `allow` / `warn` / `block` verdicts, and backs safety claims with validation evidence.

## Why It Matters

Security review often happens late. This project moves risk feedback closer to the developer workflow and shows practical security automation with clear evidence, limits, and reviewer-friendly proof.

## Portfolio Highlights

- Pre-change diff hunk analysis
- Dashboard-first review workflow
- Evidence-backed findings
- PR-comment-ready output
- Safety regression checks
- Hash-chained audit verification
- Brokered execution governance
- Capability-scoped mutation control
- One-time approval token enforcement

## Validation Evidence

Latest local validation showed:

- install/dashboard check passed
- safety regression passed: `11/11`
- audit verification: `ok=true`
- broker coverage: `1.0`, status `SAFE`
- emergency override lifecycle tested and cleaned up inactive

Proof pack:

- [`../appsec-redteam-copilot/release/proof-pack/README.md`](../appsec-redteam-copilot/release/proof-pack/README.md)
- [`../appsec-redteam-copilot/release/proof-pack/validation-evidence-2026-05-12.md`](../appsec-redteam-copilot/release/proof-pack/validation-evidence-2026-05-12.md)

## Reviewer Path

Start here:

1. [`../appsec-redteam-copilot/docs/PORTFOLIO_ONE_PAGER.md`](../appsec-redteam-copilot/docs/PORTFOLIO_ONE_PAGER.md)
2. [`../appsec-redteam-copilot/docs/REVIEWER_GUIDE.md`](../appsec-redteam-copilot/docs/REVIEWER_GUIDE.md)
3. [`../appsec-redteam-copilot/docs/DEMO_SCRIPT.md`](../appsec-redteam-copilot/docs/DEMO_SCRIPT.md)
4. [`../appsec-redteam-copilot/docs/SECURITY_GUARANTEES_AND_LIMITS.md`](../appsec-redteam-copilot/docs/SECURITY_GUARANTEES_AND_LIMITS.md)

## Honest Scope

Best description:

> Local-first pre-change AppSec triage with brokered execution governance and validation-backed safety claims.

Avoid describing it as full host security, EDR replacement, or complete command prevention.
