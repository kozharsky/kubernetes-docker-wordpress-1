#!/bin/bash

set -e

eval $(aws ecr get-login --region us-east-1)

for image in \
        haproxy \
        nginx \
        nodejs \
        wordpress \
    ; do
        ECR_TAG="${ECR_REPO}/${image}:latest"
        docker tag "${image}:latest" "${ECR_TAG}"
        docker push "${ECR_TAG}"
    done