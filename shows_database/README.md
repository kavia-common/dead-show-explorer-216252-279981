# Shows Database (PostgreSQL)

This database stores users, shows, tracks, and favorites for the Grateful Dead Show Explorer.

What this provides:
- schema.sql: Tables, constraints, and useful indexes (including lower(text) indexes for ILIKE performance).
- seed.sql: A few sample users, shows (Cornell ’77, Lyceum ’72, JFK ’89), and tracks.
- startup.sh: Env-driven Postgres initialization that applies schema + seed idempotently.
- backup_db.sh / restore_db.sh: Simple, env-aware backup/restore helpers.
- db_visualizer/postgres.env: Convenience env vars for the included simple DB viewer (default port 5001).

Environment variables (with defaults):
- POSTGRES_DB: myapp
- POSTGRES_USER: appuser
- POSTGRES_PASSWORD: dbuser123
- POSTGRES_PORT: 5001

Quick start:
1) Start and initialize Postgres with schema + seed
   - Option A (defaults):
     ./startup.sh
   - Option B (custom):
     POSTGRES_DB=myapp POSTGRES_USER=appuser POSTGRES_PASSWORD=dbuser123 POSTGRES_PORT=5001 ./startup.sh

2) Connect to the database
   - Use the generated helper:
     $(cat db_connection.txt)
   - Or:
     psql -h localhost -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT

3) Verify tables exist
   psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:$POSTGRES_PORT/$POSTGRES_DB -c "\dt"
   Expected tables: users, shows, tracks, favorites

4) Verify seed data
   - Sample shows:
     SELECT show_date, venue, city, state, country FROM shows ORDER BY show_date LIMIT 10;
   - Sample tracks for Cornell ’77:
     SELECT t.track_no, t.title FROM tracks t
     JOIN shows s ON s.id = t.show_id
     WHERE s.show_date = '1977-05-08' AND s.venue = 'Barton Hall, Cornell University'
     ORDER BY t.track_no;

5) DB Viewer (optional)
   - Prepare env:
     source db_visualizer/postgres.env
   - From db_visualizer directory, run:
     npm install
     npm start
   - Open viewer at:
     http://localhost:3000
   The viewer expects POSTGRES_URL/USER/PASSWORD/DB/PORT. The startup script updates db_visualizer/postgres.env automatically.

Backup and Restore:
- Backup (SQL or SQLite archive depending on DB type detected):
  POSTGRES_DB=myapp POSTGRES_USER=appuser POSTGRES_PASSWORD=dbuser123 POSTGRES_PORT=5001 ./backup_db.sh

- Restore:
  POSTGRES_DB=myapp POSTGRES_USER=appuser POSTGRES_PASSWORD=dbuser123 POSTGRES_PORT=5001 ./restore_db.sh

Notes:
- The schema and seed are idempotent. Running startup.sh multiple times is safe.
- Functional indexes on LOWER(text) columns support case-insensitive searches efficiently.
- Passwords in this repo are sample only. In production, ensure secrets are injected via environment variables and never committed.
