# Interview Pitch — AppSec Red Team Copilot

## 60-second version
I built an AppSec AI copilot that scans code changes before merge and assigns a gate verdict: allow, warn, or block. It analyzes git diff hunks, scores risk using security heuristics, and attaches advisory evidence from a local cache seeded by live GitHub advisories. I added a dashboard for operators, a persisted report history, a markdown report generator, and an eval harness with measurable metrics. The system is Dockerized as two services—API and watcher—and can run under systemd for ops reliability.

## 2-minute version
Problem: security issues are often discovered late, after risky code is already merged.

Solution: pre-change analysis over added lines in git diff, with explicit gate outcomes.

How it works:
1. Watcher tracks code changes in approved project roots.
2. API can run post-change file analysis and pre-change hunk analysis.
3. Triage engine detects secret leaks, injection signals, and auth-surface risk; outputs score + confidence.
4. Evidence layer enriches findings from seed CVEs + refreshed GitHub advisories cache.
5. Reports are stored, rendered as markdown, and shown in a dashboard.
6. Eval harness runs labeled cases and outputs quality metrics.

Why it’s production-oriented:
- explicit risk gates (allow/warn/block)
- scoped project registry
- persisted reports + operational dashboard
- Docker compose runtime + systemd wrapper
- reproducible eval metrics

## Resume bullets
- Built an AI-powered AppSec copilot for pre-merge diff hunk analysis with verdict gating (allow/warn/block).
- Implemented evidence-backed triage using merged seed + live advisory cache and confidence-scored findings.
- Shipped a Dockerized two-service architecture (API + watcher) with systemd operational run mode.
- Added eval harness and report pipeline (JSON + markdown) with measurable risk accuracy metrics.
