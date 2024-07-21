#!/bin/sh
# SPDX-FileCopyrightText: 2024 Junde Yhi <junde@yhi.moe>
# SPDX-License-Identifier: CC0-1.0
#
# Convenience script to build and manage the development container.

help() {
  printf 'Usage: %s <build|run|create|start|stop|delete|delete-volume>\n' "$0"
}

build() {
  podman build --file - --tag ghcr.io/weething/dev:latest < dev.containerfile
}

run() {
  podman run \
    --volume ..:/usr/local/src/weething \
    --publish 127.0.0.1:5022:22 \
    --rm \
    --interactive \
    --tty \
    ghcr.io/weething/dev:latest
}

create() {
  podman volume exists wtdev-home
  if [ "$?" -eq 1 ]; then
    podman volume create wtdev-home
  fi

  podman create \
    --name wtdev \
    --volume ..:/usr/local/src/weething \
    --volume wtdev-home:/home/wtdev \
    --publish 127.0.0.1:5022:22 \
    --tty \
    ghcr.io/weething/dev:latest
}

create_uno() {
  podman volume exists wtdev-home
  if [ "$?" -eq 1 ]; then
    podman volume create wtdev-home
  fi

  podman create \
    --name wtdev-uno \
    --volume ..:/usr/local/src/weething \
    --volume wtdev-home:/home/wtdev \
    --device /dev/ttyACM0 \
    --publish 127.0.0.1:5022:22 \
    --tty \
    ghcr.io/weething/dev:latest
}

start() {
  podman container exists wtdev
  if [ "$?" -eq 1 ]; then
    create
  fi

  podman start wtdev
}

stop() {
  podman stop wtdev
}

delete() {
  podman container exists wtdev
  if [ "$?" -eq 0 ]; then
    stop
  fi

  podman container rm wtdev
}

delete_image() {
  podman image rm -f ghcr.io/weething/dev:latest
}

delete_volume() {
  podman volume rm wtdev-home
}

CMD="$1"

case "$CMD" in
  'build') build ;;
  'run') run ;;
  'create') create ;;
  'create-uno') create_uno ;;
  'start') start ;;
  'stop') stop ;;
  'delete') delete ;;
  'delete-image') delete_image ;;
  'delete-volume') delete_volume ;;
  *) help ;;
esac
