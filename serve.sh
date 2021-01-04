#!/bin/bash
set -e

# The migrate step does not appear to work. Why??
#rails db:migrate
rails server -b 0.0.0.0
