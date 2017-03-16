#!/bin/bash

echo "AFTER SUCCESS SCRIPT"

if [ "$TRAVIS_BRANCH" == "develop" ]; then
  echo "Works $TRAVIS_BRANCH"
  echo "$TRAVIS_REPO_SLUG"
  url="https://${GITHUB_KEY}@github.com/${TRAVIS_REPO_SLUG}.git"
  echo $url
  cd /tmp
  git clone ${url}
  directory=`echo ${TRAVIS_REPO_SLUG} | awk -F '/' ' { print $2  } '`
  echo $directory
  cd $directory
  git checkout master
  git merge origin/develop --no-edit
  git push origin master
fi
