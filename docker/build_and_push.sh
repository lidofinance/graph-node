#!/bin/bash
source ./.env
set -e +u
set -o pipefail

export DOCKER_CONFIG=$HOME/.lidofinance

type -p podman > /dev/null && docker=podman || docker=docker

cd $(dirname $0)/..

if [ -d .git ]
then
    COMMIT_SHA=$(git rev-parse HEAD)
    TAG_NAME=$(git tag --points-at HEAD)
    REPO_NAME="Checkout of $(git remote get-url origin) at $(git describe --dirty)"
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
fi
stage=graph-node
$docker build --target $stage \
    --build-arg "COMMIT_SHA=$COMMIT_SHA" \
    --build-arg "REPO_NAME=$REPO_NAME" \
    --build-arg "BRANCH_NAME=$BRANCH_NAME" \
    --build-arg "TAG_NAME=$TAG_NAME" \
    -t lidofinance/$stage:$TAG_NAME \
    -f docker/Dockerfile .


echo "Pushing image to the Docker Hub"
docker push "lidofinance/$stage:$TAG_NAME"
docker tag "lidofinance/$stage:$TAG_NAME" "lidofinance/$stage:latest"
docker push "lidofinance/$stage:latest"
