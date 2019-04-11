#!/bin/bash

IMAGE_NAME=automium/service-provisioner
docker build --no-cache --pull --tag "$IMAGE_NAME" .
docker login -u "$REGISTRY_USER" -p "$REGISTRY_PASS"
docker tag "$IMAGE_NAME" "${IMAGE_NAME}:${TRAVIS_BRANCH}"
docker tag "$IMAGE_NAME" "${IMAGE_NAME}:latest"
docker push "${IMAGE_NAME}:${TRAVIS_BRANCH}"
docker push "${IMAGE_NAME}:latest"
