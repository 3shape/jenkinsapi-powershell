#!/bin/bash
# The git clone command in this script is needed because travis always performs git clone using a branch.
# This makes it impossible to get all the branch and tag information needed without fully cloning.
set -ev

if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  COMMIT_SHA=${TRAVIS_COMMIT}
else
  COMMIT_SHA=${TRAVIS_PULL_REQUEST_SHA}
fi

git clone https://github.com/$TRAVIS_REPO_SLUG.git $TRAVIS_REPO_SLUG
cd $TRAVIS_REPO_SLUG
git checkout -qf $COMMIT_SHA
