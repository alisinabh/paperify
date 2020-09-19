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

outputfile="$INPUT_DIR$1"
dir="$OUTPUT_DIR$2"

files=$(ls $dir)

cur=$(pwd)
cd $dir

for f in $files
do
  echo "reconstructing $f"

  noext=${f%.*}
  chunk=$(echo $noext |rev | cut -f 1 -d '-' | rev)

  zbarimg --raw -Sbinary --quiet $f | head -c 2953 > "$chunk-$noext.chunk"
done

cd $cur
ls $dir/*.chunk | sort | xargs cat > $outputfile
rm $dir/*.chunk

echo ""
echo "File reconstructed as $outputfile"
echo "IMPORTANT: Please check the bellow sha1 with the sha1 of the file in your media."
echo ""
sha1sum $outputfile
