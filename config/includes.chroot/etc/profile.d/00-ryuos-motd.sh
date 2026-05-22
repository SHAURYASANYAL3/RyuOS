#!/bin/bash
# RyuOS Neofetch Identity Script (MOTD)

# Only run if interactive
if [[ $- != *i* ]]; then
    return
fi

CYAN="\e[1;36m"
BLUE="\e[1;34m"
PURPLE="\e[1;35m"
WHITE="\e[1;37m"
GRAY="\e[1;30m"
RESET="\e[0m"

echo -e ""
echo -e " ${CYAN}▗|${RESET}"
echo -e " ${CYAN} |${BLUE}    ____             ____  _____${RESET}   ${WHITE}$(whoami)${RESET}@${CYAN}$(hostname)${RESET}"
echo -e " ${CYAN} |${BLUE}   / __ \__  ____  _/ __ \/ ___/${RESET}   ${GRAY}----------${RESET}"
echo -e " ${CYAN} |${BLUE}  / /_/ / / / / / / / / / \__ \ ${RESET}   ${CYAN}OS${RESET}: RyuOS v0.1-cli $(uname -m)"
echo -e " ${CYAN} |${BLUE} / _, _/ /_/ / /_/ / /_/ /___/ /${RESET}   ${CYAN}Kernel${RESET}: $(uname -r)"
echo -e " ${CYAN} |${BLUE}/_/ |_|\__, /\__,_/\____//____/ ${RESET}   ${CYAN}Uptime${RESET}: $(uptime -p | sed 's/up //')"
echo -e " ${CYAN} |${BLUE}      /____/${RESET}                       ${CYAN}Packages${RESET}: $(dpkg-query -f '.\n' -W 2>/dev/null | wc -l) (dpkg)"
echo -e " ${CYAN}▝|${RESET}                                   ${CYAN}Shell${RESET}: $(basename "$SHELL")"
echo -e "        ${PURPLE}Lightweight Developer${RESET}         ${CYAN}Terminal${RESET}: $(tty | sed 's|/dev/||')"
echo -e "             ${PURPLE}Distribution${RESET}             ${CYAN}CPU${RESET}: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')"
echo -e "                                      ${CYAN}Memory${RESET}: $(free -m | awk '/^Mem:/{print $3"MiB / "$2"MiB"}')"
echo -e ""
echo -e "                                      \e[30m██ \e[31m██ \e[32m██ \e[33m██ \e[34m██ \e[35m██ \e[36m██ \e[37m██ ${RESET}"
echo -e ""
