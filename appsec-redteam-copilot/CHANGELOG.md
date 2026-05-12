# Changelog

## Unreleased
- Added portfolio readiness notes to clarify the strongest demo path, precise claims, current promotion gaps, and next validation step.
- Added a portfolio promotion package template for future evidence bundling.
- Added runtime artifact policy docs and expanded `.gitignore` coverage for Python/runtime cache artifacts.
- Expanded the v0.4 tag checklist into an evidence-capture worksheet.
- Fixed one-time approval token enforcement in brokered execution validation flow.
- Updated safety regression script for capability-token broker requirements.
- Added local validation evidence to the proof pack.
- Added reviewer guide, proof-pack index, and tightened demo flow for portfolio/recruiter review.
- Added portfolio one-pager and screenshot guide to reduce reviewer friction.
- Completed local emergency override lifecycle validation and updated proof-pack evidence.
- Clarified safety metrics so broker coverage measures execution-path events rather than policy lifecycle audit events.

## v0.3.0 - 2026-05-07
- Added pre-change diff hunk analysis endpoint with verdict gating (`allow`/`warn`/`block`)
- Added advisory ingestion cache refresh endpoint
- Added eval harness endpoint and persisted eval reports
- Added markdown security report renderer
- Added dashboard with report list/detail, eval, advisories refresh, and analysis actions
- Added Docker compose two-service runtime (API + watcher)
- Added systemd service-mode runbook and ops cheat sheet
