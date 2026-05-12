# AppSec Proof Pack

Curated evidence for AppSec Red Team Copilot portfolio/reviewer review.

## Start Here

- `validation-evidence-2026-05-12.md` — main validation summary
- `latest_eval.json` — latest eval harness result
- `latest_prechange_report.json` — latest pre-change analysis report
- `latest_pr_comment.json` — ready-to-paste PR comment output
- `latest_safety_metrics.json` — latest broker coverage / safety metrics result
- `latest_audit_verify.json` — latest audit-chain verification result
- `SECURITY_REPORT.md` — generated markdown report

## What Was Proven Locally

On 2026-05-12:

- install/dashboard verification passed
- safety regression passed: 11 checks, 0 failures
- audit verification returned `ok=true`
- safety metrics reported broker coverage `1.0`, status `SAFE`
- eval harness reported risk accuracy `1.0` and type coverage `1.0` on 4 labeled cases
- emergency override lifecycle was tested and confirmed inactive after cleanup

## Important Limits

This proof pack is local validation evidence, not a production deployment certification.

The project is safest to describe as:

> local-first pre-change AppSec triage with brokered execution governance and validation-backed safety claims.

Do not describe it as full host security, EDR replacement, or complete command prevention.
