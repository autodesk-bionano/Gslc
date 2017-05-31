#!/usr/bin/env bash
# Builds the minimal docker image with the GSL binaries installed

set -e

USER=dionjwa
REGISTRY=docker.io
REPO_NAME="gslc"

# Get the version
GIT_TAG=`git rev-parse HEAD`
if [ ! -z "$TRAVIS_COMMIT" ]; then
	GIT_TAG=$TRAVIS_COMMIT
fi
GIT_TAG=${GIT_TAG:0:8}
PACKAGE_VERSION=$GIT_TAG

# Build the docker image that has all the build libraries.
OUTPUT_DIR=$PWD/tmpDockerBuild
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/bin
mkdir -p $OUTPUT_DIR/docs

	# # After this image is built, we will pull the binaries+docs out of it
	# DOCKER_IMAGE_BUILD="gslc-tmp-build:$PACKAGE_VERSION"
	# docker build -t $DOCKER_IMAGE_BUILD -f Dockerfile .

	# # Now run the build docker image, copying the binaries and docs out

	# #mkdir -p $OUTPUT_DIR/gslc_lib
	# docker run --rm -v $OUTPUT_DIR:/build $DOCKER_IMAGE_BUILD /bin/bash -c "cp -r /app/src/Gslc/bin/Release/* /build/bin/ && cp -r /app/docs/output/* /build/docs/"
	# # Remove the intermediate docker build image?
	# # docker rmi $DOCKER_IMAGE_BUILD

#Now create the final docker image that
#Only contains the binaries and the libraries

cp -r ./src/Gslc/bin/Debug/* $OUTPUT_DIR/bin
cp etc/Dockerfile $OUTPUT_DIR/
cp etc/.dockerignore $OUTPUT_DIR/
cp -r ./gslc_lib $OUTPUT_DIR/
cd $OUTPUT_DIR/
docker build -t "$REPO_NAME:$PACKAGE_VERSION" .
echo "$REPO_NAME:$PACKAGE_VERSION"

# function docker_tag_exists() {
# 	REPO=$1
# 	TAG=$2
# 	REPO_URL=$USER/$REPO
# 	TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_USERNAME}'", "password": "'${DOCKER_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
# 	EXISTS=$(curl -s -H "Authorization: JWT ${TOKEN}" "https://hub.docker.com/v2/repositories/$REPO_URL/tags/?page_size=10000" | jq -r "[.results | .[] | .name == \"${TAG}\"] | any")
# 	test $EXISTS = true
# }

# #Upload to dockerhub?
# if [ ! -z "$DOCKER_USERNAME" ] && [ ! -z "$DOCKER_PASSWORD" ]; then
# 	#Make sure we are logged into dockerhub
# 	docker login --username $DOCKER_USERNAME --password $DOCKER_PASSWORD

# 	if docker_tag_exists $REPO_NAME $PACKAGE_VERSION; then
# 		echo "Image already exists!: $USER/$REPO_NAME:$PACKAGE_VERSION"
# 	else
# 		echo "Pushing $USER/$REPO_NAME:$PACKAGE_VERSION"
# 		docker tag $REPO_NAME:$PACKAGE_VERSION $USER/$REPO_NAME:$PACKAGE_VERSION
# 		docker push $USER/$REPO_NAME:$PACKAGE_VERSION
# 		echo $REGISTRY/$USER/$REPO_NAME:$PACKAGE_VERSION
# 	fi
# else
# 	echo "DOCKER_USERNAME and DOCKER_PASSWORD are not set, skipping docker images push to docker.io";
# fi

