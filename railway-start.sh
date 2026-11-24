#!/bin/sh
# Railway start wrapper for Fusion. Sizes the Go runtime to the service's
# cgroup limits (Railway shows the host's 32+ CPUs inside a 1 vCPU service)
# and then execs the upstream binary, so its exit code reaches Railway.
set -eu

# --- CPU: GOMAXPROCS from cgroup cpu.max (default 2 when unlimited) ---------
if [ -z "${GOMAXPROCS:-}" ]; then
  cpus=2
  if [ -r /sys/fs/cgroup/cpu.max ]; then
    read -r quota period < /sys/fs/cgroup/cpu.max || true
    if [ "${quota:-max}" != "max" ] && [ -n "${period:-}" ] && [ "$period" -gt 0 ]; then
      cpus=$(( (quota + period - 1) / period ))
    fi
  fi
  [ "$cpus" -lt 1 ] && cpus=1
  [ "$cpus" -gt 8 ] && cpus=8
  export GOMAXPROCS="$cpus"
fi

# --- Memory: soft Go heap limit at ~70% of the cgroup limit -----------------
if [ -z "${GOMEMLIMIT:-}" ] && [ -r /sys/fs/cgroup/memory.max ]; then
  mem=$(cat /sys/fs/cgroup/memory.max)
  if [ "$mem" != "max" ]; then
    export GOMEMLIMIT="$(( mem / 100 * 70 / 1048576 ))MiB"
  fi
fi
# Railway hosts run transparent huge pages "always"; keep the Go heap off them.
export GODEBUG="${GODEBUG:-disablethp=1}"

# --- Fusion settings --------------------------------------------------------
if [ -z "${FUSION_PASSWORD:-}" ] && [ -z "${PASSWORD:-}" ] && [ "${FUSION_ALLOW_EMPTY_PASSWORD:-false}" != "true" ]; then
  echo "railway-start: FUSION_PASSWORD is empty; refusing to start an open reader." >&2
  exit 1
fi
export FUSION_DB_PATH="${FUSION_DB_PATH:-/data/fusion.db}"
export FUSION_PORT="${FUSION_PORT:-${PORT:-8080}}"
# Railway's edge proxy reaches the service from its private 100.64.0.0/10
# range; trust it so login rate limiting sees the real visitor IP.
export FUSION_TRUSTED_PROXIES="${FUSION_TRUSTED_PROXIES:-100.64.0.0/10}"
# Keep feed pulls modest on small plans.
export FUSION_PULL_CONCURRENCY="${FUSION_PULL_CONCURRENCY:-4}"

dbdir=$(dirname "$FUSION_DB_PATH")
mkdir -p "$dbdir"
if ! touch "$dbdir/.write-test" 2>/dev/null; then
  echo "railway-start: $dbdir is not writable; attach a volume at /data." >&2
  exit 1
fi
rm "$dbdir/.write-test"

echo "railway-start: Fusion on :$FUSION_PORT, db $FUSION_DB_PATH, GOMAXPROCS=$GOMAXPROCS GOMEMLIMIT=${GOMEMLIMIT:-unset}"
cd /fusion
exec ./fusion
