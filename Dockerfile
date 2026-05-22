FROM debian:bookworm-slim

# Install core build dependencies
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    live-build \
    debootstrap \
    squashfs-tools \
    syslinux-utils \
    genisoimage \
    make \
    gcc \
    git \
    && rm -rf /var/lib/apt/lists/*

# Work in the mounted project directory
WORKDIR /project

# When running this container, ensure it is run with --privileged
# so that live-build can mount chroot filesystems
CMD ["make", "iso"]
