#!/bin/sh -e


while getopts "xz:" opt; do
    case $opt in
    x) xz=true ;; 
    z) gz=true ;;
    \?) echo -e "\t -x: Use xz to compress\n\t -z Use gz to compress"; exit ;;
    esac
done

file="$1"
prefix="$1-"
dir="$file-qr"

mkdir -p $dir
rm -f $dir/*

sha=$(sha1sum $file | cut -f 1 -d ' ')
date=$(date -u)

cat $file | xz -z | base64 -w0 | split -d -C 2920 -a3 - "$dir/$prefix"

cd $dir

count=$(ls | wc -l)

for f in $prefix*
do
  echo "processing $f"
  chunksha=$(sha1sum $f | cut -f 1 -d ' ')

  out="$f.png"
  cat $f | qrencode --size=13 --margin=1 --output "$out"
  convert -size 2490x3510 xc:white \( $out -gravity center \) -composite \
    -pointsize 72 -gravity northwest -annotate +100+200 "FILE: $file\n\nCHUNK: $f\n\nTOTAL CHUNKS: $count" \
    -gravity southwest -pointsize 41 -annotate +100+300 "CHUNK ${f##*-} SHA1: $chunksha\n\nFINAL SHA1: $sha" \
    -gravity northeast -pointsize 41 -annotate +100+200 "$date" \
    -gravity southwest -pointsize 41 -annotate +100+150 "gitlab.com/alisinabh/paperify" $out

  rm $f
done
