# Weather Dashboard (Portable Desktop App)

A zero-AI, no-subscription desktop weather planner for outdoor work and gardening.

## Goals
- Portable app (no installer required for test builds)
- Auto-fetch weather on launch
- Manual refresh button
- Day / Week / Month planning summaries
- Multi-source weather aggregation for better reliability

## Current Build (Phase 1)
- Electron shell
- Local Express API
- Multi-source fetch:
 - Open-Meteo forecast API
 - National Weather Service (US) forecast API (when available)
- Summary cards for today, 7-day, and 30-day outlook
- Refresh button + source status panel

## Run (dev)
```bash
npm install
npm start
```

## Package (later)
We will use `electron-builder` to produce a portable Windows executable.

## Notes
- Internet is required for live weather pulls.
- No API keys required in current phase.


## Quick Install / Run

```bash
# clone repo
git clone <REPO_URL>
cd <PROJECT_FOLDER>

# preferred: Docker
docker compose up --build
```

If Docker is not available, see project-specific local run instructions in this README.


## Legal

Licensed under **AGPL-3.0-only** unless otherwise noted.
See `LICENSE` and `NOTICE`.
