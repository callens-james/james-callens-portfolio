# 2-Minute Demo Script

1. Open dashboard: `http://<server-ip>:3480/dashboard`
2. Click **Refresh Advisories**
3. Introduce a risky added line (e.g., `os.system(user_input)`) in tracked file
4. Click **Analyze Pre-Change Hunks**
5. Show verdict (warn/block), findings table, evidence IDs
6. Run **Eval** and show metrics snapshot
7. Show generated markdown report (`SECURITY_REPORT.md`)
8. Explain pre-change gate behavior (allow/warn/block)
