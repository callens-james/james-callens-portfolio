# Safe AI Suite (GitHub Ready)

This repository is the publish-safe package for a local-first Safe AI portfolio suite.

## What’s included
- **ai-risk-gate/** — policy-based risk classification + confirmation logic + audit logging
- **timeline-viewer/** — decision trace visualization and filtering
- **eval-harness/** — batch evaluation framework with JSON/CSV artifacts
- **safe-automation-template/** — guard-evaluate/guard-execute workflow template
- **safe-ai-suite/** — proof docs, metrics snapshots, trend table, screenshots

## Why I built this
I built this suite to prove that AI-enabled automation can be both **useful** and **safe** in practical operations. The goal was to move beyond prompt demos and implement real guardrails, measurable reliability, and auditable behavior.

## Why it matters
The suite demonstrates practical AI safety engineering:
- explicit controls before risky actions
- measurable reliability with repeatable evals
- iterative policy refinement with documented outcomes
- auditability and production-minded traceability

## How teams can use this
- Validate and harden internal AI policy rules before production rollout
- Add a risk-gating layer ahead of automation/execution actions
- Run repeatable regression evaluations after policy/model updates
- Provide governance/compliance-friendly evidence for AI safety reviews

## Key evidence
See:
- `safe-ai-suite/docs/SAFE_AI_PROOF_PACK.md`
- `safe-ai-suite/docs/METRICS_TREND_TABLE.md`
- `safe-ai-suite/docs/RUNBOOK_SAFE_AI_SUITE.md`
- `safe-ai-suite/docs/FAILURE_TAXONOMY_2026-05-02.md`

## Safety gate before push
```bash
cd "/home/james/openclaw-workspace/Safe AI/github-ready"
./prepublish_check.sh
```

## Notes
This folder contains only sanitized artifacts intended for public sharing.
