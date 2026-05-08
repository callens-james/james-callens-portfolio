# Demo Script: Before vs After Broker Enforcement

## 1) Legacy path blocked (after)
```bash
curl -s -G --data-urlencode "cmd=echo hello" -X POST http://127.0.0.1:3480/analyze-command
```
Expected: broker-only mode error.

## 2) Broker check without approval
```bash
curl -s -G --data-urlencode "cmd=rm -rf /tmp/demo" -X POST http://127.0.0.1:3480/broker/check | jq .
```
Expected: denied/needsPrompt + high risk reason.

## 3) Safe command approve + exec
```bash
TOK=$(curl -s -G --data-urlencode "action=command" --data-urlencode "cmd=echo hello" -X POST http://127.0.0.1:3480/safety/gate/check | jq -r .approvalToken)
curl -s -G --data-urlencode "token=$TOK" --data-urlencode "cmd=echo hello" --data-urlencode "action=command" --data-urlencode "workspace=/workspace" --data-urlencode "actor=local" -X POST http://127.0.0.1:3480/safety/gate/approve | jq .
curl -s -G --data-urlencode "cmd=echo hello" --data-urlencode "token=$TOK" --data-urlencode "actor=local" -X POST http://127.0.0.1:3480/broker/exec | jq .
```
Expected: success.

## 4) Replay token blocked
Run the same `/broker/exec` call again with same token.
Expected: `approval token invalid: used`.

## 5) Audit integrity check
```bash
curl -s http://127.0.0.1:3480/safety/audit/verify | jq .
```
Expected: `ok: true`.
