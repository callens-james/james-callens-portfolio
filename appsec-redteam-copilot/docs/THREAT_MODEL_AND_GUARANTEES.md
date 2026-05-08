# Threat Model & Safety Guarantees (v0.4 safety milestone)

## What this system is
AppSec Red Team Copilot is a workspace-scoped safety gate for command/code operations.
It is designed for human-in-the-loop workflows with layered policy and execution checks.

## Safety guarantees (current)

### Guaranteed (within broker path)
1. **Broker-only execution mode** can disable legacy command analysis execution path.
2. **Single-use approval tokens** are required for gated execution and are command-bound.
3. **Protected-path floor** blocks high-risk/system-sensitive path operations.
4. **Workspace containment checks** block out-of-scope path targets.
5. **Tamper-evident audit chain** (hash-linked entries) detects log integrity breaks.

### Best-effort
1. Regex/pattern detection for destructive command heuristics.
2. Path extraction from command strings (improves but not perfect semantic parsing).
3. Human confirmation quality (depends on operator decisions).

## Known limitations
1. Full process-level containment is not yet kernel-enforced sandboxing.
2. Complex indirect mutations via deeply nested scripts can reduce classification clarity.
3. Non-command mutation channels must be explicitly routed through broker to inherit guarantees.

## Threat classes addressed
- accidental destructive shell usage
- policy toggle misuse (admin phrase required)
- token replay (single-use command-bound approval)
- out-of-scope filesystem mutation attempts
- audit log silent tampering

## Threat classes still in progress
- deep semantic command intent parsing (beyond regex heuristics)
- OS-level syscall containment
- remote append-only audit sink + signing

## Operator guidance
- Keep **Master Safe Mode ON** for non-coder environments.
- Keep **brokerOnlyMode ON** in all normal operation.
- Use regression check before release changes:
  - `bash scripts/safety_regression_check.sh`

## Validation endpoints
- `/safety/policy`
- `/safety/mode`
- `/broker/check`
- `/broker/exec`
- `/safety/audit`
- `/safety/audit/verify`
