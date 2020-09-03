#!/bin/sh -e

outputfile="$1"
dir="$2"

files=$(ls $dir)

cur=$(pwd)
cd $dir

for f in $files
do
  echo "reconstructing $f"

  noext=${f%.*}
  chunk=$(echo $noext |rev | cut -f 1 -d '-' | rev)
  zbarimg --raw --quiet --oneshot $f > "$chunk-$noext.chunk"
done

cd $cur
ls $dir/*.chunk | sort | xargs cat | base64 -d | xz -dc > $outputfile
echo "$(ls $dir/*.chunk | sort)"
rm $dir/*.chunk

echo "File reconstructed as $outputfile please check the bellow sha1 with the sha1 of the file in your media."
sha1sum $outputfile
