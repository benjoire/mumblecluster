#!/usr/bin/env python3
"""
parse_chat.py — CLI parser for chatlogs
"""

import re
import sys
import os
import json
import yaml
import sqlite3
import logging
import glob
from datetime import datetime

try:
    import questionary
except ImportError:
    print("Missing dependency 'questionary'. Run: pip install questionary")
    sys.exit(1)

# Paths
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
THOUGHTS_PATH = os.path.join(BASE_DIR, "thoughts", "deniz-thoughts.yaml")
SQLITE_PATH = os.path.join(BASE_DIR, "database", "memory.sql")
LOGFILE_PATH = os.path.join(BASE_DIR, "logs", "chatlog-sync.log")

# Logging
logging.basicConfig(filename=LOGFILE_PATH, level=logging.INFO, format="%(asctime)s - %(message)s")

def load_chat(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        return f.readlines()

def clean_line(line):
    return re.sub(r"\[.*?\]", "", line.strip())

def segment_chat(lines):
    return [
        {"id": idx, "text": clean_line(line), "timestamp": datetime.now().isoformat()}
        for idx, line in enumerate(lines) if clean_line(line)
    ]

def export_yaml(segments):
    yaml_data = {
        "session": datetime.now().strftime("%Y-%m-%d_%H%M"),
        "segments": segments
    }
    with open(THOUGHTS_PATH, "w", encoding="utf-8") as f:
        yaml.dump(yaml_data, f, allow_unicode=True)
    logging.info(f"Exported YAML to {THOUGHTS_PATH}")

def insert_sql(segments):
    conn = sqlite3.connect(SQLITE_PATH)
    cur = conn.cursor()
    for seg in segments:
        cur.execute(
            "INSERT INTO memory_events (session, timestamp, topic, raw_text, tags) VALUES (?, ?, ?, ?, ?)",
            (
                datetime.now().strftime("%Y-%m-%d"),
                seg["timestamp"],
                "chat-segment",
                seg["text"],
                ""
            )
        )
    conn.commit()
    conn.close()
    logging.info(f"Inserted {len(segments)} rows into memory.sql")

def choose_chat_file():
    base = questionary.path("📁 Select chatlog folder or paste path").ask()

    if not base or not os.path.isdir(base):
        print("❌ Not a valid folder. Exiting.")
        sys.exit(1)

    chat_files = sorted(glob.glob(os.path.join(base, "*.txt")) + glob.glob(os.path.join(base, "*.md")))

    choices = [os.path.basename(f) for f in chat_files]
    choices.append("📎 Enter custom file path")
    choices.append("❌ Exit")

    selected = questionary.select("Choose a chatlog:", choices=choices).ask()

    if selected == "❌ Exit":
        sys.exit(0)
    elif selected == "📎 Enter custom file path":
        return questionary.text("Type or paste full file path:").ask()
    else:
        return os.path.join(base, selected)

def main():
    chatfile = choose_chat_file()
    use_sql = questionary.confirm("Also sync parsed segments into memory.sql?", default=True).ask()

    lines = load_chat(chatfile)
    segments = segment_chat(lines)
    export_yaml(segments)

    if use_sql:
        insert_sql(segments)

    print(f"🔄 Parsed {len(segments)} segments from {chatfile}")

if __name__ == "__main__":
    main()
