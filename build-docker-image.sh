#!/usr/bin/env bash
# Builds the minimal docker image with the GSL binaries installed

# Get the version
GIT_TAG=`git rev-parse HEAD`
if [ ! -z "$TRAVIS_COMMIT" ]; then
	GIT_TAG=$TRAVIS_COMMIT
fi
GIT_TAG=${GIT_TAG:0:8}
VERSION=$GIT_TAG

# Build the docker image that has all the build libraries.
# After this image is built, we will pull the binaries+docs out of it
DOCKER_IMAGE_BUILD="gslc-tmp-build:$VERSION"
docker build -t $DOCKER_IMAGE_BUILD -f Dockerfile .

# Now run the build docker image, copying the binaries and docs out
OUTPUT_DIR=$PWD/tmpDockerBuild
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/bin
mkdir -p $OUTPUT_DIR/docs
mkdir -p $OUTPUT_DIR/gslc_lib
docker run --rm -v $OUTPUT_DIR:/build $DOCKER_IMAGE_BUILD /bin/bash -c "cp -r /app/src/Gslc/bin/Release/* /build/bin/ && cp -r /app/docs/output/* /build/docs/ && cp -r /app/gslc_lib/* /build/gslc_lib/"
# Remove the intermediate docker build image?
# docker rmi $DOCKER_IMAGE_BUILD

#Now create the final docker image that
#Only contains the binaries and the libraries
DOCKER_IMAGE="gslc:$VERSION"
cp etc/Dockerfile $OUTPUT_DIR/
cp etc/.dockerignore $OUTPUT_DIR/
cd $OUTPUT_DIR/
docker build -t $DOCKER_IMAGE .
echo $DOCKER_IMAGE

#Upload to quay.io?

