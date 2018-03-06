#!/bin/sh

BUILD_STR=""

case $(uname -s) in
  OpenBSD)
    HUMANTIME=$(date -r $BUILD_TS)
    ;;
  *)
    HUMANTIME=$(date --date=@$BUILD_TS)
    ;;
esac

HUMANTIME=$(echo $HUMANTIME|sed 's/:/./g')

if [ -z "$SYSTEM_TAG" ] ; then
  echo "SYSTEM_TAG not in environment, aborting" 1>&2
fi

if [ -z "$BUILD_SHA" ] ; then
  echo "BUILD_SHA not in environment, aborting" 1>&2
  exit 1
else
  BUILD_STR="Build $BUILD_SHA"
  echo "Building $SYSTEM_TAG commit $BUILD_SHA"
  echo "(Timestamp $HUMANTIME)"
fi

if [ -f /etc/issue ] ; then
  set -e
  # loonix
  {
    echo "${SYSTEM_TAG} ${BUILD_STR}"
    echo "Built ${HUMANTIME}"
    echo ""
  } >> /etc/issue
  set +e
fi

if [ -f /etc/gettytab ] ; then
  set -e
  # openbsd
  sed -i.dist -e 's/im=.*:/im=\\r\\n\%s\/\%m '"$SYSTEM_TAG"' '"$BUILD_STR"'\\r\\nBuilt '"$HUMANTIME"' (\\%t)\\r\\n\\r\\n:/' /etc/gettytab
  set +e
fi
