import os
import requests

VERDICT_ORDER = {"allow":0, "warn":1, "block":2}

def should_alert(verdict:str)->bool:
    min_v = (os.getenv('ALERT_MIN_VERDICT','warn') or 'warn').lower()
    v = (verdict or 'allow').lower()
    return VERDICT_ORDER.get(v,0) >= VERDICT_ORDER.get(min_v,1)

def send_telegram_alert(text:str)->dict:
    token = os.getenv('TELEGRAM_BOT_TOKEN','').strip()
    chat_id = os.getenv('TELEGRAM_CHAT_ID','').strip()
    if not token or not chat_id:
        return {"sent": False, "reason": "missing_env"}
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    resp = requests.post(url, json={"chat_id": chat_id, "text": text}, timeout=15)
    ok = resp.status_code == 200
    return {"sent": ok, "status": resp.status_code}

def build_alert(payload:dict)->str:
    risk = (payload.get('risk') or 'low').upper()
    verdict = (payload.get('verdict') or 'allow').upper()
    summary = payload.get('summary','')
    project = payload.get('project','')
    return f"AppSec Alert\nVerdict: {verdict}\nRisk: {risk}\nProject: {project}\nSummary: {summary}"
