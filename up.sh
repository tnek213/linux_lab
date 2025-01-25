#!/bin/bash

set -e

script_dir=$(
    cd "$(dirname "$0")" || exit 1
    pwd
)

cd "$script_dir" || exit 1

source common.sh

option_skip_cleanup=$([[ $1 == "--skip-cleanup" ]] && echo -n yes || true)

export containers=""

if [ -z "$option_skip_cleanup" ]; then
    trap '(docker kill $containers && docker container rm $containers) &>/dev/null' EXIT
fi

offset=10000

exec_show() {
    echo "$@"
    "$@"
}

while read -r base; do
    image=$(echo "$base" | cut -d: -f1)
    tag=$(echo "$base" | cut -d: -f2)
    container_name="${image}${tag}"

    docker stop "$container_name" 2>/dev/null || true
    docker container rm "$container_name" 2>/dev/null || true

    exec_show docker run -d --cap-add=NET_RAW --name "$container_name" --pull=never \
        -p "$((offset + 22)):22" \
        "$namespace/linux_lab:${image}${tag}"

    containers="$containers $container_name"
    ((offset += 10000))
done <"base_images.txt"

echo
docker ps

read -r -p "Press any key to stop the containers"
