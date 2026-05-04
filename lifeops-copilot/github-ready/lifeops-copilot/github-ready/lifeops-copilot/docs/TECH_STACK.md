# Tech Stack Decision

## Build-now stack (speed)
- Backend/API: Node.js + Fastify
- Frontend: HTML/CSS/JS
- Storage: local JSON (upgrade to SQLite)

## Productization stack (performance)
- Core engine: Rust
- Desktop packaging: Tauri
- UI: TypeScript frontend
- Storage: SQLite

## Why this approach
Ship fast with Node to validate behavior, then migrate stable/high-load paths to Rust for low-resource devices and cross-platform installers.
