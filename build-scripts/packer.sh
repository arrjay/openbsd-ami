#!/usr/bin/env bash

set -x

type qemu-system-x86_64 > /dev/null 2>&1
if [ "${?}" -ne 0 ] ; then
  if [ -f /usr/libexec/qemu-kvm ] ; then
    PACKER_BUILD_FLAGS+=" -var qemu_binary=/usr/libexec/qemu-kvm"
  fi
else
  PACKER_BUILD_FLAGS+=" -var qemu_binary=qemu-system-x86_64"
fi

if [ -z "${DISPLAY}" ] ; then
  PACKER_BUILD_FLAGS+=" -var packer_qemu_headless=true"
fi

# this starts setting packer variables
PACKER_BUILD_FLAGS+=" -var build_sha=$(git rev-parse HEAD)"
PACKER_BUILD_FLAGS+=" -var build_tag=$(git describe --exact-match HEAD 2> /dev/null)"
PACKER_BUILD_FLAGS+=" -var build_ts=${TIMESTAMP}"

packer build ${PACKER_BUILD_FLAGS} packer.json
