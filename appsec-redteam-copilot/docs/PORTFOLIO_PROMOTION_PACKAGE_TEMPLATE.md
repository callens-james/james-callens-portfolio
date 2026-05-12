# Portfolio Promotion Package Template — AppSec Red Team Copilot

Use this before treating the project as portfolio-ready.

## Project Summary

<One paragraph explaining the project and its value.>

## Demo Path

<Exact 2–5 minute flow.>

## Verified Evidence

- Safety regression check: <pass/fail/date>
- Audit verify endpoint: <pass/fail/date>
- Safety metrics / broker coverage: <summary/date>
- Eval report: <path/summary/date>
- Screenshots/proof-pack: <paths>

## Strongest Components

- <component>

## Known Limits

- <limit>

## Dependencies / Runtime

- Docker compose
- Python/FastAPI backend
- Watcher service
- Local advisory/eval data

## Storage / Runtime Artifacts

Document what is generated locally and what should not be committed.

## Risks

- <risk>

## Rollback / Recovery

- Stop Docker compose.
- Disable shell trap with `scripts/panic_disable_shell_trap.sh` if needed.
- Revert branch changes if documentation/package updates are not useful.

## Promotion Recommendation

<ready / not ready / keep active / archive>
