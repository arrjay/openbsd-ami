#!/bin/sh

sys=$(uname -s)
case "${sys}" in
  OpenBSD)
    set -e
    echo "installpath = $MIRROR/pub/OpenBSD/$(uname -r)/packages/$(machine -a)" > /etc/pkg.conf
    echo "$MIRROR/pub/OpenBSD/" > /etc/installurl
    set +e
    ;;
esac
