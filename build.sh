#!/bin/sh -eux

IMAGE=btop

cat <<EOF | docker build --platform linux/x86_64 -t $IMAGE -f- ./
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 AS base

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      gcc-12 g++-12 make

WORKDIR /workdir

COPY . .

RUN make -j STATIC=true STRIP=true
EOF

CONTAINER_ID=`docker create $IMAGE`
docker cp $CONTAINER_ID:/workdir /tmp/btop
docker rm $CONTAINER_ID

(cd /tmp/btop && sudo make install)
