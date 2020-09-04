#!/bin/sh -e

while getopts "c:" opt; do
    case $opt in
    c) comment=$OPTARG ;; # Handle -c
    \?) echo "Use -c \"COMMENT\" to add comment to images."; exit ;; # Handle error: unknown option or missing required argument.
    esac
done

for file in $@; do :; done
filename=$(echo $file | rev | cut -f 1 -d '/' | rev)
prefix="$filename-"
dir="$filename-qr"

mkdir -p $dir
rm -f $dir/*

sha=$(sha1sum $file | cut -f 1 -d ' ')
date=$(date -u --iso-8601=seconds)

cat $file | split -d -b 2953 -a3 - "$dir/$prefix"

cd $dir

count=$(ls | wc -l)

for f in $prefix*
do
  echo "processing $f"
  chunksha=$(sha1sum $f | cut -f 1 -d ' ')

  out="$f.png"
  cat $f | qrencode --8bit -v 40 --size=13 --margin=1 --output "$out"
  convert -size 2490x3510 xc:white \( $out -gravity center \) -composite \
    -pointsize 72 -gravity northwest -annotate +100+200 "FILE: $file\n\nCHUNK: $f\n\nTOTAL CHUNKS: $count" \
    -gravity southwest -pointsize 41 -annotate +100+300 "CHUNK ${f##*-} SHA1: $chunksha\n\nFINAL SHA1: $sha" \
    -gravity northeast -pointsize 41 -annotate +100+130 "$date" \
    -gravity southeast -pointsize 41 -annotate +100+150 "$comment" \
    -gravity southwest -pointsize 41 -annotate +100+150 "gitlab.com/alisinabh/paperify" $out

  rm $f
done
