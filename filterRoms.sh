#!/bin/bash

function fctCheckArgs {
  if [ -z "$archivePath" ] || [ -z $destinationPath  ]; then
    fctErrorArguments
  fi
  if [ ! -f "$archivePath" ]; then
    fctErrorNotAFile $archivePath
  fi
  if [ ! -d "$destinationPath" ]; then
   mkdir -p "$destinationPath" 
  fi
}

function fctUncompress {
  mimetype=`file --mime-type  ${archivePath} | cut -d ':' -f 2`
  echo $mimetype
#  filename=`basename ${archivePath}`
#  multipleExtension=${filename#*.}
#  simpleExtension=${filename##*.}
# echo $filename
#echo $multipleExtension
#echo $simpleExtension  
#  if [ -z "$simpleExtension" ]; then
#    fctErrorExtension $filename
#  fi
}

function fctErrorExtension {
  echo "Unable to determine extension for file $1"
  exit 1
}

function fctErrorNotAFile {
  echo "$1 is not a file or does not exists"
  exit 1
}

function fctErrorArguments {
  echo "Usage: ./filterRoms.sh <archive path> <destination path>"
  exit 1
}

archivePath=$1
destinationPath=$2

fctCheckArgs
fctUncompress
