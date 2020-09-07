#!/bin/sh -e

for ((i=1;i<=$#;i++));
do

  if [ ${!i} = "-c" ]
  then ((i++))
    comment=${!i};
  else
    file="$INPUT_DIR${!i}";
  fi

done

if test -f "$file"; then
  echo "Paperifying $file"
else
  echo "File not found! $file"
  exit 1
fi

filename=$(echo $file | rev | cut -f 1 -d '/' | rev)
prefix="$filename-"
dir="$OUTPUT_DIR$filename-qr"

mkdir -p $dir
rm -f $dir/*

sha=$(sha1sum $file | cut -f 1 -d ' ')
date=$(date -u +%Y-%m-%dT%H:%M:%S+00:00)

cat $file | split -d -b 2953 -a3 - "$dir/$prefix"

cd $dir

count=$(ls | wc -l)
FONT=${FONT:-fixed}

for f in $prefix*
do
  echo "processing $f"
  chunksha=$(sha1sum $f | cut -f 1 -d ' ')

  out="$f.png"
  cat $f | qrencode --8bit -v 40 --size=13 --margin=1 --output "$out"
  convert -size 2490x3510 xc:white \( $out -gravity center \) -composite \
    -font $FONT -pointsize 72 -gravity northwest -annotate +100+200 "FILE: $filename\n\nCHUNK: $f\n\nTOTAL CHUNKS: $count" \
    -gravity southwest -pointsize 41 -annotate +100+300 "CHUNK ${f##*-} SHA1: $chunksha\n\nFINAL SHA1: $sha" \
    -gravity northeast -pointsize 41 -annotate +100+130 "$date" \
    -gravity southeast -pointsize 41 -annotate +100+150 "$comment" \
    -gravity southwest -pointsize 41 -annotate +100+150 "gitlab.com/alisinabh/paperify" $out

  rm $f
done

echo ""
echo "QR Code generation completed"
echo "You can now print files inside of $dir"
