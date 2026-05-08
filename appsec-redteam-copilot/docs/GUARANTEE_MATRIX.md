# Guarantee Matrix

## Guaranteed (current scope)
- Broker-only default blocks legacy command execution path.
- One-time command-bound approval token required for gated execution.
- Token context binding: action/workspace/actor must match.
- Workspace containment and protected-path floors can hard-block execution.
- Hash-chained audit entries with verification endpoint.

## Conditional
- Detection quality for complex shell intent relies on current pattern/risk logic.
- Path extraction accuracy depends on parseability of command string.

## Best-effort
- Deep semantic understanding of nested scripts/subprocess chains.
- External mutation channels not yet explicitly broker-routed.
