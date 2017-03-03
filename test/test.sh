#/bin/bash

function showError {
  echo '!!!!!!!!!!!!!!!!!!!!!!!!!   ERROR   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  echo $1
  echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  error=`expr $error + 1`
}

#Go the the test directory
scriptPath=$(cd $(dirname $0);echo $PWD)
cd ${scriptPath}
cp ./input/* ../input
if [ "$1" = "travis" ]; then
  refDir='ref-travis'
else
  refDir='ref'
fi

#Cleaning output directory
find ../output -type f -not -name .gitignore -delete

#Running code
../filterRoms.sh

#Moving results
find ../output -type f -not -name .gitignore   -exec mv '{}' ./result \;

#Analysing results
error=0

resultNb=`ls result | wc -l`
refNb=`ls ${refDir} | wc -l`

if [ ${resultNb} -ne ${refNb} ]; then
  showError "output and ref directories don't have the same number of files"
fi
cd ${refDir}
refArray=($(find . -type f | grep -v ".DS_Store" | grep -v ".gitignore" |xargs cksum | tr ' ' '_'))
cd ../result
resultArray=($(find . -type f | grep -v ".DS_Store" | grep -v ".gitignore" |xargs cksum | tr ' ' '_'))
cd ${scriptPath}


containsElement () {
  for e in "${@:2}"; do [[ "$e" = "$1" ]] && return 0; done; return 1;
}

for checksum in ${refArray[@]}
do
  containsElement "${checksum}" "${resultArray[@]}"
  if [ $? -ne 0 ]; then
    filename=`echo ${checksum} | awk -F '_' ' { print $3 } '`
    diff "${refDir}/${filename}" "result/${filename}"
    showError "${filename} files differ"
  fi  
done
echo Done
echo "$error error(s)"
exit $error
