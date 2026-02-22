#!/bin/bash
set -u

QUIET=0
WARN=0
FAIL=0

supports_color() { [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; }
if supports_color; then
  G="$(tput setaf 2)"; Y="$(tput setaf 3)"; R="$(tput setaf 1)"; Z="$(tput sgr0)"
else
  G=""; Y=""; R=""; Z=""
fi

tag() {
  case "$1" in
    OK) echo "${G}[OK]${Z}" ;;
    WARNING) echo "${Y}[WARNING]${Z}" ;;
    CRITICAL) echo "${R}[CRITICAL]${Z}" ;;
    FAIL) echo "${R}[FAIL]${Z}" ;;
  esac
}

SERVICES=()
for a in "$@"; do
  case "$a" in
    --quiet) QUIET=1 ;;
    *) SERVICES+=("$a") ;;
  esac
done
[[ ${#SERVICES[@]} -eq 0 ]] && SERVICES=(ssh cron docker)

echo "========================================"
echo "  SYSTEM HEALTH CHECK - $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
echo

echo "-- DISK USAGE --"
while read -r fs size used avail usep mnt; do
  pct="${usep%\%}"
  lvl="OK"
  if [[ "$pct" -ge 95 ]]; then lvl="CRITICAL"; ((FAIL++))
  elif [[ "$pct" -ge 80 ]]; then lvl="WARNING"; ((WARN++))
  fi
  [[ "$QUIET" -eq 1 && "$lvl" == "OK" ]] && continue
  printf "%-18s %-18s %4s  %s\n" "$fs" "$mnt" "$usep" "$(tag "$lvl")"
done < <(df -P --exclude-type=tmpfs --exclude-type=devtmpfs | awk 'NR>1{print $1,$2,$3,$4,$5,$6}')
echo

echo "-- MEMORY --"
read -r t u f s bc a < <(free -b | awk '/^Mem:/ {print $2,$3,$4,$5,$6,$7}')
pct=$(( a * 100 / t ))
lvl="OK"
if [[ "$pct" -lt 10 ]]; then lvl="WARNING"; ((WARN++)); fi
if [[ "$QUIET" -eq 0 || "$lvl" != "OK" ]]; then
  echo "Available: ${pct}%  $(tag "$lvl")"
fi
echo

echo "-- SERVICES --"
for svc in "${SERVICES[@]}"; do
  if systemctl is-active --quiet "$svc"; then
    lvl="OK"; st="active"
  else
    lvl="FAIL"; st="$(systemctl is-active "$svc" 2>/dev/null || echo inactive)"; ((FAIL++))
  fi
  [[ "$QUIET" -eq 1 && "$lvl" == "OK" ]] && continue
  printf "%-12s %-10s %s\n" "$svc" "$st" "$(tag "$lvl")"
done
echo

echo "========================================"
echo "Summary: ${WARN} warning(s), ${FAIL} failure(s)"
echo "========================================"

if [[ "$WARN" -gt 0 || "$FAIL" -gt 0 ]]; then exit 1; fi
exit 0