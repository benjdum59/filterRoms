#!/bin/bash

echo "AFTER SUCCESS SCRIPT"

if [ "$TRAVIS_BRANCH" == "develop" ]; then
  echo "Works $TRAVIS_BRANCH"
  echo "$TRAVIS_REPO_SLUG"
  url="https://${GITHUB_KEY}@github.com/${TRAVIS_REPO_SLUG}.git"
  cd /tmp
  git clone ${url}
  git config --global user.email "travis@travis"
  git config --global user.name "Travis CI"
  directory=`echo ${TRAVIS_REPO_SLUG} | awk -F '/' ' { print $2  } '`
  cd $directory
  git checkout master
  git merge origin/develop --no-edit
  git push origin master --quiet
fi
