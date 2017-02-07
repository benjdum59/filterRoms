#!/bin/bash

function fctInit {
  rarMimeType="application/x-rar-compressed"
  rarMimeType2="application/x-rar"
  zipMimeType="application/zip"
  tarMimeType="application/tar"
  targzMimeType="application/tar+gzip"
  gzipMimeType="application/x-gzip"
}

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

function fctGetPatterns {
  patterns=()
  while read line; do    
    echo $line | grep -v "^#" 1>/dev/null 
    if [ $? -eq 0 ]; then
      patterns+=($line)
    fi  
  done < patterns.txt
  
  if [ ${#patterns[@]} -eq 0 ]; then
    fctErrorPattern
  fi

  echo ${patterns[0]}
  echo ${patterns[1]}
}

function fctUncompress {
  mimetype=`file --mime-type  ${archivePath} | cut -d ':' -f 2`
  echo "Mime-Type found: $mimetype"

  if [ $mimetype = $rarMimeType ] || [ $mimetype = $rarMimeType2 ]; then
    echo "File is a rar file"
  fi
}

function fctErrorPattern {
  echo "No pattern defined in patterns.txt"
  exit 1
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
fctGetPatterns
archivePath=$1
destinationPath=$2
fctInit
fctCheckArgs
fctUncompress
