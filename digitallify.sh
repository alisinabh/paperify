#!/bin/bash -e

if [ "$1" = "-h" ]; then
  echo "usage: digitallify.sh <outputfile> <images_directory>"
  exit 0
elif [ "$1" = "" ]; then
  echo "Please provide a filename as the first argument"
  exit 1
elif [ "$2" = "" ]; then
  echo "Please provide the directory of the images as the second argument"
  exit 1
fi

cur="$(pwd)/"
outputfile="${OUTPUT_DIR:-$cur}$1"
dir="${INPUT_DIR:-$cur}$2"

files=$(ls "$dir")

cd "$dir"

for f in $files
do
  echo "reconstructing $f"

  noext=${f%.*}
  chunk=$(echo $noext |rev | cut -f 1 -d '-' | rev)

  zbarimg --nodbus --raw -Sbinary --quiet $f | head -c 2953 > "$chunk-$noext.chunk"
done

echo $(ls | grep ".*\.chunk$" | sort)
ls | grep ".*\.chunk$" | sort | xargs cat > "$outputfile"
rm *.chunk
cd "$cur"

echo ""
echo "File reconstructed as $outputfile"
echo "IMPORTANT: Please check the bellow sha1 with the sha1 of the file in your media."
echo ""
sha1sum "$outputfile"
