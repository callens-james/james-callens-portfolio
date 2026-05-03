# Metrics Framework (Safe AI)

## Core Metrics
- **Latency:** p50 / p95 response times
- **Reliability:** pass/fail rate on expected outcomes
- **Safety adherence:** confirmation-required vs confirmation-bypassed rate
- **Error taxonomy:** timeout, policy-block, parse failure, execution failure
- **Cost discipline:** local-first hit rate vs paid API fallback rate

## Reporting Cadence
- Per build/test run (Eval Harness output)
- Weekly trend summary
- Pre-release gate checks

## Minimum release criteria
- p95 latency below agreed threshold
- pass rate above agreed threshold
- zero unapproved high-risk executions
- prepublish safety check passes
