#!/bin/bash -e

NCPUS=$(grep -c ^processor /proc/cpuinfo)

mkdir -p $PWD/localdisk
mkdir -p $PWD/import

STX_BUILD_DOCKER_IMG="starlingxabc/stx-build"
STX_MANIFEST='https://opendev.org/starlingx/manifest/raw/branch/master/default.xml'
STX_RELEASE_URL='http://mirror.starlingx.cengn.ca/mirror/starlingx/master/centos/latest_build'

STX_BUILD_DOCKER_OPTS=" --name stx-ci --rm --privileged=true -u builder
    --env http_proxy --env https_proxy --env no_proxy
    --env HTTP_PROXY --env HTTPS_PROXY --env NO_PROXY
    --env STX_MANIFEST=$STX_MANIFEST
    --env STX_RELEASE_URL=$STX_RELEASE_URL
    --env MYPROJECTNAME=starlingx
    -v /dev:/dev
    -v $PWD:/stx-ci
    -v $PWD/import:/import
    -v $PWD/localdisk:/localdisk
    -v $HOME/.ssh:/home/builder/.ssh
    -v $HOME/.gitconfig:/home/builder/.gitconfig
    -it
    $STX_BUILD_DOCKER_IMG"

if [ -z "$1" ]; then
	sudo docker run $STX_BUILD_DOCKER_OPTS /bin/bash -c -x -e "/stx-ci/scripts/stx-repo-init"
	sudo docker run $STX_BUILD_DOCKER_OPTS /bin/bash -c -x -e "/stx-ci/scripts/stx-mirror-init"
	sudo docker run $STX_BUILD_DOCKER_OPTS /bin/bash -c -x -e "/stx-ci/scripts/stx-build"
else
	sudo docker run $STX_BUILD_DOCKER_OPTS /bin/bash -c -x -e "$@"
fi
