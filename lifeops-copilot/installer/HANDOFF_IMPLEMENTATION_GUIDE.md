# Installer Handoff Implementation Guide (Sprint 3.6)

## Goal
Implement production installer for Windows/macOS/Linux with profile-based setup.

## Inputs
- INSTALL_PROFILES.json
- SETUP_WIZARD_SPEC.md
- POST_INSTALL_TOGGLES.md
- UPDATE_CHECK_PLACEHOLDER.md

## Required behaviors
1. Show profile chooser (core/local-ai/openclaw)
2. Require warning acknowledgement for optional profiles
3. Apply profile to app settings on first launch
4. Allow profile changes later in Settings
5. No auto-install of optional components without explicit consent

## Acceptance tests
- Core-only install works on low-spec machine
- Optional profiles blocked until warning checkbox checked
- Selected profile persisted in app settings
- First-run wizard can be skipped and resumed
