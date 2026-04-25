# Architecture Snapshot (Draft)

## Layers
1. **Interface Layer** — mission-control style dashboard
2. **Decision Layer** — intent routing and mode handling
3. **Execution Layer** — tool/command orchestration with safety checks
4. **Model Layer** — local-first inference with optional fallback

## Design Principles
- Control > blind automation
- Local-first where possible
- Explicit approvals for risky actions
- Observable behavior (status, logs, outcomes)

## Safety Direction
- Preview-before-run for command execution
- Guardrails for sensitive operations
- Secret-safe handling policies
- Reversible change sequencing
