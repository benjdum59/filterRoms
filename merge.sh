#!/bin/bash

if [ "$TRAVIS_BRANCH" == "develop" ]; then
  echo "Works $TRAVIS_BRANCH"
fi
