#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

#wrapper script for running weather on interval

fahrenheit=$1
location=$2
fixedlocation=$3

DATAFILE=/tmp/.neom-tmux-data
LAST_EXEC_FILE="/tmp/.neom-tmux-weather-last-exec"
RUN_EACH=1200
TIME_NOW=$(date +%s)
TIME_LAST=$(cat "${LAST_EXEC_FILE}" 2>/dev/null || echo "0")

main()
{
  current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  if [ "$(expr ${TIME_LAST} + ${RUN_EACH})" -lt "${TIME_NOW}" ]; then
    # Run weather script here
    "$current_dir/weather.sh" "$fahrenheit" "$location" "$fixedlocation" > "${DATAFILE}" 2>/dev/null || true
    echo "${TIME_NOW}" > "${LAST_EXEC_FILE}"
  fi

  if [ -r "${DATAFILE}" ]; then
    cat "${DATAFILE}"
  fi
}

#run main driver function
main
