IMAGE_NAME ?= localhost/clawos-atomic
IMAGE_TAG ?= dev
BASE_IMAGE ?= quay.io/fedora/fedora-bootc:latest
CONTAINER_RUNTIME ?= podman
CONTAINERFILE ?= images/host/Containerfile

.PHONY: help image-build image-base-inspect image-inspect verify

help:
	@printf '%s\n' 'ClawOS Atomic targets:'
	@printf '%s\n' '  make image-base-inspect  Inspect the configured bootc base image'
	@printf '%s\n' '  make image-build         Build the MVP 0 developer preview image'
	@printf '%s\n' '  make image-inspect       Inspect the locally built image'
	@printf '%s\n' '  make verify              Run lightweight repository checks'

image-base-inspect:
	skopeo inspect docker://$(BASE_IMAGE)

image-build:
	$(CONTAINER_RUNTIME) build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--file $(CONTAINERFILE) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG) \
		.

image-inspect:
	$(CONTAINER_RUNTIME) image inspect $(IMAGE_NAME):$(IMAGE_TAG)

verify:
	git diff --check
	@! grep -nH '[[:blank:]]$$' Makefile
	@! find README.md docs images packages packaging policy schemas services tests \
		-type f \( -name '*.md' -o -name 'Containerfile' -o -name '*.service' \
		-o -name '*.conf' -o -name '*.policy' -o -name '*.manifest' \) \
		-exec grep -nH '[[:blank:]]$$' {} +
