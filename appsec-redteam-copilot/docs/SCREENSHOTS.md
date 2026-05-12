# Screenshot Guide

These screenshots are included so reviewers can understand the project quickly even without running the app.

## Dashboard Overview

File: `docs/screenshots/dashboard-overview.jpg`

Shows:

- dashboard-first operator workflow
- project/workspace context
- action buttons for analysis and validation
- local AppSec copilot UX, not just a backend API

Reviewer takeaway:

> This project has a usable operator surface, not only command-line scripts.

## Pre-Change Findings

File: `docs/screenshots/prechange-findings.jpg`

Shows:

- pre-change diff hunk analysis
- risk verdict output
- finding details for risky code
- evidence-oriented review flow

Reviewer takeaway:

> The copilot can flag risky code before merge and present findings in a human-readable way.

## Findings Table

File: `docs/screenshots/prechange-table.jpg`

Shows:

- table-based triage view
- risk/finding organization
- review-friendly output for multiple findings

Reviewer takeaway:

> Findings are structured for review, not hidden in raw logs.

## How To Use These In A Demo

Recommended order:

1. `dashboard-overview.jpg`
2. `prechange-findings.jpg`
3. `prechange-table.jpg`
4. `release/proof-pack/validation-evidence-2026-05-12.md`

Suggested narration:

> “The dashboard shows the operator workflow. The pre-change findings show risky-code detection. The table shows reviewable output. The proof pack shows that the safety path was validated locally.”

## Current Screenshot Status

The screenshots are suitable for portfolio review.

Future improvement, if needed:

- refresh screenshots after final UI polish
- add one screenshot of the proof-pack / validation evidence view
- add one screenshot of PR-comment-ready output
