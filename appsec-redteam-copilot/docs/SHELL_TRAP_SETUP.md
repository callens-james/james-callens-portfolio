# Shell Trap Setup (Optional) — Route Commands Through AppSec Automatically

This guide explains how to enable an **optional shell trap** so interactive commands run through `runsafe` automatically.

> Recommended for advanced users. If unsure, use explicit `runsafe "..."` only.

---

## What this does

With trap enabled (opt-in), your shell intercepts interactive commands and sends them to:

`<PROJECT_ROOT>/scripts/safe-run.sh`

Behavior:
- `allow` → command executes
- `warn` → you must type `YES` in terminal
- `block` → command does not execute
- Telegram alert triggers for `warn/block` if alert env is configured

---

## Prerequisites

1. AppSec Copilot is running (Docker/systemd)
2. `safe-run.sh` exists and works:

```bash
bash <PROJECT_ROOT>/scripts/safe-run.sh "ls -lah"
```

3. Optional Telegram alerts configured in `backend/.env.local`

---

## Install (Bash)

```bash
cd <PROJECT_ROOT>
bash scripts/install_shell_trap.sh ~/.bashrc
source ~/.bashrc
```

Default state after install:
- trap enabled (`APPSEC_TRAP_ENABLED=1`)

---

## Install (Zsh users)

Use your zsh rc file:

```bash
bash scripts/install_shell_trap.sh ~/.zshrc
source ~/.zshrc
```

---

## Toggle on/off quickly

Disable for current shell:

```bash
export APPSEC_TRAP_ENABLED=0
```

Enable again:

```bash
export APPSEC_TRAP_ENABLED=1
```

---

## Bypass trap for one command

Prefix with `command`:

```bash
command ls -lah
```

---

## Remove trap block completely

Re-run installer (it replaces old block), then manually delete block between markers:

- `# >>> appsec-runsafe-trap >>>`
- `# <<< appsec-runsafe-trap <<<`

from your rc file (`~/.bashrc` or `~/.zshrc`).

---

## Where to add this in your own repo

Recommended structure for public repos:

- `scripts/safe-run.sh` (command wrapper)
- `scripts/install_shell_trap.sh` (installer)
- `docs/SHELL_TRAP_SETUP.md` (this guide)

And in your README add:

```markdown
## Optional Auto-Guard Shell Trap
See `docs/SHELL_TRAP_SETUP.md` for enabling automatic command interception through AppSec.
```

---

## Troubleshooting

### Commands appear to run twice
- Ensure only one trap block is present in rc file.
- Re-run installer; it replaces prior block by markers.

### Nothing happens
- Confirm interactive shell (`echo $-` includes `i`).
- Confirm `APPSEC_TRAP_ENABLED=1`.

### Too noisy / too strict
- Keep trap disabled and use explicit `runsafe` for risky commands only.

### Alerting not sending
- Verify `backend/.env.local` and run:
  - `curl -s -X POST http://127.0.0.1:3480/alerts/test | jq`



## Emergency disable
```bash
bash scripts/panic_disable_shell_trap.sh
```
Then open a new terminal.
