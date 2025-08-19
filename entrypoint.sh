#!/usr/bin/env bash
set -euo pipefail

echo "[entrypoint] Waiting for DB at ${DB_HOST}:${DB_PORT} ..."
python - <<'PYCODE'
import os, time
import mysql.connector

host = os.getenv("DB_HOST", "db")
port = int(os.getenv("DB_PORT", "3306"))
user = os.getenv("DB_USER", "notesuser")
password = os.getenv("DB_PASSWORD", "")
database = os.getenv("DB_NAME", "notesdb")

for i in range(60):
    try:
        conn = mysql.connector.connect(
            host=host, port=port, user=user, password=password, database=database
        )
        conn.close()
        print("[entrypoint] DB connection successful")
        break
    except Exception as e:
        print(f"[entrypoint] DB not ready yet: {e}")
        time.sleep(2)
else:
    raise SystemExit("DB not reachable after retries")
PYCODE

# Run migrations
echo "[entrypoint] Applying migrations ..."
flask db upgrade || (echo "Migration failed" && exit 1)

echo "[entrypoint] Starting Gunicorn ..."
exec "$@"
