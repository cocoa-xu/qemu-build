#!/bin/sh

set -xe

QEMU_VERSION=$1
HOST_TRIPLET=$2

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y curl gcc g++ git build-essential gettext \
    libxml2-utils xsltproc libglib2.0-dev gnutls-dev python3-docutils libslirp-dev \
    libyajl-dev meson libosinfo-1.0-dev libcurl4-openssl-dev libreadline-dev \
    libnl-3-dev libudev-dev flex libnfs-dev libssh-dev libssh2-1-dev libpng-dev \
    bison libusb-dev libsnappy-dev libsdl2-dev libpam0g-dev libbz2-dev liblzma-dev \
    libzstd-dev libcap-ng-dev libjpeg-dev libvde-dev libvdeplug-dev liblzo2-dev \
    libspice-server-dev libspice-protocol-dev python3-full python3-pip python3-setuptools

mkdir -p /work/build
chmod a+rw /work/build

export ROOTDIR="$(pwd)"
export DESTDIR="${ROOTDIR}/build/qemu-${QEMU_VERSION}"

curl -fSL "https://download.qemu.org/qemu-${QEMU_VERSION}.tar.xz" -o "qemu-${QEMU_VERSION}.tar.xz"
tar -xJf "qemu-${QEMU_VERSION}.tar.xz"
cd "qemu-${QEMU_VERSION}"
./configure --enable-strip --enable-user --enable-modules --enable-vhost-user --prefix=/usr/local --disable-xen
make -j$(nproc)
make DESTDIR="${DESTDIR}" install

cd "${DESTDIR}"
tar -czf "${ROOTDIR}/build/qemu-${HOST_TRIPLET}.tar.gz" .
