#!/bin/bash
# Shell script to monitor disk space
# It will send an email to $ADMIN if the usage percentage is >= ALERT.

ADMIN="my_email@email.com"
ALERT=90
EXCLUDE_LIST="/auto/ripper|/snap"

function main_prog() {
  while read usep partition; do
    # Quitar el símbolo % si viene con él
    usep=${usep%\%}

    # Saltar líneas que no tengan número
    if ! [[ "$usep" =~ ^[0-9]+$ ]]; then
      continue
    fi

    if [ "$usep" -ge "$ALERT" ]; then
      echo "Running out of space \"$partition ($usep%)\" on server $(hostname), $(date)" | \
        mail -s "Alert: Almost out of disk space on $(hostname): $partition $usep%" "$ADMIN"
    fi
  done
}

_excluded="^Filesystem|tmpfs|cdrom"
if [ -n "$EXCLUDE_LIST" ]; then
  _excluded="${_excluded}|${EXCLUDE_LIST}"
fi

# Obtener uso de disco y pasarlo a la función
df -P -h | awk 'NR>1 {print $5 " " $6}' | egrep -v "$_excluded" | main_prog
