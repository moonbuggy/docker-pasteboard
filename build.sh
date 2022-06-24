#! /bin/bash
# shellcheck shell=bash disable=SC2034

# Flags for build can also be hardcoded here if desired.
#NOOP=1
#DO_PUSH=1
#NO_BUILD=1

# define the target repo
DOCKER_REPO="${DOCKER_REPO:-moonbuggy2000/pasteboard}"

# default tag to build when no arguments provided
default_tag='latest'

# optional: tag(s) to build when 'all' is the argument
all_tags='latest'

# start the builder proper
. "hooks/.build.sh"
