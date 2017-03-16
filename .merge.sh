#!/bin/bash

echo "AFTER SUCCESS SCRIPT"

if [ "$TRAVIS_BRANCH" == "develop" ]; then
  echo "Works $TRAVIS_BRANCH"
  echo "$TRAVIS_REPO_SLUG"
  url="https://${GITHUB_KEY}@github.com:${TRAVIS_REPO_SLUG}.git"
  echo $url
  cd /tmp
  git clone ${url}
  git checkout master
  git merge develop -m "Merge from develop into master after build success"
  git push origin master
fi
