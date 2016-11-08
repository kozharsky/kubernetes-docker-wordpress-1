#!/bin/bash

set -e

for image in \
        haproxy \
        nginx \
        nodejs \
        wordpress \
    ; do
        docker build -t ${image} ./${image}
    done
