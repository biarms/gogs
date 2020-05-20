SHELL = bash

 # DOCKER_REGISTRY: Nothing, or 'registry:5000/'
DOCKER_REGISTRY ?=
 # DOCKER_USERNAME: Nothing, or 'biarms'
DOCKER_USERNAME ?=
 # DOCKER_PASSWORD: Nothing, or '********'
DOCKER_PASSWORD ?=
 # BETA_VERSION: Nothing, or '-beta-123'
BETA_VERSION ?=
DOCKER_IMAGE_NAME=biarms/gogs
DOCKER_IMAGE_VERSION=0.11.91
DOCKER_IMAGE_TAGNAME=$(DOCKER_REGISTRY)$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)-linux-$(ARCH)$(BETA_VERSION)

default: create-and-push-manifests

tags: check-binaries
	docker pull gogs/gogs:${DOCKER_IMAGE_VERSION}
	docker pull gogs/gogs-rpi:${DOCKER_IMAGE_VERSION}
	docker tag "gogs/gogs:${DOCKER_IMAGE_VERSION}"     "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}"
	docker tag "gogs/gogs-rpi:${DOCKER_IMAGE_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}"
	docker tag "gogs/gogs-rpi:${DOCKER_IMAGE_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}"

push-tags: check-docker-login tags
	docker push "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}"
	docker push "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}"
	docker push "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}"

create-manifests: push-tags
	# biarms/gogs:0.11.91
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}"
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}" --os linux --arch arm --variant v7
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}" --os linux --arch arm64 --variant v8
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}" --os linux --arch amd64
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}"
	# biarms/gogs:latest
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend "${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}"
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}" --os linux --arch arm --variant v7
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}" --os linux --arch arm64 --variant v8
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}" --os linux --arch amd64
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}"

create-and-push-manifests: check-docker-login push-tags create-manifests docker-login-if-possible
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}"
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push "${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}"

docker-login-if-possible: check-binaries
	if [[ ! "${DOCKER_USERNAME}" == "" ]]; then echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin; fi

check-docker-login: check-binaries
	@ if [[ "${DOCKER_USERNAME}" == "" ]]; then echo "DOCKER_USERNAME and DOCKER_PASSWORD env variables are mandatory for this kind of build"; exit -1; fi

check-binaries:
	@ which docker > /dev/null || (echo "Please install docker before using this script" && exit 1)
	@ DOCKER_CLI_EXPERIMENTAL=enabled docker manifest --help | grep "docker manifest COMMAND" > /dev/null || (echo "docker manifest is needed. Consider upgrading docker" && exit 4)
	@ DOCKER_CLI_EXPERIMENTAL=enabled docker version -f '{{.Client.Experimental}}' | grep "true" > /dev/null || (echo "docker experimental mode is not enabled" && exit 5)
