#!/bin/bash

echo "AFTER SUCCESS SCRIPT"

if [ "$TRAVIS_BRANCH" == "develop" ]; then
  nbBuildSuccessFile="/tmp/nbBuildSuccess.txt"
  if [ ! -f "${nbBuildSuccessFile}" ]; then
    echo '1'>"${nbBuildSuccessFile}"
  fi
  nbBuildSuccess=`cat "${nbBuildSuccessFile}"`
  echo "Previous build success number: $nbBuildSuccess"
  nbBuildSuccess=`expr $nbBuildSuccess + 1`
  echo "New build success number: ${nbBuildSuccess}"
  echo "$nbBuildSuccess">"${nbBuildSuccessFile}"
  if [ ${nbBuildSuccess} -ne 2 ]; then
    echo "There are still some builds to run or some build in failure state"
    exit 0
  fi
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
