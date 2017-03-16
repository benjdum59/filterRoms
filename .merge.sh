#!/bin/bash

echo "AFTER SUCCESS SCRIPT"

if [ "$TRAVIS_BRANCH" == "develop" ]; then
  echo "Works $TRAVIS_BRANCH"
  echo "$TRAVIS_REPO_SLUG"
  url=${GITHUB_KEY}@github.com:${TRAVIS_REPO_SLUG}.git
  echo $url
fi
