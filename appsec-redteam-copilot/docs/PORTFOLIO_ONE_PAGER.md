# Portfolio One-Pager — AppSec Red Team Copilot

## One-Sentence Summary

AppSec Red Team Copilot catches risky code changes before they become merges by analyzing git diff hunks and producing clear `allow` / `warn` / `block` verdicts with evidence.

## Problem

Security review often happens too late: after risky code has already been written, merged, or deployed.

Developers need fast, local feedback that explains risk clearly without forcing them to wait for a full security review cycle.

## Solution

A local-first AppSec copilot that:

- watches approved project/workspace folders
- analyzes changed files and added diff hunks
- detects risky patterns such as command execution, injection, secrets, and auth-sensitive changes
- returns clear gate verdicts: `allow`, `warn`, or `block`
- produces dashboard findings, markdown reports, and PR-comment-ready output
- validates safety claims with regression checks and audit verification

## Why This Project Matters

This project shows more than a demo UI. It shows practical security engineering discipline:

- precise claims instead of overclaiming
- evidence-backed validation
- operational docs and install flow
- safety limits documented clearly
- regression testing that caught a real approval-token reuse bug

## Strongest Proof Points

Validated locally on 2026-05-12:

- install/dashboard verification passed
- safety regression passed: `11/11`
- audit verification returned `ok=true`
- broker coverage reported `1.0`, status `SAFE`
- eval harness returned `riskAccuracy=1.0`, `typeCoverage=1.0` on 4 labeled cases
- emergency override lifecycle tested and cleaned up inactive

Evidence: `release/proof-pack/validation-evidence-2026-05-12.md`

## Demo Path

1. Open dashboard.
2. Show project/workspace scope.
3. Add or point to risky code such as `os.system(user_input)`.
4. Run **Analyze Pre-Change Hunks**.
5. Show verdict, findings, and evidence.
6. Show proof pack validation results.

Full demo: `docs/DEMO_SCRIPT.md`

## Screenshots

- `docs/screenshots/dashboard-overview.jpg` — dashboard/operator surface
- `docs/screenshots/prechange-findings.jpg` — risky-change finding output
- `docs/screenshots/prechange-table.jpg` — findings table / triage view

Screenshot guide: `docs/SCREENSHOTS.md`

## Technical Highlights

- FastAPI backend
- Docker Compose runtime
- Watcher service for project changes
- Diff hunk analysis
- Evidence-backed triage
- Brokered execution safety path
- Capability-scoped mutation control
- One-time approval token enforcement
- Hash-chained safety audit verification

## Honest Limits

This does not claim complete host-level security.

It is best described as:

> local-first pre-change AppSec triage with brokered execution governance and validation-backed safety claims.

It complements OS controls, sandboxing, EDR, and human review.

## Best Reviewer Starting Points

- `README.md`
- `docs/REVIEWER_GUIDE.md`
- `docs/DEMO_SCRIPT.md`
- `release/proof-pack/README.md`
- `release/proof-pack/validation-evidence-2026-05-12.md`
