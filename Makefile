# Makefile for building, tagging, publishing and releasing a container.
#
# Import build-time configuration.
# You can change the default config with `make env="config_special.env" build`.
# env ?= .env
# include $(env)
# export $(shell sed 's/=.*//' $(env))

# Use bash instead of sh.
SHELL := /usr/bin/env bash

# Retrieve application version from metadata file.
GIT_COMMIT_SHA1 := $(shell git rev-parse HEAD 2>/dev/null)
GIT_COMMIT_SHA1_SHORT := $(shell git rev-parse --short HEAD 2>/dev/null)
GIT_BRANCH := $(shell git symbolic-ref --short HEAD 2>/dev/null)
ifneq ($(BUILD_NUMBER),)
	VERSION = $(GIT_COMMIT_SHA1_SHORT)-$(BUILD_NUMBER)
else
	VERSION = $(GIT_COMMIT_SHA1_SHORT)
endif

IMAGE_TAG ?= latest

# Handy utilities.
DONE = echo ✓ $@ done
FAILED = echo ✘ $@ failed

# Materialized executables.
DOCKER_CMD ?= docker
DOCKER_COMPOSE_CMD ?= docker-compose

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help docker version

help: ## This halp!
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := docker

docker-all: docker docker-push ## Creates custom docker image, tags and pushes it.

docker: ## Creates custom docker image with compose.
	@echo '============================================'
	@echo 'Building custom docker image and tagging it.'
	@echo '============================================'
	GIT_COMMIT_SHA1_SHORT=$(GIT_COMMIT_SHA1_SHORT) $(DOCKER_COMPOSE_CMD) build
	@$(DONE)

docker-push: ## Pushes custom docker image to registry defined in image field of compose spec.
	@echo '============================'
	@echo 'Pushing custom docker image.'
	@echo '============================'
	GIT_COMMIT_SHA1_SHORT=$(GIT_COMMIT_SHA1_SHORT) $(DOCKER_COMPOSE_CMD) push
	@$(DONE)

docker-up: ## Runs the custom docker image in the background.
	@echo '============================'
	@echo 'Running custom docker image.'
	@echo '============================'
	GIT_COMMIT_SHA1_SHORT=$(GIT_COMMIT_SHA1_SHORT) $(DOCKER_COMPOSE_CMD) up --detach
	@$(DONE)

version: ## Output the current version.
	@echo $(VERSION)
