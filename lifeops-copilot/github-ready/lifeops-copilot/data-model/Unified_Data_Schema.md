# Unified Data Schema (v1)

## Core entities
- `item` (task/doc/obligation/opportunity)
- `entity` (person/org/program)
- `deadline`
- `checklist_item`
- `action`
- `approval`
- `audit_event`
- `module_state`

## Workflow states
`inbox -> parsed -> planned -> awaiting_approval -> in_progress -> done | blocked | expired`

## Key design choice
Every module writes to the same core entities, enabling shared reminders, prioritization, and reporting.
