SHELL = bash
# .ONESHELL:
# .SHELLFLAGS = -e
# See https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: default all build circleci-local-build check-binaries check-buildx check-docker-login docker-login-if-possible \
        tags push-tags create-manifests create-and-push-manifests

# DOCKER_REGISTRY: Nothing, or 'registry:5000/'
DOCKER_REGISTRY ?= docker.io/
# DOCKER_USERNAME: Nothing, or 'biarms'
DOCKER_USERNAME ?=
# DOCKER_PASSWORD: Nothing, or '********'
DOCKER_PASSWORD ?=
# BETA_VERSION: Nothing, or '-beta-123'
BETA_VERSION ?=
DOCKER_IMAGE_NAME=biarms/gogs
DOCKER_IMAGE_VERSION=0.11.91
DOCKER_IMAGE_TAGNAME=$(DOCKER_REGISTRY)$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)-linux-$(ARCH)$(BETA_VERSION)

default: all

all: create-and-push-manifests

build: tags

# Launch a local build as on circleci, that will call the default target, but inside the 'circleci build and test env'
circleci-local-build: check-docker-login
	@ circleci local execute -e DOCKER_USERNAME="${DOCKER_USERNAME}" -e DOCKER_PASSWORD="${DOCKER_PASSWORD}"

check-binaries:
	@ which docker > /dev/null || (echo "Please install docker before using this script" && exit 1)
	@ which git > /dev/null || (echo "Please install git before using this script" && exit 2)
	@ # deprecated: which manifest-tool > /dev/null || (echo "Ensure that you've got the manifest-tool utility in your path. Could be downloaded from  https://github.com/estesp/manifest-tool/releases/" && exit 3)
	@ DOCKER_CLI_EXPERIMENTAL=enabled docker manifest --help | grep "docker manifest COMMAND" > /dev/null || (echo "docker manifest is needed. Consider upgrading docker" && exit 4)
	@ DOCKER_CLI_EXPERIMENTAL=enabled docker version -f '{{.Client.Experimental}}' | grep "true" > /dev/null || (echo "docker experimental mode is not enabled" && exit 5)
	# Debug info
	@ echo "DOCKER_IMAGE_TAGNAME: ${DOCKER_IMAGE_TAGNAME}"
	# @ echo "BUILD_DATE: ${BUILD_DATE}"
	# @ echo "VCS_REF: ${VCS_REF}"

check-buildx: check-binaries
	# Next line will fail if docker server can't be contacted
	docker version
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx version

check-docker-login: check-binaries
	@ if [[ "${DOCKER_USERNAME}" == "" ]]; then echo "DOCKER_USERNAME and DOCKER_PASSWORD env variables are mandatory for this kind of build"; exit -1; fi

docker-login-if-possible: check-binaries
	if [[ ! "${DOCKER_USERNAME}" == "" ]]; then echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin; fi

tags: check-binaries
	docker pull gogs/gogs:${DOCKER_IMAGE_VERSION}
	docker pull gogs/gogs-rpi:${DOCKER_IMAGE_VERSION}
	docker tag "gogs/gogs:${DOCKER_IMAGE_VERSION}"     "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}"
	docker tag "gogs/gogs-rpi:${DOCKER_IMAGE_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}"
	docker tag "gogs/gogs-rpi:${DOCKER_IMAGE_VERSION}" "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}"

push-tags: check-docker-login docker-login-if-possible tags
	docker push "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}"
	docker push "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}"
	docker push "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}"

create-manifests: push-tags
	# biarms/gogs:0.11.91
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}"
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}" --os linux --arch arm --variant v7
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}" --os linux --arch arm64 --variant v8
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}" --os linux --arch amd64
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}"
	# biarms/gogs:latest
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}"
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm32-v7${BETA_VERSION}" --os linux --arch arm --variant v7
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-arm64-v8${BETA_VERSION}" --os linux --arch arm64 --variant v8
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}" "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-linux-amd64${BETA_VERSION}" --os linux --arch amd64
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}"

create-and-push-manifests: push-tags create-manifests
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}"
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push "${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}"