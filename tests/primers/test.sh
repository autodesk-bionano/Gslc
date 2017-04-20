#!/usr/bin/env bash

./build-docker-image.sh

# Get the version
GIT_TAG=`git rev-parse HEAD`
if [ ! -z "$TRAVIS_COMMIT" ]; then
	GIT_TAG=$TRAVIS_COMMIT
fi
GIT_TAG=${GIT_TAG:0:8}
VERSION=$GIT_TAG
VERSION="c0e881a6"
DOCKER_IMAGE="gslc:$VERSION"

TESTOUT=tmpTestOut

CMD=" --flat /$TESTOUT/gslOutFlat.txt"
CMD="$CMD --json /$TESTOUT/gslOut.json"
CMD="$CMD --primers /$TESTOUT/gslOut.primers.txt"
CMD="$CMD --ape /$TESTOUT gslOut"
CMD="$CMD --cm /$TESTOUT gslOut"
# CMD="$CMD --thumper /$TESTOUT/thumperOut"
CMD="$CMD /primers/simple_promoter_gene_locus.gsl"

# echo "docker run --rm -ti -v $PWD/tests/primers:/primers -v $PWD/$TESTOUT:/$TESTOUT $DOCKER_IMAGE $CMD"
docker run --rm -ti -v $PWD/tests/primers:/primers -v $PWD/$TESTOUT:/$TESTOUT $DOCKER_IMAGE $CMD
#Testing the same command with the current production binaries
# docker run --rm -ti -v $PWD/compiledbinaries:/gslc/bin -v $PWD/tests/primers:/primers -v $PWD/$TESTOUT:/$TESTOUT $DOCKER_IMAGE $CMD
