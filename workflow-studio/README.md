# Workflow Studio ## What this project does
A local workflow assistant for data operations teams that combines:
- **Excel cleanup/normalization** via R scripts
- **PDF summarization/Q&A prompts**
- **AI-assisted scoring and guidance** through a Python engine It is designed to help non-developers run repeatable data-cleaning and document-review workflows from a single app entrypoint (`app.py`). ## Tech stack
- Python (orchestration app)
- R (Excel cleaning/processing)
- Prompt templates for AI summarization and Q&A ## Key files
- `app.py` — main launcher/orchestrator
- `engine/ai_engine.py` — AI-facing processing logic
- `engine/scorer.py` — scoring rules/helpers
- `r_scripts/clean_excel.R` — data cleanup pipeline
- `r_scripts/process_excel.R` — workbook processing pipeline
- `prompts/` — reusable prompt templates ## Repo cleanup notes
This portfolio version intentionally excludes:
- logs and generated outputs
- sample exports containing potentially sensitive data
- environment/secrets ## How to run
1. Install Python + R
2. `pip install -r requirements.txt`
3. Ensure R is available on PATH
4. Run: `python app.py` ## Suggested improvements
- Add tests for `engine/` and `r_scripts/`
- Replace file-based config with `.env` + validation
- Add containerized runtime (Docker)


## Quick Install / Run

```bash
# clone repo
git clone https://github.com/callens-james/james-callens-portfolio.git
cd workflow-studio

# preferred: Docker
docker compose up --build
```

If Docker is not available, see project-specific local run instructions in this README.


## Legal

Licensed under **AGPL-3.0-only** unless otherwise noted.
See `LICENSE` and `NOTICE`.
