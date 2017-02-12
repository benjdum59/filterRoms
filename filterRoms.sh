#!/bin/bash
shopt -s extglob

function fctInit {
  scriptPath=$(cd $(dirname $0);echo $PWD)
  rarMimeType="application/x-rar-compressed"
  rarMimeType2="application/x-rar"
  zipMimeType="application/zip"
  tarMimeType="application/tar"
  targzMimeType="application/tar+gzip"
  gzipMimeType="application/x-gzip"
  sevenZMimeType="application/x-7z-compressed"
  archivePath="${scriptPath}/input"
  destinationPath="${scriptPath}/output"

  echo $scriptPath
  echo $archivePath
  echo $destinationPath
}

function fctGetPatterns {
  patterns=()
  while read line; do    
    echo $line | grep -v "^#" 1>/dev/null 
    if [ $? -eq 0 ]; then
      patterns+=($line)
    fi  
  done < ${scriptPath}/patterns.txt
  
  if [ ${#patterns[@]} -eq 0 ]; then
    fctErrorPattern
  fi

  echo ${patterns[0]}
  echo ${patterns[1]}
}

function fctCheckEnv {
  inputData=`find ${archivePath} -type f | grep -v .gitignore  | grep -v .DS_Store | wc -l | tr -d ' '`
  outputData=`find ${destinationPath} -type f | grep -v .gitignore | grep -v .DS_Store | wc -l | tr -d ' '`
  if [ $inputData -eq 0 ]; then
    fctErrorDirectoryEmpty "${archivePath}"
  fi
  if [ $outputData -ne 0 ]; then
    fctErrorDirectoryNotEmpty "${destinationPath}"
  fi
}

function fctProceed {

find ${archivePath} -type f -print0  | while IFS= read -r -d '' archiveFile; do 
  echo  "$archiveFile" | grep -v '.gitignore' 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "${archiveFile} will be processed"
    fctIdentifyMimeType "$archiveFile"
  fi 
done
}



function fctIdentifyMimeType {
  mimetype=`file --mime-type  "$1" | cut -d ':' -f 2`
  echo "Mime-Type found: $mimetype"

  if [ $mimetype = $rarMimeType ] || [ $mimetype = $rarMimeType2 ]; then
    echo "File is a rar file"
  elif [ $mimetype = ${sevenZMimeType} ]; then
    echo "File is a 7z file"
    fct7zProcess "$1"
  fi 
}

function fct7zProcess {
compressedFile=$1
while read -r line
do
    filename="$line"
    for pattern in "${patterns[@]}"
    do
      filename=`echo $filename | grep ${pattern}`
    done
    if [ "$filename" != "" ]; then
      #filename=`echo ${filename} | sed 's/\[\!\]/\[\\!\]/g'`
      filename="${filename//!/\\!}"
      compressedFile="${compressedFile//!/\\!}"
      echo "Treating $filename"
      echo 7z e \"${compressedFile}\" -o${destinationPath} \"${filename}\" >> ${destinationPath}/7zCommands.txt
    fi
#done < <(7z l "$1" | awk -F ' ' '{ $1 = ""; $2 = ""; $3 = ""; $4 = ""; print $0}')
done < <(7z l "${compressedFile}" -slt | grep "^Path = " | awk -F '=' '{ print $2 }')
}

function fctErrorDirectoryEmpty {
  echo "$1 should not be empty"
  exit 1
}

function fctErrorDirectoryNotEmpty {
  echo "$1 should be empty"
  exit 1
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

fctInit
fctGetPatterns
fctCheckEnv
fctProceed
