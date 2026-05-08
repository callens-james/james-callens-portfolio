# Security Guarantees & Limits

## Purpose
This document defines what AppSec Red Team Copilot enforces today, where enforcement is conditional, and what remains out-of-scope.

## Strong guarantees (integrated execution scope)
- Broker-mediated mutation flow is the default control path.
- Broker-only mode blocks legacy direct execution route.
- Mutating execution requires approved tokens/capabilities (context-bound, expiring).
- Workspace containment and protected-path floors can block execution.
- Safety audit trail is hash-chained and verifiable.

## Conditional guarantees
- Protection applies to integrated/orchestrated paths that route through broker.
- Detection quality for complex shell intent depends on parser/rules and execution adapter strictness.

## Explicit limits (important)
AppSec does **not** claim complete host-level security by itself. It does not replace:
- OS access controls and privilege boundaries
- endpoint protection/antivirus/EDR
- sandboxing or kernel-level policy enforcement
- malware defense for unmanaged binaries/processes outside integration

## Recommended posture
- Keep Master Safe Mode ON
- Keep broker-only mode ON
- Use capability-scoped workflows for agents/sub-agents
- Pair AppSec with host security controls

## Roadmap direction
- Capability propagation enforcement and process lineage checks
- Out-of-band mutation detection
- Typed execution adapters (intent-driven operations)
