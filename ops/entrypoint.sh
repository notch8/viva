#!/bin/bash -l
set -e

# Remove a potentially pre-existing server.pid for Rails.
# Check if the server.pid file exists
if [ -f tmp/pids/server.pid ]; then
  # Remove the server.pid file
  rm -f tmp/pids/server.pid
fi

bundle check || bundle install

echo "Starting $@"
# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
