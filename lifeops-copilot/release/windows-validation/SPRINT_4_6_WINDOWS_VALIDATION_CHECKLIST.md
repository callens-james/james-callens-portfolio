# Sprint 4.6 — Windows Installer Validation Checklist

## Package
- [ ] `LifeOps Copilot_0.3.0_x64_en-US.msi` exists
- [ ] File hash captured (SHA256)

## Install
- [ ] MSI launches installer UI
- [ ] Install completes without errors
- [ ] App appears in Start Menu
- [ ] App appears in Installed Apps list

## First Launch
- [ ] App starts successfully
- [ ] Setup banner appears when `setupComplete=false`
- [ ] Setup Wizard profile loading works
- [ ] Optional profile warning acknowledgment enforced

## Core Flow Smoke
- [ ] Run Quick Start Demo succeeds
- [ ] Queue populates
- [ ] Plan My Day generates
- [ ] Career/SMB/Health sections render

## Security/Trust
- [ ] High-risk approval requires phrase
- [ ] Rollback button works
- [ ] Security settings save
- [ ] Selfcheck passes

## Data/Export
- [ ] Export bundle downloads
- [ ] Data export package downloads
- [ ] Data integrity report loads

## Multi-User
- [ ] User switch works
- [ ] Viewer denied destructive actions

## Uninstall/Reinstall
- [ ] Uninstall succeeds
- [ ] Reinstall succeeds
- [ ] App launches after reinstall
