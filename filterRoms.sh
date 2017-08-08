#!/bin/bash
shopt -s extglob

function fctInit {
  scriptPath=$(cd $(dirname $0);echo $PWD)
  rarMimeType="application/x-rar-compressed"
  rarMimeType2="application/x-rar"
  zipMimeType="application/zip"
  tarMimeType="application/tar"
  tarMimeType2="application/x-tar"
  targzMimeType="application/tar+gzip"
  tgzMimeType="application/x-bzip2"
  gzipMimeType="application/x-gzip"
  gzipMimeType2="application/gzip"
  sevenZMimeType="application/x-7z-compressed"
  octetStreamMimeType="application/octet-stream"
  archivePath="${scriptPath}/input"
  destinationPath="${scriptPath}/output"
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
  while read line; do
    echo $line | grep -v "^#" 1>/dev/null
    if [ $? -eq 0 ]; then
      exclusions+=($line)
    fi
  done < ${scriptPath}/exclusions.txt
}

function fctCheckEnv {
  inputData=$(find ${archivePath} -type f | grep -v .gitignore  | grep -v .DS_Store | wc -l | tr -d ' ')
  outputData=$(find ${destinationPath} -type f | grep -v .gitignore | grep -v .DS_Store | wc -l | tr -d ' ')
  if [ $inputData -eq 0 ]; then
    fctErrorDirectoryEmpty "${archivePath}"
  fi
  if [ $outputData -ne 0 ]; then
    fctErrorDirectoryNotEmpty "${destinationPath}"
  fi
}

function fctProceed {
find ${archivePath} -type f -print0 | sort | while IFS= read -r -d '' archiveFile; do 
  echo  "$archiveFile" | grep -v '.gitignore' 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "${archiveFile} will be processed"
    fctIdentifyMimeType "$archiveFile"
  fi 
done
}

function fctIdentifyMimeType {
  mimetype=$(file --mime-type  "$1" | cut -d ':' -f 2)
  echo "Mime-Type found: $mimetype for file $1"
  if [ $mimetype = $rarMimeType ] || [ $mimetype = $rarMimeType2 ]; then
    echo "File is a rar file"
    fct7zProcess "$1"
  elif [ $mimetype = ${sevenZMimeType} ]; then
    echo "File is a 7z file"
    fct7zProcess "$1"
  elif [ $mimetype = ${zipMimeType} ]; then
    echo "File is a zip file"
    fct7zProcess "$1"
  elif [ $mimetype = ${tarMimeType} ] || [ $mimetype = ${tarMimeType2} ]; then
    echo "File is a tar file"
    fct7zProcess "$1"
  elif [ $mimetype = ${targzMimeType} ]; then
    echo "File is a tar.gz file"
    fctTgzProcess "$1"
  elif [ $mimetype = ${gzipMimeType} || $mimetype = ${gzipMimeType2} ]; then
    echo "File is a gz file"
    extension="${1##*.}"
    extension2=${1#*.}
    if [ "$extension" = "tgz" ] || [ "$extension2" = "tar.gz" ]; then
      echo "File is a tgz or tar.gz file" 
      fctTgzProcess "$1"
    else   
      fct7zProcess "$1"
    fi
  elif [ $mimetype = ${tgzMimeType} ]; then
    echo "File is a tbz2 file"
    fctTgz2Process "$1" 
  elif [ $mimetype = ${octetStreamMimeType} ]; then
    fctOctetStream "$1"
  else
    echo "File will be treated as a regular file"
    fctRegularFile "$1" 
  fi
}

function fctOctetStream {
  echo "Determining file type with extension for file $1"
  extension="${1##*.}"
  extension2="${1#*.}"
  if [ "$extension" = "rar" ]; then
    echo "File is a rar file"
    fct7zProcess "$1"
  elif [ "$extension" = "7z" ]; then
    echo "File is a 7z file"
    fct7zProcess "$1"
  elif [ "$extension" = "zip" ]; then
    echo "File is a zip file"
    fct7zProcess "$1"
  elif [ "$extension" = "tar" ]; then
    echo "File is a tar file"
    fct7zProcess "$1"
  elif [ "$extension" = "tgz" ] || [ "$extension2" = "tar.gz" ]; then
      echo "File is a tgz or tar.gz file"
      fctTgzProcess "$1"
  elif [ "$extension" = "gz" ]; then
      echo "File is a gz file" 
      fct7zProcess "$1"
  elif [ "$extension" = "tbz2" ]; then
    echo "File is a tbz2 file"
    fctTgz2Process "$1"
  else
    echo "File will be treated as a regular file"
    fctRegularFile "$1"
  fi
}

function fctCheckFilename {
  filename=$1
  echo "Filename: ${filename}"
  for pattern in "${patterns[@]}"
  do
    filename=$(echo $filename | grep -F ${pattern})
    if [ "$filename" = "" ]; then
      return 1
    fi
  done
  for exclusion in "${exclusions[@]}"
  do
    filename=$(echo $filename | grep -v -F ${exclusion})
    if [ "$filename" = "" ]; then
      return 1
    fi
  done
}

function fctRegularFile {
  filePath=$1
  filename=$(basename "${filePath}")
  fctCheckFilename "${filename}"
  if [ "$filename" != "" ]; then
      filePath="${filePath//!/\\!}"
      echo "cp \"${filePath}\" \"${destinationPath}\"" >> ${destinationPath}/regularFilesCommands.txt
  fi   
}

function fct7zProcess {
compressedFile=$1
while read -r line
do
    filename="$line"
    fctCheckFilename "${filename}"
    if [ "$filename" != "" ]; then
      filename="${filename//!/\\!}"
      compressedFile="${compressedFile//!/\\!}"
      echo "Treating $filename"
      echo 7z e \"${compressedFile}\" -o${destinationPath} \"${filename}\" >> ${destinationPath}/7zCommands.txt
    fi
done < <(7z l "${compressedFile}" -slt | grep "^Path = " | awk -F '=' '{ print $2 }')
}

function fctTgz2Process {
compressedFile=$1
  while read -r line
  do
    filename="$line"
    fctCheckFilename "${filename}"
    if [ "$filename" != "" ]; then
      filename="${filename//!/\\!}"
      compressedFile="${compressedFile//!/\\!}"
      echo "Treating $filename"
      echo "7z x  \"${compressedFile}\" -so |  7z x -si -ttar -o${destinationPath} \"${filename}\"" >> ${destinationPath}/7zCommands.txt
    fi
done < <(tar -jtf "${compressedFile}")
}

function fctTgzProcess {
compressedFile=$1
  while read -r line
  do
    filename="$line"
    fctCheckFilename "${filename}"
    if [ "$filename" != "" ]; then
      filename="${filename//!/\\!}"
      compressedFile="${compressedFile//!/\\!}"
      filename=$(echo $filename)
      echo "Treating $filename"
      echo "7z x  \"${compressedFile}\" -so |  7z x -si -ttar -o${destinationPath} \"${filename}\"" >> ${destinationPath}/7zCommands.txt
    fi
  done < <(tar -tf "${compressedFile}")
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
