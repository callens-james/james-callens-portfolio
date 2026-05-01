This replacement fixes the PDF prompt flow in the current app. Main changes:
- Clipboard copy now uses the main Tk window instead of a temporary hidden Tk root.
- PDF workflow now runs on the main thread, so clipboard and auto-paste are more reliable.
- ChatGPT still does not auto-upload PDFs. You must upload them manually.
- Auto-paste now happens via `after(...)` on the main thread. Use:
1. Replace your current app.py with this one.
2. Keep your existing prompts/, r_scripts/, output/, logs/ folders.
3. Run the app again. NEW IN THIS BUNDLE
- Integrated AI toolkit logging (Use Case Matrix / Process Tracker / Data Pipeline)
- Structured metadata saved for Excel and PDF runs
- Bundled toolkit workbook and Word guide in workflow_app/toolkit
- UI kept intact; changes are backend only
