#!/bin/bash

set -Eeo pipefail

if [[ "$UID" != '0' ]]; then
  echo "Скрипт ${0##*/} должен выполняться с правами root" >&2
  exit 1
fi

if [[ -n "$host_uid" ]]; then
  if [[ -z "$host_gid" ]]; then
    echo '$host_uid определено, $host_gid нет' >&2
    exit 1
  fi
  if [[ "$host_uid" =~ ^(0|.*[^0-9]) ]]; then
    echo 'Значение $host_uid должно быть числом >= 1000' >&2
    exit 1
  fi
  if (( "$host_uid" < 1000 )); then
    echo 'Значение $host_uid должно быть >= 1000' >&2
    exit 1
  fi
fi

if [[ -n "$host_gid" ]]; then
  if [[ -z "$host_uid" ]]; then
    echo '$host_gid определено, $host_uid нет' >&2
    exit 1
  fi
  if [[ "$host_gid" =~ ^(0|.*[^0-9]) ]]; then
    echo 'Значение $host_gid должно быть числом >= 1000' >&2
    exit 1
  fi
  if (( "$host_gid" < 1000 )); then
    echo 'Значение $host_gid должно быть >= 1000' >&2
    exit 1
  fi
fi

if [[ "${1:0:1}" = '-' ]]; then
  set -- ansible-playbook "$@"
fi

if [[ -z "$host_uid" && -z "$host_gid" ]]; then
  exec "$@"
else
  inner_name=__ansible__
  groupadd -g "$host_gid" -o "$inner_name"
  useradd -d /home/ansible -m -u "$host_uid" -o -g "$host_gid" "$inner_name" || echo "$?"
  exec gosu "$inner_name" "$@"
fi
