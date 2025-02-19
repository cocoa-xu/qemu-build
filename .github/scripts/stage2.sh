#!/bin/sh

set -xe

QEMU_VERSION=$1
HOST_TRIPLET=$2

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y curl gcc g++ git build-essential gettext \
    libxml2-utils xsltproc libglib2.0-dev gnutls-dev python3-docutils libslirp-dev \
    libyajl-dev libosinfo-1.0-dev libcurl4-openssl-dev libreadline-dev \
    libnl-3-dev libudev-dev flex libnfs-dev libssh-dev libssh2-1-dev libpng-dev \
    bison libusb-dev libsnappy-dev libsdl2-dev libpam0g-dev libbz2-dev liblzma-dev \
    libzstd-dev libcap-ng-dev libjpeg-dev libvde-dev libvdeplug-dev liblzo2-dev \
    libspice-server-dev libspice-protocol-dev python3 python3-pip python3-setuptools \
    libunistring-dev libp11-kit-dev ninja-build

rm -rf /work/build
mkdir -p /work/build
chmod a+rw /work/build

export ROOTDIR="/work"

pip3 install git+https://github.com/mesonbuild/meson.git
pip3 install tomli

export CURRENT_DIR=$(pwd)
curl -fSL "https://download.qemu.org/qemu-${QEMU_VERSION}.tar.xz" -o "qemu-${QEMU_VERSION}.tar.xz"
XZ_OPT="-k"
tar -xJf "qemu-${QEMU_VERSION}.tar.xz"

# static build slirp
git clone https://gitlab.freedesktop.org/slirp/libslirp.git
cd libslirp
meson setup -Ddefault_library=static build
ninja -C build install

export DESTDIR="${ROOTDIR}/build/qemu-${QEMU_VERSION}"
export XZ_OPT="-e -T0 -9"
rm -rf "${DESTDIR}"
mkdir -p "${DESTDIR}"

cd "${CURRENT_DIR}"
cd "qemu-${QEMU_VERSION}"
./configure --enable-strip --enable-slirp --enable-user --enable-modules --enable-vhost-user --prefix=/usr/local --disable-xen
make -j$(nproc)
make DESTDIR="${DESTDIR}" install

cd "${DESTDIR}"
tar -cJf "${ROOTDIR}/build/qemu-${HOST_TRIPLET}.tar.xz" .
cd "${ROOTDIR}/build"
sha256sum qemu-${HOST_TRIPLET}.tar.xz | tee qemu-${HOST_TRIPLET}.tar.xz.sha256

cd "${CURRENT_DIR}"
rm -rf "qemu-${QEMU_VERSION}"
