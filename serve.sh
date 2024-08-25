#!/bin/bash
set -e

# The migrate step does not appear to work. Why??
bin/rails db:migrate
bin/rails server -b 0.0.0.0
