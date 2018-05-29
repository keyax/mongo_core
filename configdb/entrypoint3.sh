#!/bin/bash
set -e
#su -l mongodb
if [ "${1:0:1}" = '-' ]; then
	set -- mongod "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'mongod' -a "$(id -u)" = '0' ]; then
	chown -R mongodb /data/configdb /data/db
	exec su mongodb "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'mongod' ]; then
	numa='numactl --interleave=all'
 	if $numa true &> /dev/null; then
		  set -- $numa "$@"
  fi
fi
# exec su mongodb
eval "$@"
 #--auth --bind_ip_all -f /data/configdb/mongod.conf
