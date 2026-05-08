#!/usr/bin/env bash
set -euo pipefail
BASE="http://127.0.0.1:3480"
pass=0; fail=0

ok(){ echo "[PASS] $1"; pass=$((pass+1)); }
no(){ echo "[FAIL] $1"; fail=$((fail+1)); }

# 1) broker-only mode blocks legacy endpoint
r=$(curl -s -G --data-urlencode "cmd=echo hi" -X POST "$BASE/analyze-command" || true)
echo "$r" | grep -q "broker-only mode enabled" && ok "broker-only blocks /analyze-command" || no "broker-only blocks /analyze-command"

# 2) gate token flow + one-time consume
chk=$(curl -s -G --data-urlencode "action=command" --data-urlencode "cmd=echo hello" -X POST "$BASE/safety/gate/check")
tok=$(echo "$chk" | python3 -c 'import sys,json; j=json.load(sys.stdin); print(j.get("approvalToken",""))')
[ -n "$tok" ] || no "approval token generated"
app=$(curl -s -G --data-urlencode "token=$tok" --data-urlencode "cmd=echo hello" --data-urlencode "ttl=60" -X POST "$BASE/safety/gate/approve")
echo "$app" | grep -q '"ok": true' && ok "token approval works" || no "token approval works"
exe1=$(curl -s -G --data-urlencode "cmd=echo hello" --data-urlencode "token=$tok" -X POST "$BASE/broker/exec")
echo "$exe1" | grep -q '"ok": true' && ok "broker exec works with approved token" || no "broker exec works with approved token"
exe2=$(curl -s -G --data-urlencode "cmd=echo hello" --data-urlencode "token=$tok" -X POST "$BASE/broker/exec")
echo "$exe2" | grep -q 'approval token invalid' && ok "token one-time-use enforced" || no "token one-time-use enforced"

# 3) protected path floor (should block)
blk=$(curl -s -G --data-urlencode "cmd=cat /etc/passwd" -X POST "$BASE/broker/check")
echo "$blk" | grep -q 'protected-path-floor\|workspace-containment-fail' && ok "protected/outside scope blocked" || no "protected/outside scope blocked"

# 4) audit chain verify
ver=$(curl -s "$BASE/safety/audit/verify")
echo "$ver" | grep -q '"ok": true' && ok "audit chain verifies" || no "audit chain verifies"

echo "\nSummary: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]


# 5) capability child scope validation
cap=$(curl -s -G --data-urlencode "actor=parent" --data-urlencode "workspace=/workspace" --data-urlencode "actionClass=modify_files" --data-urlencode "ttl=120" -X POST "$BASE/capability/issue")
pt=$(echo "$cap" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("capabilityToken",""))')
child=$(curl -s -G --data-urlencode "parentToken=$pt" --data-urlencode "actor=child" --data-urlencode "ttl=60" -X POST "$BASE/capability/inherit")
ct=$(echo "$child" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("capabilityToken",""))')
cv=$(curl -s -G --data-urlencode "childToken=$ct" --data-urlencode "parentToken=$pt" -X POST "$BASE/capability/validate-child")
echo "$cv" | grep -q '"ok": true' && ok "capability child scope validation" || no "capability child scope validation"
