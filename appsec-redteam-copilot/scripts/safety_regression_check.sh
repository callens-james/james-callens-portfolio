#!/usr/bin/env bash
set -euo pipefail
BASE="http://127.0.0.1:3480"
pass=0; fail=0

ok(){ echo "[PASS] $1"; pass=$((pass+1)); }
no(){ echo "[FAIL] $1"; fail=$((fail+1)); }
json_get(){ python3 -c 'import sys,json; j=json.load(sys.stdin); print(j.get(sys.argv[1],""))' "$1"; }

# 1) broker-only mode blocks legacy endpoint
r=$(curl -s -G --data-urlencode "cmd=echo hi" -X POST "$BASE/analyze-command" || true)
echo "$r" | grep -q "broker-only mode enabled" && ok "broker-only blocks /analyze-command" || no "broker-only blocks /analyze-command"

# 2) broker exec requires a current capability token
cap_required=$(curl -s -G --data-urlencode "cmd=echo hello" -X POST "$BASE/broker/exec")
echo "$cap_required" | grep -q 'capability required' && ok "broker exec requires capability" || no "broker exec requires capability"

# 3) capability + low-risk broker execution works
cap=$(curl -s -G --data-urlencode "actor=local" --data-urlencode "workspace=/workspace" --data-urlencode "actionClass=modify_files" --data-urlencode "ttl=120" -X POST "$BASE/capability/issue")
ct=$(echo "$cap" | json_get capabilityToken)
[ -n "$ct" ] && ok "capability token generated" || no "capability token generated"
exe_low=$(curl -s -G --data-urlencode "cmd=echo hello" --data-urlencode "capabilityToken=$ct" --data-urlencode "actor=local" --data-urlencode "workspace=/workspace" -X POST "$BASE/broker/exec")
echo "$exe_low" | grep -q '"ok":true' && ok "broker exec works with capability" || no "broker exec works with capability"

# 4) gated destructive command uses approval token once
# This command targets a deliberately nonexistent in-workspace path, so it exercises the destructive gate without removing project files.
cmd="chmod -R 777 /workspace/__appsec_regression_nonexistent_${RANDOM}_$$_ || true"
chk=$(curl -s -G --data-urlencode "action=command" --data-urlencode "cmd=$cmd" -X POST "$BASE/safety/gate/check")
tok=$(echo "$chk" | json_get approvalToken)
echo "$chk" | grep -q '"needsPrompt":true' && [ -n "$tok" ] && ok "destructive command requires approval token" || no "destructive command requires approval token"
app=$(curl -s -G --data-urlencode "token=$tok" --data-urlencode "cmd=$cmd" --data-urlencode "ttl=60" -X POST "$BASE/safety/gate/approve")
echo "$app" | grep -q '"ok":true' && ok "token approval works" || no "token approval works"
cap2=$(curl -s -G --data-urlencode "actor=local" --data-urlencode "workspace=/workspace" --data-urlencode "actionClass=modify_files" --data-urlencode "ttl=120" -X POST "$BASE/capability/issue")
ct2=$(echo "$cap2" | json_get capabilityToken)
exe1=$(curl -s -G --data-urlencode "cmd=$cmd" --data-urlencode "token=$tok" --data-urlencode "capabilityToken=$ct2" --data-urlencode "actor=local" --data-urlencode "workspace=/workspace" -X POST "$BASE/broker/exec")
echo "$exe1" | grep -q '"ok":true' && ok "broker exec works with approved token" || no "broker exec works with approved token"
cap3=$(curl -s -G --data-urlencode "actor=local" --data-urlencode "workspace=/workspace" --data-urlencode "actionClass=modify_files" --data-urlencode "ttl=120" -X POST "$BASE/capability/issue")
ct3=$(echo "$cap3" | json_get capabilityToken)
exe2=$(curl -s -G --data-urlencode "cmd=$cmd" --data-urlencode "token=$tok" --data-urlencode "capabilityToken=$ct3" --data-urlencode "actor=local" --data-urlencode "workspace=/workspace" -X POST "$BASE/broker/exec")
echo "$exe2" | grep -q 'approval token invalid' && ok "token one-time-use enforced" || no "token one-time-use enforced"

# 5) protected path floor should block
blk=$(curl -s -G --data-urlencode "cmd=cat /etc/passwd" -X POST "$BASE/broker/check")
echo "$blk" | grep -q 'protected-path-floor\|workspace-containment-fail' && ok "protected/outside scope blocked" || no "protected/outside scope blocked"

# 6) audit chain verify
ver=$(curl -s "$BASE/safety/audit/verify")
echo "$ver" | grep -q '"ok":true' && ok "audit chain verifies" || no "audit chain verifies"

# 7) capability child scope validation
parent=$(curl -s -G --data-urlencode "actor=parent" --data-urlencode "workspace=/workspace" --data-urlencode "actionClass=modify_files" --data-urlencode "ttl=120" -X POST "$BASE/capability/issue")
pt=$(echo "$parent" | json_get capabilityToken)
child=$(curl -s -G --data-urlencode "parentToken=$pt" --data-urlencode "actor=child" --data-urlencode "ttl=60" -X POST "$BASE/capability/inherit")
ct_child=$(echo "$child" | json_get capabilityToken)
cv=$(curl -s -G --data-urlencode "childToken=$ct_child" --data-urlencode "parentToken=$pt" -X POST "$BASE/capability/validate-child")
echo "$cv" | grep -q '"ok":true' && ok "capability child scope validation" || no "capability child scope validation"

echo ""
echo "Summary: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
