#!/usr/bin/env bash
load_config() {
  if [[ -f ${PWD}/gitserver.conf ]]; then
    echo "Local Config file found"
    source ${PWD}/gitserver.conf
  fi
  OS_TYPE=$(uname -s)
  case $OS_TYPE in
     Linux) export GITSERVER_USB_HOME=${GITSERVER_USB_HOME:-/media/${USER}/Gitserver};;
    Darwin) export GITSERVER_USB_HOME=${GITSERVER_USB_HOME:-/Volumes/Gitserver};;
         *) echo OS_TYPE $OS_TYPE is not supported; exit 1;;
  esac
  if [[ -f ${GITSERVER_USB_HOME}/gitserver.conf ]]; then
    echo "USB Config file found"
    source ${GITSERVER_USB_HOME}/gitserver.conf
  else
    echo "No config file found, using defaults"
  fi

  GITSERVER_USB_REPO=${GITSERVER_USB_REPO:-${GITSERVER_USB_HOME}/repositories}
  GITSERVER_DOCKER_IMAGE=${GITSERVER_DOCKER_IMAGE:-local/gitserver}
  GITSERVER_DOCKER_IMAGE_TAG=${GITSERVER_DOCKER_IMAGE_TAG:-latest}
  GITSERVER_CONTAINER_PORT=${GITSERVER_CONTAINER_PORT:-9418}
  GITSERVER_HOST_PORT=${GITSERVER_HOST_PORT:-9418}
  GITWEB_CONTAINER_PORT=${GITWEB_CONTAINER_PORT:-1234}
  GITWEB_HOST_PORT=${GITWEB_HOST_PORT:-1234}
}

find_ostype() {
  OS_TYPE=$(uname -s)
  case $OS_TYPE in
     Linux) export GITSERVER_USB_HOME=${GITSERVER_USB_HOME:-/media/${USER}/Gitserver};;
    Darwin) export GITSERVER_USB_HOME=${GITSERVER_USB_HOME:-/Volumes/Gitserver};;
         *) echo OS_TYPE $OS_TYPE is not supported; exit 1;;
  esac
}

usb_home_exists() {
  # find_ostype
  if [[ -d ${GITSERVER_USB_HOME} ]]; then
    return 0
  else
    echo " The directory ${GITSERVER_USB_HOME} does not exist"
    return 1
  fi
}

repo_dir_exists() {
  # find_ostype
  if [[ -d ${GITSERVER_USB_REPO} ]]; then
    return 0
  else
    mkdir ${GITSERVER_USB_REPO}
  fi
}

load_config

if usb_home_exists; then
  echo "Gitserver home directory exists"
else
  echo "Please (re)define GITSERVER_USB_HOME"
  exit 1
fi
