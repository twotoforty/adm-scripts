#!/bin/bash -xe
set -e -o pipefail

echo "##################### EXECUTE: twotoforty_ci_container_build #####################"

[ -n $PUSH_IMAGES ] || PUSH_IMAGES='no'
[ -n $DOCKERHUB_REPO ] || exit 1
[ -n "$IMAGE_NAME" ] || exit 1
[ -n "$TAG" ] || exit 1

docker build --no-cache --rm=true -t $DOCKERHUB_REPO/$IMAGE_NAME:$TAG -f Dockerfile . || exit 1

if [ "$PUSH_IMAGES" == "yes" ]; then
  docker login -u "$TWOTOFORTY_DOCKERHUB_USER" -p "$TWOTOFORTY_DOCKERHUB_PASSWD"
  docker push $DOCKERHUB_REPO/$IMAGE_NAME:$TAG
  docker logout
fi

# Remove dangling images
if [ $(docker images -f "dangling=true" -q | wc -l) -ne 0 ]; then
  docker rmi $(docker images -f "dangling=true" -q) || exit 0
fi
