#!/bin/bash

/usr/sbin/sshd &

[ $# -gt 0 ] && "$@"

sleep infinity &
# shellcheck disable=SC2064
trap "kill -9 $! || true" INT TERM

wait
