# Timeline Viewer

Timeline Viewer is a local-first decision trace viewer for inspecting automation events.

## Goal

Make agent and workflow behavior reviewable:

```text
message -> route -> tool call -> result -> final response
```

## What it shows

- thread/session selector
- event stream panel
- filters for route, tool, error, and confirmation events
- highlighted risky actions and confirmation points

## Run

```bash
npm install
npm start
```

Open: `http://localhost:3345`

## Input data

By default, the viewer reads a local decision log path. Point it at your own JSONL event log when adapting the template.

## Why this matters

Automation is easier to trust when reviewers can see what happened, when it happened, and which controls were triggered.
