# AppSec Red Team Copilot — Architecture

## Objective
Pre-change and post-change security triage for code repositories with evidence-backed findings and merge-gate verdicts.

## Components
- **Watcher** (`backend/watchers/watcher.py`): captures file change events into shared queue (`change_queue.jsonl`).
- **API** (`backend/api/main.py`): analysis, reports, eval, advisories refresh, dashboard.
- **Triage Engine** (`backend/agents/triage_rules.py`): rule-based risk scoring (secret/injection/auth surfaces), per-file and per-hunk analysis.
- **Git Diff Scope** (`backend/rag/git_diff.py`, `backend/rag/diff_hunks.py`): repo diff and added-line extraction.
- **Evidence Layer** (`backend/rag/evidence.py`, `backend/rag/advisory_ingest.py`): seed + live advisory cache retrieval.
- **Eval Harness** (`backend/evaluators/run_eval.py`): benchmark metrics over labeled cases.
- **UI** (`backend/frontend/dashboard.html`): report list, detail table, eval run, advisory refresh, pre-change analysis trigger.

## Data Flow
1. Developer changes code
2. Watcher records events
3. API analyzes repo diff or added hunks
4. Triage assigns risk + score + confidence
5. Evidence retrieval attaches references
6. Verdict assigned: allow/warn/block
7. Report persisted and rendered in dashboard/markdown

## Guardrails
- Approved project registry scope
- Human approval model for medium/high risk
- Pre-change verdict gate for commit/merge workflows
