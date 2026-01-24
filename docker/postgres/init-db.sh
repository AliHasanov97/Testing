#!/bin/bash
set -e

# This script runs when PostgreSQL container starts for the first time
# It creates the database and user if they don't exist

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create extensions
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

    -- Grant privileges
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;

    -- Log
    SELECT 'Database initialized successfully' AS status;
EOSQL

echo "PostgreSQL initialization completed!"
