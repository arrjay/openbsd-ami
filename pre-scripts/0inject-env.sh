#!/usr/bin/env bash

. /etc/os-release

ci_shyaml() {
  local SHYAML_TAG SHYAML_DIR SHYAML_SRC
  SHYAML_TAG=0.5.0
  SHYAML_DIR=com.github.0k.shyaml
  SHYAML_SRC=https://github.com/0k/shyaml
  [ -e "./vendor/${SHYAML_DIR}/shyaml" ] || \
  {
   mkdir -p vendor && ( cd vendor && \
    git clone "${SHYAML_SRC}" "${SHYAML_DIR}" && cd "${SHYAML_DIR}" &&\
    git checkout "${SHYAML_TAG}" )
  } >&2
  python "./vendor/${SHYAML_DIR}/shyaml" "${@}" < environment.yml
}

load_env_from_yaml () {
  local key firstexpansion secondexpansion
  for key in $(ci_shyaml keys environment) ; do
    printf 'key: %s\n' "${key}"
    firstexpansion=$(ci_shyaml get-value "environment.${key}")
    secondexpansion="$(eval echo "${firstexpansion}")"
    printf 'value: %s\n' "${secondexpansion}"
    case "${key}" in
      TERM) [ ! -z "${TERM+x}" ] && continue ;;
    esac
    printf -v "${key}" "%s" "${secondexpansion}" && export "${key}" && echo "set,exported"
    printf 'export %s="%s"\n' "${key}" "${secondexpansion}" >> "${BASH_SCRATCHPAD}"
  done
}

case "${ID_LIKE}" in
  *rhel*)
    pip_pkg="python2-pip"
    pkgin() { sudo yum -y install "${@}"; }
  ;;
  *debian*)
    pip_pkg="python-pip"
    pkgin() { sudo apt-get -q -y install "${@}"; }
  ;;
esac

install_pyyaml () {
  type pip 2> /dev/null 1>&2 || pkgin "${pip_pkg}"
  type git 2> /dev/null 1>&2 || pkgin "git"
  python -c 'import yaml' || pip install --user pyyaml
}

[ -z "${BASH_SCRATCHPAD}" ] && export BASH_SCRATCHPAD=$(mktemp)
{
  [[ "${BASH_SOURCE[0]}" == "${0}" ]] && { echo "you will want to source this for interactive development" 1>&2 && exit 1; }
  install_pyyaml
  load_env_from_yaml
}

[ -z "${CIRCLE_ARTIFACTS}" ] && export CIRCLE_ARTIFACTS=$(mktemp -d /tmp/circle-artifacts.XXXXXX)
echo "BASH_SCRATCHPAD at ${BASH_SCRATCHPAD}"
echo "CIRCLE_ARTIFACTS at ${CIRCLE_ARTIFACTS}"

[ -z "${USER}" ] && export USER=$(whoami)
printf 'export USER="%s"\n' "${USER}" >> "${BASH_SCRATCHPAD}"

unset -f load_env_from_yaml
