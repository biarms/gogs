# biarms/gogs

![GitHub release (latest by date)](https://img.shields.io/github/v/release/biarms/gogs?label=Latest%20Github%20release&logo=Github)
![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/biarms/gogs?include_prereleases&label=Highest%20GitHub%20release&logo=Github&sort=semver)

[![TravisCI build status image](https://img.shields.io/travis/biarms/gogs/master?label=Travis%20build&logo=Travis)](https://travis-ci.org/biarms/gogs)
[![CircleCI build status image](https://img.shields.io/circleci/build/gh/biarms/gogs/master?label=CircleCI%20build&logo=CircleCI)](https://circleci.com/gh/biarms/gogs)

[![Docker Pulls image](https://img.shields.io/docker/pulls/biarms/gogs?logo=Docker)](https://hub.docker.com/r/biarms/gogs)
[![Docker Stars image](https://img.shields.io/docker/stars/biarms/gogs?logo=Docker)](https://hub.docker.com/r/biarms/gogs)
[![Highest Docker release](https://img.shields.io/docker/v/biarms/gogs?label=docker%20release&logo=Docker&sort=semver)](https://hub.docker.com/r/biarms/gogs)

<!--
[![Travis build status](https://api.travis-ci.org/biarms/gogs.svg?branch=master)](https://travis-ci.org/biarms/gogs)
[![CircleCI build status](https://circleci.com/gh/biarms/gogs.svg?style=svg)](https://circleci.com/gh/biarms/gogs)
-->

## Overview
The goal of this very simple project is only to publish a docker manifest merging both [Gogs](https://hub.docker.com/r/gogs/gogs/) and [Gogs-rpi](https://hub.docker.com/r/gogs/gogs-rpi) docker images repositories.

Resulting manifests are pushed on [dockerhub](https://hub.docker.com/repository/docker/biarms/gogs).

Current implementation 'retag' the gogs official images into this repo just because:
- The implementation of 'docker pull' (version 19.03.8) is still not smart enough to pull an arm32v7 images if running on a arm64v8 OS;
- The "docker manifest annotate" can't annotate twice the same image.

So, notes that the "arm64v8" images is actually the same as the arm32v7 one.

## How to build locally
1. Option 1: with CircleCI Local CLI:
   - Install [CircleCI Local CLI](https://circleci.com/docs/2.0/local-cli/)
   - Call `circleci local execute`
2. Option 2: with make:
   - Install [GNU make](https://www.gnu.org/software/make/manual/make.html). Version 3.81 (which came out-of-the-box on MacOS) should be OK.
   - Call `make build`