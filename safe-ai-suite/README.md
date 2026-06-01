# Safe AI Suite

Safe AI Suite is a publish-safe, local-first toolkit for making AI-enabled automation reviewable: risk gating, decision traces, repeatable evals, guarded execution, and proof-pack documentation.

## What’s included

| Module | Purpose | Local port |
| --- | --- | --- |
| `ai-risk-gate/` | Policy-based risk classification, confirmation logic, and audit logging | `3344` |
| `timeline-viewer/` | Decision trace visualization and filtering | `3345` |
| `eval-harness/` | Batch evaluation framework with JSON/CSV artifacts | `3346` |
| `safe-automation-template/` | Guard-evaluate / guard-execute workflow template with preflight and rollback | `3347` |
| `safe-ai-suite/` | Proof docs, metrics snapshots, trend table, and screenshots | n/a |

## Why I built this

AI automation demos often skip the hard parts: deciding when an action is risky, preserving evidence, testing policy changes, and giving reviewers a clear audit trail. This suite packages those safety patterns as small, inspectable modules.

## Why it matters

The suite demonstrates practical AI safety engineering:

- explicit controls before risky actions
- measurable reliability with repeatable evals
- iterative policy refinement with documented outcomes
- auditability and production-minded traceability
- prepublish hygiene before public sharing

## How teams can use this

- Validate and harden internal AI policy rules before production rollout
- Add a risk-gating layer ahead of automation/execution actions
- Run repeatable regression evaluations after policy/model updates
- Provide governance/compliance-friendly evidence for AI safety reviews

## Reviewer path

Start here:

1. Proof pack: [`safe-ai-suite/docs/SAFE_AI_PROOF_PACK.md`](./safe-ai-suite/docs/SAFE_AI_PROOF_PACK.md)
2. Metrics trend table: [`safe-ai-suite/docs/METRICS_TREND_TABLE.md`](./safe-ai-suite/docs/METRICS_TREND_TABLE.md)
3. Runbook: [`safe-ai-suite/docs/RUNBOOK_SAFE_AI_SUITE.md`](./safe-ai-suite/docs/RUNBOOK_SAFE_AI_SUITE.md)
4. Failure taxonomy: [`safe-ai-suite/docs/FAILURE_TAXONOMY_2026-05-02.md`](./safe-ai-suite/docs/FAILURE_TAXONOMY_2026-05-02.md)

## Local setup

Each module is standalone. From a module folder, install dependencies and start it locally:

```bash
cd ai-risk-gate   # or timeline-viewer / eval-harness / safe-automation-template
npm install
npm start
```

Use the included sample configs and datasets as templates. Replace paths, policies, and logs with your own local values before personal use.

## Safety gate before push

```bash
cd "<repo-root>"
./prepublish_check.sh
```

## Boundaries

This is a portfolio/reference toolkit, not a complete enterprise governance platform, security review replacement, or production access-control system.

## Notes

This folder contains only sanitized artifacts intended for public sharing.

## License

Licensed under **AGPL-3.0-only** unless otherwise noted. See `LICENSE` and `NOTICE`.
