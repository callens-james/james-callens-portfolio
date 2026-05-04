# Background Task Design

## Runs with low user input
1. Deadline monitor (hourly)
2. Stale item detector (daily)
3. Opportunity refresh/re-rank (daily)
4. Weekly summary generator (weekly)
5. Duplicate document detector (on ingest)

## Guardrails
- No external irreversible action without approval
- Background tasks only propose; user confirms execution
- All background-generated recommendations logged to audit trail
