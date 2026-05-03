# Safe Automation Template Architecture

1. Request enters guard layer (`/guard/evaluate`)
2. Policy checks run (blocked actions, risky actions)
3. Confirmation required for risky actions
4. Execution allowed only after checks pass
5. Every step logged to audit trail (`logs/audit.jsonl`)

This template is local-first and designed for adding tool handlers safely.
