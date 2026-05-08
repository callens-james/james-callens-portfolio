# Mutation Path Map

| Path | Mutating | Broker Routed | Status |
|---|---|---|---|
| `/broker/check` | No | n/a | Active |
| `/broker/exec` | Yes | Yes | **Authoritative** |
| `scripts/safe-run.sh` | Yes | Yes (`/broker/check` + `/broker/exec`) | Active |
| `/analyze-command` | Legacy analysis route | No (execution denied in brokerOnlyMode) | Blocked by default |
| `/safety/policy` | Yes (config mutation) | Policy-protected (admin phrase) | Active |
| `/setup/init`, `/config/*` | Yes (watch config mutation) | Not command-brokered (API config layer) | Guarded by policy admin confirm where applicable |

## Target posture
- All command mutations must route through `/broker/exec`.
- Legacy direct execution paths remain disabled when `brokerOnlyMode=true`.
