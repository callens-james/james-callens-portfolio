# Validation Evidence — 2026-05-12

Scope: local validation for AppSec Red Team Copilot v0.4 safety/portfolio readiness.

## Environment

- Local Docker Compose service rebuilt and restarted from current source.
- No production deployment performed.
- No paid APIs used.

## Install / Dashboard Check

Command:

```bash
bash scripts/verify_install.sh
```

Result:

```text
OK: health
OK: dashboard
OK: install verified
```

## Safety Regression Check

Command:

```bash
bash scripts/safety_regression_check.sh
```

Result:

```text
[PASS] broker-only blocks /analyze-command
[PASS] broker exec requires capability
[PASS] capability token generated
[PASS] broker exec works with capability
[PASS] destructive command requires approval token
[PASS] token approval works
[PASS] broker exec works with approved token
[PASS] token one-time-use enforced
[PASS] protected/outside scope blocked
[PASS] audit chain verifies
[PASS] capability child scope validation

Summary: pass=11 fail=0
```

## Safety Mode

Endpoint:

```bash
curl -s http://127.0.0.1:3480/safety/mode
```

Observed:

```json
{"brokerOnlyMode":true,"commandGuard":true,"agentSafeMode":true}
```

## Audit Verification

Endpoint:

```bash
curl -s http://127.0.0.1:3480/safety/audit/verify
```

Observed:

```json
{"ok":true,"checked":26,"errors":[],"genesisCount":1,"lastHash":"668de8d8f732961999a1d339601a40501b0738402fd10dcdcad015864530a7ac"}
```

## Safety Metrics

Endpoint:

```bash
curl -s http://127.0.0.1:3480/safety/metrics
```

Observed:

```json
{"events":26,"executionEvents":23,"brokerCoverageRate":1.0,"coverageStatus":"SAFE","counts":{"global-gate-check":7,"broker-exec":14,"broker-deny":2,"emergency-override-enabled":1,"emergency-override-auto-disabled":1,"emergency-override-disabled":1}}
```

## Eval Harness

Endpoint:

```bash
curl -s -X POST http://127.0.0.1:3480/eval/run
```

Observed:

```json
{"report":"/app/backend/data/eval_reports/eval-20260512T210554Z.json","riskAccuracy":1.0,"typeCoverage":1.0,"cases":4}
```

## Pre-Change Report / PR Comment

Pre-change analysis against current repo diff returned:

```json
{"savedAt":"2026-05-12T21:06:06.587915","project":"/workspace","summary":"Analyzed added lines: 0","risk":"low","verdict":"allow","findings":[],"source":"pre-change-diff"}
```

PR comment endpoint returned a ready-to-paste allow comment with 0 findings.

## Fixes Discovered During Validation

Validation exposed a one-time approval-token weakness: cached approvals did not respect the `used` flag and broker execution did not consume reused approval tokens.

Fix applied:

- `backend/agents/global_gate.py` now only reuses cached approvals when `used` is false.
- `backend/agents/mutation_broker.py` now treats reused approvals as requiring token consumption.
- `scripts/safety_regression_check.sh` now validates capability-token flow and one-time approval enforcement.

Emergency override validation also exposed a metrics clarity issue: policy lifecycle audit events lowered broker coverage even though they were not execution-path events.

Fix applied:

- `/safety/metrics` now reports `executionEvents` and excludes emergency override lifecycle events from broker coverage denominator.

## Emergency Override Lifecycle

Local lifecycle test exercised on 2026-05-12:

1. Confirmed override inactive before test.
2. Enabled emergency override for 1 minute with required admin confirmation phrase.
3. Confirmed override active.
4. Waited for expiry and called `/safety/mode` to trigger normalization.
5. Confirmed override auto-disabled.
6. Explicitly disabled override as cleanup.
7. Verified audit chain remained valid.
8. Observed audit events:
   - `emergency-override-enabled`
   - `emergency-override-auto-disabled`
   - `emergency-override-disabled`

Final state: `emergencyOverrideActive=false`, `emergencyOverrideExpiresAt=0`.

## Remaining Limits

- This was local validation only.
- No production deployment was performed.
- Release/tag promotion remains a human decision.
