# Rust-First Migration Architecture

## Migration triggers (move Node -> Rust when 2+ true)
1. Median response > 250ms on low-spec test machine
2. Memory use > 350MB for normal workflow
3. Need background daemon reliability beyond Node prototype limits
4. Installer/package size must be significantly reduced

## Migrate first
1. Priority/risk scoring engine
2. Deadline extractor and parser
3. Background reminder scheduler
4. Audit/event writer

## Keep in JS initially
- UI rendering
- Non-critical view formatting
- Onboarding copy/wizard content
