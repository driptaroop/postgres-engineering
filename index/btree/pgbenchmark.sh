#!/usr/bin/env zsh

set -e -u -o pipefail

PGPASSWORD='password' pgbench -f ./query.sql -t 100 -h localhost -d postgres -U postgres