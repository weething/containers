# SPDX-FileCopyrightText: 2024 Junde Yhi <junde@yhi.moe>
# SPDX-License-Identifier: CC0-1.0
#
# Recipe for building a development container for WeeThing projects.
#
# Remember to publish port 22 to the host: `-p 127.0.0.1:5022:22` will set up
# port forwarding on localhost port 5022 to the sshd inside container. Then use
# an editor with SSH remote connection to enter the container with the root
# account. You're advised to use Podman to run the container in rootless mode.
# In this way, root inside the container is the current user on the host. The
# root account inside the container is configured to have no password for
# convenience. Although it's a container, such setup isn't secure. Make sure
# not to expose the container sshd to anywhere except the loopback network!

FROM ubuntu:24.04

# Set up environment variables that are needed both during build-time and run-
# time (pipx for now).
ENV PIPX_HOME=/usr/local/lib/pipx PIPX_BIN_DIR=/usr/local/bin \
PIPX_MAN_DIR=/usr/local/share/man

# Software installation via distribution.
RUN apt-get update -y && \
apt-get install --no-install-recommends -y catatonit curl openssh-server git \
pipx cmake ninja-build clangd gcc g++ gcc-avr binutils-avr avr-libc avrdude \
simavr doxygen graphviz && \
rm -fr /var/lib/apt/lists/*

# Software installation via PyPI.
RUN for p in meson platformio pyocd reuse; do pipx install $p; done && \
rm -fr /root/.cache /usr/local/lib/pipx/{.cache,logs}

# Set up authentication.
RUN passwd -d root && \
printf 'PermitRootLogin yes\nPermitEmptyPasswords yes\n' > \
/etc/ssh/sshd_config.d/60-wtdev.conf

# Script to start the container.
RUN printf '#!/bin/sh\n\
set -eu\n\
service ssh start\n\
exec /usr/bin/catatonit -P\n' > /docker-entrypoint.sh && \
chmod 0755 /docker-entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/docker-entrypoint.sh"]

LABEL org.opencontainers.image.description="WeeThing Development Container" \
org.opencontainers.image.licenses="GPL-3.0-or-later"
