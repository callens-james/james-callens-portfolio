import json
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from change_queue import push
from registry import is_approved

CFG = Path(__file__).with_name('watch_config.json')

class Handler(FileSystemEventHandler):
    def __init__(self, cfg):
        self.cfg = cfg

    def _accept(self, p:Path):
        if any(part in self.cfg['excludeDirs'] for part in p.parts):
            return False
        if not is_approved(str(p)):
            return False
        return p.suffix.lower() in self.cfg['includeExtensions'] or p.name == 'Dockerfile'

    def on_modified(self, event):
        if event.is_directory:
            return
        p = Path(event.src_path)
        if self._accept(p):
            push(str(p), 'modified')
            print(f"[watch] modified: {p}")

    def on_created(self, event):
        if event.is_directory:
            return
        p = Path(event.src_path)
        if self._accept(p):
            push(str(p), 'created')
            print(f"[watch] created: {p}")

if __name__ == '__main__':
    cfg = json.loads(CFG.read_text())
    root = Path(cfg['workspaceRoot'])
    obs = Observer()
    obs.schedule(Handler(cfg), str(root), recursive=True)
    obs.start()
    print(f"Watching {root} (MVP)")
    try:
        while True:
            import time; time.sleep(1)
    except KeyboardInterrupt:
        obs.stop()
    obs.join()
