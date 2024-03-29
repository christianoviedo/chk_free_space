#!/bin/bash
# set -x
# Shell script to monitor or watch the disk space
# It will send an email to $ADMIN, if the (free available) percentage of space is >= 90%.
# -------------------------------------------------------------------------
# Set admin email so that you can get email.
ADMIN="my_email@email.com"
# set alert level 90% is default
ALERT=90
# Exclude list of unwanted monitoring, if several partions then use "|" to separate the partitions.
# An example: EXCLUDE_LIST="/dev/hdd1|/dev/hdc5"
EXCLUDE_LIST="/auto/ripper|/snap"
#
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#
function main_prog() {
while read output;
do
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1)
  partition=$(echo $output | awk '{print $2}')
  if [ $usep -ge $ALERT ] ; then
    echo "Running out of space \"$partition ($usep%)\" on server $(hostname), $(date)" | \
      mail -s "Alert: Almost out of $1 $usep%" $ADMIN
  fi
done
}

_excluded="^Filesystem|tmpfs|cdrom"
if [ "$EXCLUDE_LIST" != "" ] ; then
  _excluded="${_excluded}|${EXCLUDE_LIST}"
fi

# disk usage
df -H | grep -vE "${_excluded}" | awk '{print $5 " " $6}' | main_prog "disk space"
# inode usage
df -iH | grep -vE "${_excluded}" | awk '{print $5 " " $6}' | main_prog "inodes"
