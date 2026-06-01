# Eval Harness

Eval Harness batch-tests automation scenarios and records repeatable reliability evidence.

## Goal

Measure whether policy and workflow changes improve behavior without creating regressions.

## What it measures

- pass/fail rate
- latency p50/p95
- escalation rate
- error taxonomy
- JSON/CSV result artifacts for reporting

## Run

```bash
npm install
npm run run:batch
npm start
```

Open: `http://localhost:3346`

## Dataset

Scenario cases live in `datasets/tasks.json`. Add your own prompts, expected outcomes, and risk labels to extend coverage.

## Why this matters

The goal is not a one-off demo. The harness makes policy behavior testable, comparable, and reviewer-friendly over time.
