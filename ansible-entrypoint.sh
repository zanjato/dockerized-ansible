#!/bin/bash

set -Eeuo pipefail

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
  inner_name='__ansible__'
  if ! getent group "${host_gid}" &>/dev/null; then
    gid_max="$(awk '/^GID_MAX\s+[0-9]+/{print $2}' /etc/login.defs)"
    if [[ -z "${gid_max:-}" ]]; then
      echo -e "GID_MAX\t${host_gid}" >>/etc/login.defs
    elif (( gid_max < host_gid )); then
      sed -i "s/^\(GID_MAX\s\+\).\+/\1${host_gid}/" /etc/login.defs
    fi
    groupadd -g "$host_gid" "$inner_name"
  fi
  if ! getent passwd "${host_uid}" &>/dev/null; then
    uid_max="$(awk '/^UID_MAX\s+[0-9]+/{print $2}' /etc/login.defs)"
    if [[ -z "${uid_max:-}" ]]; then
      echo -e "UID_MAX\t${host_uid}" >>/etc/login.defs
    elif (( uid_max < host_uid )); then
      sed -i "s/^\(UID_MAX\s\+\).\+/\1${host_uid}/" /etc/login.defs
    fi
    useradd -d "/home/${inner_name}" -m -u "$host_uid" -g "$host_gid" "$inner_name"
  fi
  exec gosu "$inner_name" "$@"
fi
