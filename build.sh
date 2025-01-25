#!/bin/bash

set -e

script_dir=$(
    cd "$(dirname "$0")" || exit 1
    pwd
)

cd "$script_dir" || exit 1

source common.sh

build() {
    while read -r base; do
        image=$(echo "$base" | cut -d: -f1)
        tag=$(echo "$base" | cut -d: -f2)
        docker build -f Dockerfile --build-arg BASE_IMAGE="$image:$tag" -t "$namespace/linux_lab:${image}${tag}" .
    done <"base_images.txt"
}

build

select choice in run rebuild publish exit; do
    if [[ $choice == "run" ]]; then
        ./up.sh # pass --skip-cleanup to keep containers
    elif [[ $choice == "rebuild" ]]; then
        build
    elif [[ $choice == "publish" ]]; then
        if ! docker info | grep -q "Username:"; then
            echo "You are not logged in. Please log in first." >&2
            exit 1
        fi

        docker push -a "$namespace/linux_lab"
        exit 0
    elif [[ $choice == "exit" ]]; then
        exit 0
    fi
done
