#!/usr/bin/env bash

start_gitserver() {
  if repo_dir_exists; then
    echo "Starting Gitserver docker container in read/write mode"
  else
    echo "${GITSERVER_USB_REPO} does not exist"
    exit 1
  fi

  docker run -d --rm\
    --name=gitserver \
    -p ${GITSERVER_HOST_PORT}:${GITSERVER_CONTAINER_PORT} \
    -p ${GITWEB_HOST_PORT}:${GITWEB_CONTAINER_PORT} \
    -v ${GITSERVER_USB_REPO}:/srv/git \
    ${GITSERVER_DOCKER_IMAGE}:${GITSERVER_DOCKER_IMAGE_TAG}
}

start_readonly() {
  if repo_dir_exists; then
    echo "Starting Gitserver docker container in readonly mode"
  else
    echo "${GITSERVER_USB_REPO} does not exist"
    exit 1
  fi

  docker run -d --rm\
    --name=gitserver \
    -p ${GITSERVER_HOST_PORT}:${GITSERVER_CONTAINER_PORT} \
    -p ${GITWEB_HOST_PORT}:${GITWEB_CONTAINER_PORT} \
    -v ${GITSERVER_USB_REPO}:/srv/git \
    ${GITSERVER_DOCKER_IMAGE}:${GITSERVER_DOCKER_IMAGE_TAG} serve
}

stop_gitserver() {
  echo "Stopping and removing Gitserver docker container"
  docker stop gitserver
}

start_gitweb() {
  echo "Starting Gitserver Web GUI"
  docker exec -it gitserver git webstart
}

stop_gitweb() {
  echo "Stopping Gitserver Web GUI"
  docker exec -it gitserver git webstop
}

build_gitserver() {
  echo "Building Gitserver docker image"
  GITSERVER_BUILD_HOME=${GITSERVER_USB_HOME}/build

  if [[ -d ${GITSERVER_BUILD_HOME}/ssh ]]; then
    rm -rf ${GITSERVER_BUILD_HOME}/ssh && mkdir ${GITSERVER_BUILD_HOME}/ssh
  fi

  ssh-keygen -b 2048 -t rsa -f ${GITSERVER_BUILD_HOME}/ssh/gitclient_rsa -q -N ""
  cp ${GITSERVER_BUILD_HOME}/ssh/gitclient_rsa.pub ${GITSERVER_BUILD_HOME}/ssh/authorized_keys

  docker build -t ${GITSERVER_DOCKER_IMAGE}:${GITSERVER_DOCKER_IMAGE_TAG} ${GITSERVER_BUILD_HOME}
}

init_repo() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: $0 initrepo REPOSITORY_NAME"
    exit 1
  fi
  PROJECT=$1

  if repo_dir_exists; then
    echo "Creating ${PROJECT} respository"
  else
    echo "Unable to create local repository directory ${GITSERVER_USB_HOME}/${PROJECT}"
    exit 1
  fi

  docker run -it \
    --entrypoint /bin/ash \
    -v ${GITSERVER_USB_REPO}:/srv/git \
    ${GITSERVER_DOCKER_IMAGE}:${GITSERVER_DOCKER_IMAGE_TAG} create-repo $PROJECT
}

login_gitserver() {
  echo "Logging into the Gitserver container"
  if [[ -n $GITUSER ]]; then # login as root
    docker exec -it --user ${GITUSER} -w /git gitserver /bin/ash
  else # loing as gituser
    docker exec -it gitserver /bin/ash
  fi
}
