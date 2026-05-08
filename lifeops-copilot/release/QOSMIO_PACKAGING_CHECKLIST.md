# Qosmio Packaging Validation Checklist (LifeOps)

## Goal
Validate installer/first-run experience on target user machine (Qosmio) with minimal operator friction.

## Pre-check
- [ ] Confirm old LifeOps instances are closed
- [ ] Confirm required runtime dependencies present
- [ ] Confirm internet access for any package/runtime fetches

## Install
- [ ] Run installer/package as documented
- [ ] No missing dependency error popups
- [ ] Install path is clear and writable

## First Run
- [ ] App launches without terminal intervention
- [ ] Main dashboard loads successfully
- [ ] No blocking startup errors

## Functional Smoke
- [ ] Health endpoint reachable (`/api/health`)
- [ ] Queue Today renders
- [ ] Digest Daily renders
- [ ] Plan Day renders
- [ ] Metrics panel renders
- [ ] Notifications/opportunities views load

## Persistence / Restart
- [ ] Close app gracefully
- [ ] Reopen app; state and startup remain stable

## Update Path (if available)
- [ ] Apply update package
- [ ] Existing data/settings preserved
- [ ] App remains functional post-update

## Uninstall / Cleanup
- [ ] Uninstall completes without orphaned process
- [ ] Optional: user data retention behavior matches expectation

## Evidence Capture
- [ ] Screenshot install success
- [ ] Screenshot first-run dashboard
- [ ] Screenshot health check output
- [ ] Record any failures with exact text/time

## Result
- PASS / CONDITIONAL PASS / FAIL
- Notes:
