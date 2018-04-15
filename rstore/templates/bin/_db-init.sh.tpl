#!/bin/bash

set -ex
export HOME=/tmp

pgsql_superuser_cmd () {
  DB_COMMAND="$1"

  psql \
  -h ${DB_FQDN} \
  -p ${DB_PORT} \
  -U ${DB_ADMIN_USER} \
  --command="${DB_COMMAND}"
}

# Create db
pgsql_superuser_cmd "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || pgsql_superuser_cmd "CREATE DATABASE $DB_NAME"

# Create db user
pgsql_superuser_cmd "SELECT * FROM pg_roles WHERE rolname = '$DB_SERVICE_USER';" | tail -n +3 | head -n -2 | grep -q 1 || \
    pgsql_superuser_cmd "CREATE ROLE ${DB_SERVICE_USER} LOGIN PASSWORD '$DB_SERVICE_PASSWORD';"

# Grant permissions to user
pgsql_superuser_cmd "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME to $DB_SERVICE_USER;"
