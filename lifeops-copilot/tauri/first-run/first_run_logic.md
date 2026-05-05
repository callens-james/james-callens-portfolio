# First-Run Wizard Logic (Sprint 4.0)

1. On app launch, call `/api/settings`.
2. If `setupComplete !== true`, show setup wizard overlay.
3. Wizard steps:
 - choose profile
 - acknowledge warnings (if optional profile)
 - model selection + compatibility test
 - scheduler defaults
4. Save via `/api/onboarding` and `/api/installer/apply-profile`.
5. Set `setupComplete=true` and launch dashboard.
