# Featured Project: Job Application Pipeline (Remote-First)

## Overview
A structured pipeline for discovering, scoring, and tracking remote jobs with clear follow-up workflows.

## Problem
Manual job searching is noisy and inconsistent. It’s easy to lose track of quality, follow-up timing, and application state.

## What I Built
- Separate jobs workspace/page to avoid disrupting core dashboard UX
- Structured listings with:
  - fit score (0–100)
  - A/B/C priority tier
  - source attribution
  - “why fit” rationale
- Tracking fields:
  - applied date
  - follow-up date
  - interview date
  - outcome
- Scheduled sync runs (2x/day)
- Safe export/publish workflow for public-facing repo content

## Candidate Profile Constraints
- Remote-only (USA)
- Full-time only
- Salary target floor and preferred range
- Title-targeted sourcing

## Design Principles
- Keep data actionable, not just collected
- Make follow-up visible and time-aware
- Separate private credentials from public artifacts
- Use fail-closed publishing checks

## Skills Demonstrated
- Workflow automation design
- Filtering/scoring logic
- Data hygiene and dedupe mindset
- Product-oriented UX iteration
- Security-aware handling of sensitive inputs

## Stack
- Node.js API endpoints for job CRUD
- JSON persistence for quick iteration
- Python sync scripts for source ingestion
- Browser UI integration in mission-control environment

## Outcome
A practical, extensible application engine that increases consistency, prioritization, and follow-through in the job search process.
