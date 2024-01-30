#!/bin/sh

set -xe

QEMU_VERSION=$1
HOST_TRIPLET=$2
DOCKER_PLATFORM=$3
DOCKER_IMAGE=$4

sudo docker run --privileged --network=host --rm --platform="${DOCKER_PLATFORM}" -v $(pwd):/work "${DOCKER_IMAGE}" \
    sh -c "chmod a+x /work/stage2.sh && /work/stage2.sh ${QEMU_VERSION} ${HOST_TRIPLET}"
