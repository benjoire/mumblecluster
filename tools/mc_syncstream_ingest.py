#!/usr/bin/env python3
import csv
import json
import os
import re
from pathlib import Path
from datetime import datetime, timezone

MC_ROOT = Path(os.environ.get("MC_ROOT", "/home/celvin__1/Documents/MumbleCluster"))
RUNS_DIR = Path(os.environ.get("MC_RUNS_DIR", str(MC_ROOT / "_blueprint" / "_runs")))
OUT_DIR = Path(os.environ.get("MC_SYNCSTREAM_OUT_DIR", str(MC_ROOT / "_blueprint" / "_syncstream_exports")))
OUT_DIR.mkdir(parents=True, exist_ok=True)

OUT_CSV = OUT_DIR / "Runs_Index__auto.csv"

HEADER = [
    "Timestamp (UTC)",
    "Title",
    "Phase",
    "Scope",
    "Operator",
    "Controller Node",
    #"Hetzner Node",
    "Exit",
    "Status",
    "Integrity",
    "Run Dir",
    "Notes (1-liner)",
]

def read_text(p: Path) -> str:
    try:
        return p.read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return ""

def extract_one_liner_notes(notes_md: str) -> str:
    """
    Pull a single-line summary from notes.md.
    Preference:
      1) 'Result:' line if present
      2) first non-empty, non-header, non-bullet template line
    """
    # Try: "- Result: ..."
    for line in notes_md.splitlines():
        m = re.match(r"^\s*-\s*Result:\s*(.+)\s*$", line)
        if m and m.group(1).strip():
            return m.group(1).strip()

    # Fall back to any meaningful line that isn't the template
    junk_prefixes = ("# Notes", "- Intent:", "- What changed:", "- Result:", "- Follow-up:")
    for line in notes_md.splitlines():
        s = line.strip()
        if not s:
            continue
        if s.startswith(junk_prefixes):
            continue
        # ignore pure bullets without content
        if s in ("- Intent:", "- What changed:", "- Result:", "- Follow-up:"):
            continue
        return s[:240]
    return ""

def normalize_integrity(rec: dict, status_txt: str) -> str:
    # Prefer explicit record field if present
    integrity = rec.get("integrity") or rec.get("Log Integrity") or ""
    if integrity:
        return integrity
    # If status COMPLETE and timestamp looks current-ish, treat as LIVE by default
    if status_txt.strip() == "COMPLETE":
        return "LIVE"
    return "RETRO/UNKNOWN"

def parse_timestamp(ts: str) -> str:
    # Keep as-is if it already looks like ISO Z
    if re.match(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$", ts):
        return ts
    # Try parse
    try:
        dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        return dt.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    except Exception:
        return ts

def main() -> int:
    rows = []
    run_dirs = sorted([p for p in RUNS_DIR.glob("*__*") if p.is_dir()])

    for run_dir in run_dirs:
        rec_path = run_dir / "run_record.json"
        if not rec_path.exists():
            continue

        try:
            rec = json.loads(read_text(rec_path))
        except json.JSONDecodeError:
            # skip broken record
            continue

        status_txt = read_text(run_dir / "status.txt").strip()
        if status_txt != "COMPLETE":
            print(f"SKIP {run_dir.name} (status={status_txt or 'MISSING'})")
            continue

        notes_md = read_text(run_dir / "notes.md")
        one_liner = extract_one_liner_notes(notes_md)

        ts = parse_timestamp(str(rec.get("timestamp_utc", "")))
        title = str(rec.get("title", "")).strip()
        phase = str(rec.get("phase", "")).strip()
        scope = str(rec.get("scope", "")).strip()
        operator = str(rec.get("operator", "")).strip()
        controller = str(rec.get("controller_node", "")).strip()
        #hetz = str(rec.get("hetzner_node", "")).strip()
        exit_code = rec.get("exit_code", "")

        integrity = normalize_integrity(rec, status_txt)

        rows.append([
            ts,
            title,
            phase,
            scope,
            operator,
            controller,
            #hetz,
            exit_code,
            status_txt or rec.get("status", ""),
            integrity,
            str(run_dir),
            one_liner,
        ])

    # Sort newest-first by timestamp string (ISO sorts lexicographically)
    rows.sort(key=lambda r: r[0], reverse=True)

    with OUT_CSV.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(HEADER)
        w.writerows(rows)

    print(f"Wrote: {OUT_CSV}")
    print(f"Runs processed: {len(rows)}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
