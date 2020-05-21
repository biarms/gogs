# biarms/gogs

[![Travis build status](https://api.travis-ci.org/biarms/gogs.svg?branch=master)](https://travis-ci.org/biarms/gogs)

## Overview
The goal of this very simple project is only to publish a docker manifest merging both [Gogs](https://hub.docker.com/r/gogs/gogs/) and [Gogs-rpi](https://hub.docker.com/r/gogs/gogs-rpi) docker images repositories.

Resulting manifests are pushed on [dockerhub](https://hub.docker.com/repository/docker/biarms/gogs).

Current implementation 'retag' the gogs official images into this repo just because:
- The implementation of 'docker pull' (version 19.03.8) is still not smart enough to pull an arm32v7 images if running on a arm64v8 OS;
- The "docker manifest annotate" can't annotate twice the same image.

So, notes that the "arm64v8" images is actually the same as the arm32v7 one.

## How to build locally:
1. Option 1: `make`
2. Option 2: build as on CI thanks to the circleci cli with `make circleci-local-build`
