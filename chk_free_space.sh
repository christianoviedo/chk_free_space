#!/bin/bash
# Shell script para monitorear el uso de disco.
# Envía un correo a $ADMIN si el porcentaje de uso es >= $ALERT.

ADMIN="coviedo@tallerdigital.cl"
ALERT=90

# Excluir filesystems o puntos de montaje que no quieras monitorear
# (usa | para separar varios)
EXCLUDE_LIST="/auto/ripper|/snap"

main_prog() {
  while read -r usep partition; do
    # Quitar el símbolo %
    usep=${usep%\%}

    # Saltar líneas que no tengan número
    if ! [[ "$usep" =~ ^[0-9]+$ ]]; then
      continue
    fi

    if [ "$usep" -ge "$ALERT" ]; then
      mensaje="Running out of space \"$partition ($usep%)\" on server $(hostname), $(date)"
      echo "$mensaje" | mail -s "Alert: Almost out of disk space on $(hostname): $partition $usep%" "$ADMIN"
    fi
  done
}

# Patrones a excluir en la salida de df (a nivel de línea completa)
_excluded="^Filesystem|tmpfs|cdrom"
if [ -n "$EXCLUDE_LIST" ]; then
  _excluded="${_excluded}|${EXCLUDE_LIST}"
fi

# Obtener uso de disco, excluir lo no deseado y procesar
df -P -h \
  | egrep -v "$_excluded" \
  | awk '{print $5 " " $6}' \
  | main_prog
