# shellcheck shell=sh
# Post-login welcome (once per session).
[ -n "$RYUOS_WELCOME_DONE" ] && return 0
[ ! -t 1 ] && return 0
export RYUOS_WELCOME_DONE=1

printf '\033[1;36m'
cat << 'EOF'

  RyuOS ready
  Try: ryush, sys-monitor, ryu-benchmark

EOF
printf '\033[0m'
