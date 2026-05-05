## Repository History Rewrite Notice

On **2026-05-05**, this repository history was rewritten to scrub sensitive/local environment identifiers from past commits.

### What changed
- Commit hashes changed across history.
- Branches/tags were force-pushed after rewrite.
- Current content is functionally equivalent, with privacy-focused redactions.

### If you cloned before this date
Please re-sync using one of these options.

#### Recommended: fresh clone
```bash
git clone https://github.com/callens-james/james-callens-portfolio.git
```

#### Existing clone: hard reset (destructive)
```bash
git fetch origin --prune
git checkout main
git reset --hard origin/main
git clean -fd
```

### Why this was done
To remove sensitive local-path/host/user identifiers and improve privacy hygiene in repository history.
