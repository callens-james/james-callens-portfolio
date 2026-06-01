# Safe AI Suite

## One-line summary
Safe AI Suite is a publish-safe toolkit showing how to make AI-enabled automation reviewable: risk gating, decision traces, eval evidence, and guarded execution templates.

## Problem solved
AI automation projects often skip the hard parts: deciding when an action is risky, preserving evidence, testing policy changes, and giving reviewers a clear audit trail. This project packages those safety patterns as small, inspectable modules.

## What it includes
- **AI Risk Gate** — policy-based risk classification with `allow` / `confirm` style decisions and audit logging.
- **Timeline Viewer** — decision trace visualization for reviewing what happened and why.
- **Eval Harness** — repeatable batch checks with JSON/CSV outputs for policy and scenario coverage.
- **Safe Automation Template** — guard-evaluate / guard-execute workflow with preflight and rollback scripts.
- **Proof docs** — metrics snapshots, failure taxonomy, runbook, proof pack, and screenshots.

## Reviewer path
Start here:

1. Project folder: [`../safe-ai-suite/`](../safe-ai-suite/)
2. Proof pack: [`../safe-ai-suite/safe-ai-suite/docs/SAFE_AI_PROOF_PACK.md`](../safe-ai-suite/safe-ai-suite/docs/SAFE_AI_PROOF_PACK.md)
3. Metrics trend table: [`../safe-ai-suite/safe-ai-suite/docs/METRICS_TREND_TABLE.md`](../safe-ai-suite/safe-ai-suite/docs/METRICS_TREND_TABLE.md)
4. Runbook: [`../safe-ai-suite/safe-ai-suite/docs/RUNBOOK_SAFE_AI_SUITE.md`](../safe-ai-suite/safe-ai-suite/docs/RUNBOOK_SAFE_AI_SUITE.md)
5. Failure taxonomy: [`../safe-ai-suite/safe-ai-suite/docs/FAILURE_TAXONOMY_2026-05-02.md`](../safe-ai-suite/safe-ai-suite/docs/FAILURE_TAXONOMY_2026-05-02.md)

## Validation evidence
The package has been checked with:

- module dependency audits
- JavaScript syntax checks
- eval harness batch runs
- safe automation preflight
- screenshot/OCR prepublish scan
- focused scans for local paths, IPs, names, and secret-like patterns

## Portfolio positioning
This is best treated as a supporting safety-engineering package, not the first recruiter click. It reinforces the same theme as the flagship projects:

> I am not just automating work — I am making automation reviewable.

## Boundaries / claims to avoid
Do not describe this as:
- production deployed
- a complete enterprise AI governance platform
- a replacement for security review, compliance review, or access control
- model-level safety research

Best framing: a local-first portfolio toolkit demonstrating practical safety controls, eval-backed policy iteration, and reviewer-ready evidence for AI automation workflows.
