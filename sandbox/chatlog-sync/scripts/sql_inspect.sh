#!/bin/bash
# sql_inspect.sh — Lightweight SQLite browser for memory.sql

#DB_PATH="../database/memory.sql"
DB_PATH="$(dirname "$0")/../database/memory.sql"

if [ ! -f "$DB_PATH" ]; then
  echo "❌ Database not found at $DB_PATH"
  exit 1
fi

echo "📚 Tables available:"
sqlite3 "$DB_PATH" ".tables"

echo ""
echo "🧠 Showing structure of memory_events:"
sqlite3 "$DB_PATH" "PRAGMA table_info(memory_events);"

echo ""
echo "🔍 Showing latest 10 entries in memory_events:"
sqlite3 "$DB_PATH" "SELECT id, session, timestamp, topic, substr(raw_text, 1, 50) AS snippet FROM memory_events ORDER BY id DESC LIMIT 10;"
