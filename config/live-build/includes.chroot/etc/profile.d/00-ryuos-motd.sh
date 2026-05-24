#!/bin/bash
# Lightweight interactive login identity.

case $- in
    *i*) ;;
    *) return 0 ;;
esac

CYAN="\e[1;36m"
WHITE="\e[1;37m"
GRAY="\e[1;30m"
RESET="\e[0m"

printf "\n"
printf " %b____        _   ___  ____%b   %b%s%b@%b%s%b\n" "$CYAN" "$RESET" "$WHITE" "$(whoami)" "$RESET" "$CYAN" "$(hostname)" "$RESET"
printf " %b|  _ \\ _   _| | / _ \\/ ___|%b   %b--------%b\n" "$CYAN" "$RESET" "$GRAY" "$RESET"
printf " %b| |_) | | | | |/ _ \\\\___ \\%b   OS: RyuOS v0.1-cli %s\n" "$CYAN" "$RESET" "$(uname -m)"
printf " %b|  _ <| |_| | | (_) |__) |%b   Kernel: %s\n" "$CYAN" "$RESET" "$(uname -r)"
printf " %b|_| \\_\\\\__,_|_|\\___/____/%b   Uptime: %s\n" "$CYAN" "$RESET" "$(uptime -p | sed 's/^up //')"
printf "                                Memory: %s\n" "$(free -m | awk '/^Mem:/{print $3"MiB / "$2"MiB"}')"
printf "\n"
