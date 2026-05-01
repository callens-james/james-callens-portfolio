# Workflow Suite (R + MED-PC Analysis Scripts) ## Overview
This project bundles R scripts and companion text/protocol files used to process and analyze behavioral experiment outputs (e.g., self-administration, open field, elevated plus maze, social interaction, qPCR-supporting scripts). ## What this repository demonstrates
- Practical R scripting for real lab workflows
- Data reshaping and trial-level extraction patterns
- Script modularization around assay/behavior paradigms
- Integration context with MED-PC task files (`.mpc`) ## Structure
- `Self_Administration/` – SA analysis scripts and helper logic
- `Open_Field/` – open field analysis scripts
- `Elevated_Plus_Maze/` – EPM scripts and protocol notes
- `Nosepoke_SA/` – nosepoke FR workflow scripts
- `qPCR/` – qPCR analysis script(s)
- `text_files_for_R/` – helper notes and setup text ## Notes on authorship
Most R scripts were authored by James. `master_script` variants may include collaborative modifications from team workflows. ## Public-release cleanup
This portfolio version excludes runtime state files (`.RData`, `.Rhistory`) and applies basic redaction for common sensitive patterns. ## Suggested improvements
- Replace hard-coded file paths with `config.yml` + CLI args
- Add reproducible test fixtures and expected outputs
- Add unit tests for parsing/transform helper functions
