#!/usr/bin/env bash

echo "$(date +%c)"
echo "Building $TRAVIS_REPO_SLUG"
if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo "Building Pull Request from branch $TRAVIS_PULL_REQUEST_BRANCH"
else
    echo "Building $TRAVIS_BRANCH"
fi
echo "Commit is $TRAVIS_COMMIT - $TRAVIS_COMMIT_MESSAGE"
echo "Travis Job Number is $TRAVIS_BUILD_NUMBER"
echo ""
