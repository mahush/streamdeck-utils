#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

prog_name=$(basename "${BASH_SOURCE[0]}")

usage() {
  cat <<EOF
Usage: $prog_name subcommand

subcommands:
 mute [false|true|toggle]
 hand [toggle]

Available options:
 -h, --help      Print this help and exit
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

msg() {
  echo >&2 -e ">>>${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

function mute_get() {

    response=$(curl -H "Authorization: OAuth XCKVHCPSTKAPBETH" http://localhost:8249/state)
    msg "${response}" 
    
    case ${response} in
      *"\"in_meeting\":false"*)
        echo "no meeting"
      ;;
      *"\"muted\":true"*)
        echo "true"
      ;;
      *"\"muted\":false"*)
        echo "false"
      ;;
    esac
}

function mute_toggle() {
  sendkeys --application-name "Microsoft Teams" --initial-delay 0.0 --characters "<k:m:shift,command> "
}

function mute() {
  
  if [ $# -eq 0 ]; then
    msg "get mute"
    mute_get
  else
    msg "set mute"
    case $1 in
      "false")
      [ "$(mute_get)" = "true" ] && mute_toggle 
      ;;
      "true")
      [ "$(mute_get)" = "false" ] && mute_toggle 
      ;;
      "toggle")
      mute_toggle
      ;;
      *)
      die "unkown parameter"
      ;;
    esac
  fi  
}
  
subcommand=""
if [ $# -gt 0 ]; then
  subcommand=$1
fi
case $subcommand in
    "" | "-h" | "--help")
      usage
      ;;
    "mute")
      shift
      mute "$@"
      ;;
    *)
      shift
      die "Error: '$subcommand' is not a known subcommand." >&2
      ;;
esac
