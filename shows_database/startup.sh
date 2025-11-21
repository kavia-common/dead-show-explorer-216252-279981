#!/bin/bash
set -euo pipefail

# Env-driven PostgreSQL startup and initialization with schema + seed
# Defaults aligned with running container map (port 5001)
DB_NAME="${POSTGRES_DB:-myapp}"
DB_USER="${POSTGRES_USER:-appuser}"
DB_PASSWORD="${POSTGRES_PASSWORD:-dbuser123}"
DB_PORT="${POSTGRES_PORT:-5001}"

echo "Starting PostgreSQL setup (DB=${DB_NAME}, USER=${DB_USER}, PORT=${DB_PORT})..."

# Find PostgreSQL version and set paths
PG_VERSION=$(ls /usr/lib/postgresql/ 2>/dev/null | head -1)
if [ -z "${PG_VERSION}" ]; then
  echo "ERROR: PostgreSQL binaries not found under /usr/lib/postgresql"
  exit 1
fi
PG_BIN="/usr/lib/postgresql/${PG_VERSION}/bin"
echo "Found PostgreSQL version: ${PG_VERSION}"

# Quick helper to run psql as postgres
psql_sysdb() {
  sudo -u postgres "${PG_BIN}/psql" -p "${DB_PORT}" -d "$1"
}

# Check if PostgreSQL is already running on the specified port
if sudo -u postgres "${PG_BIN}/pg_isready" -p "${DB_PORT}" > /dev/null 2>&1; then
  echo "PostgreSQL is already running on port ${DB_PORT}."
else
  # Also check if process exists (fallback)
  if pgrep -f "postgres.*-p ${DB_PORT}" > /dev/null 2>&1; then
    echo "Found existing PostgreSQL process on port ${DB_PORT}"
  else
    # Initialize data directory if needed
    if [ ! -f "/var/lib/postgresql/data/PG_VERSION" ]; then
      echo "Initializing PostgreSQL cluster..."
      sudo -u postgres "${PG_BIN}/initdb" -D /var/lib/postgresql/data
    fi

    echo "Starting PostgreSQL server on port ${DB_PORT}..."
    sudo -u postgres "${PG_BIN}/postgres" -D /var/lib/postgresql/data -p "${DB_PORT}" >/tmp/postgres.log 2>&1 &
    sleep 3
  fi

  # Wait for readiness
  for i in {1..20}; do
    if sudo -u postgres "${PG_BIN}/pg_isready" -p "${DB_PORT}" > /dev/null 2>&1; then
      echo "PostgreSQL is ready."
      break
    fi
    echo "Waiting for PostgreSQL to become ready... ($i/20)"
    sleep 1
  done
fi

# Create DB and user with privileges
echo "Ensuring database and role exist..."
# Create role + set password idempotently
sudo -u postgres "${PG_BIN}/psql" -p "${DB_PORT}" -d postgres <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${DB_USER}') THEN
    CREATE ROLE ${DB_USER} WITH LOGIN PASSWORD '${DB_PASSWORD}';
  ELSE
    ALTER ROLE ${DB_USER} WITH LOGIN PASSWORD '${DB_PASSWORD}';
  END IF;
END
\$\$;
SQL

# Create database if it doesn't exist
sudo -u postgres "${PG_BIN}/psql" -p "${DB_PORT}" -d postgres <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}') THEN
    PERFORM dblink_connect('dbname=postgres');
  END IF;
END
\$\$;
CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};
ALTER DATABASE ${DB_NAME} OWNER TO ${DB_USER};
SQL
# Ignore error if DB exists
if [ $? -ne 0 ]; then
  echo "Database may already exist; continuing."
fi

# Schema-level privileges in target DB
psql_sysdb "${DB_NAME}" <<SQL
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
GRANT USAGE, CREATE ON SCHEMA public TO ${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO ${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TYPES TO ${DB_USER};
SQL

# Apply schema.sql and seed.sql safely and idempotently
echo "Applying schema.sql..."
if [ -f "schema.sql" ]; then
  psql_sysdb "${DB_NAME}" < schema.sql
else
  echo "WARNING: schema.sql not found; skipping schema application."
fi

echo "Applying seed.sql..."
if [ -f "seed.sql" ]; then
  psql_sysdb "${DB_NAME}" < seed.sql
else
  echo "WARNING: seed.sql not found; skipping seed application."
fi

# Save connection helpers
echo "psql postgresql://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}" > db_connection.txt
echo "Connection string saved to db_connection.txt"

# Write db_visualizer env aligned with effective port
mkdir -p db_visualizer
cat > db_visualizer/postgres.env << EOF
export POSTGRES_URL="postgresql://localhost:${DB_PORT}/${DB_NAME}"
export POSTGRES_USER="${DB_USER}"
export POSTGRES_PASSWORD="${DB_PASSWORD}"
export POSTGRES_DB="${DB_NAME}"
export POSTGRES_PORT="${DB_PORT}"
EOF

echo "PostgreSQL setup complete!"
echo "Database: ${DB_NAME}"
echo "User: ${DB_USER}"
echo "Port: ${DB_PORT}"
echo ""
echo "Environment variables saved to db_visualizer/postgres.env"
echo "To use with Node.js viewer, run: source db_visualizer/postgres.env"
echo "To connect:"
echo "psql -h localhost -U ${DB_USER} -d ${DB_NAME} -p ${DB_PORT}"
echo "$(cat db_connection.txt)"
