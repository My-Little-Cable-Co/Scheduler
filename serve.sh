#!/bin/bash
set -e

# The migrate step does not appear to work. Why??
bin/rails db:migrate
rm -f /src/tmp/pids/server.pid
bin/rails server -p 3000 -b '0.0.0.0'
