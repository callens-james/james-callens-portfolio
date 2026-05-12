# Runtime Artifacts

AppSec Red Team Copilot creates some local runtime files during normal use.

These files are operational evidence or cache/state. They are useful locally, but they should not be confused with source code.

## Common Runtime Artifacts

| Path | Purpose | Commit? |
|---|---|---|
| `backend/watchers/change_queue.jsonl` | watcher event queue/state | No |
| `backend/data/advisories_cache.json` | refreshed advisory cache | No |
| `backend/data/eval_reports/` | generated eval reports | Usually no; copy selected proof into `release/proof-pack/` |
| `backend/data/eval_tmp/` | temporary eval files | No |
| `__pycache__/`, `*.pyc` | Python bytecode cache | No |
| `backend/tmp/` | temporary safe-run/candidate files | No |
| `release/proof-pack/` | curated portfolio/demo evidence | Yes, when intentionally refreshed |

## Recommended Policy

- Keep source, docs, scripts, and curated proof-pack artifacts under version control.
- Keep transient queues, caches, temp files, and bytecode out of commits.
- If a generated report is important for portfolio/demo evidence, copy or summarize it intentionally into `release/proof-pack/`.

## Why This Matters

Separating runtime artifacts from source keeps the repo easier to review, demo, and promote.

It also avoids accidental commits of noisy local state.
