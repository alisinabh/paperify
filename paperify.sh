#!/bin/bash -e

function show_help {
    echo "usage: $(basename $0) [OPTIONS] <FILE>"
    echo ""
    echo "options:"
    echo -e "  -h\t\tShow this help."
    echo -e "  -c COMMENT\tAdd comment to the generated files."
    echo -e "  -p\t\tCreate a PDF using the generated files."
    echo -e "  -pp\t\tCreate an enhanced PDF using the generated files.\n\t\tThis will include as preface the digitallify.sh script."
}

if [ $# -eq 0 ]
then
  echo "Error: You must specify a filename" >&2
  show_help
  exit 1
fi

for (( i=1; i<=$#; i++ ))
do
  #echo "${!i} $#"
  if [ "${!i}" = "-p" -o "${!i}" = "-pp" ]
  then
    topdf=1;
    echo "PDF creation is experimental!"
    echo "Make sure that you give ImageMagick enough memory in policy.xml"
    echo "Run 'identify -list policy' to see your current limits"
    echo
    if [ "${!i}" = "-pp" ]; then prefacepdf=1; fi
  elif [ "${!i}" = "-c" ]
  then ((i++))
    comment=${!i};
  elif [ "${!i}" = "-h" ]
  then
    show_help
    exit 0
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

rm -Rf -- "$dir"
mkdir -p "$dir"
echo $(pwd)

sha=$(sha1sum "$file" | cut -f 1 -d ' ')
date=$(date -u +%Y-%m-%dT%H:%M:%S+00:00)

SPLIT_BIN=split

if [[ $OSTYPE == "darwin"* ]]; then
	# Use gsplit in OS X as split does not support -d 
	# Issue #11
	SPLIT_BIN=gsplit
fi

eval "cat \"$file\" | $SPLIT_BIN -d -b 2953 -a3 - \"$dir/$prefix\""

cd "$dir"

count=$(ls | wc -l)
FONT=${FONT:-fixed}
unset preface

function make_qr_image {
	local file_in=$1
	local file_out=$2
  	chunksha=$(sha1sum "$file_in" | cut -f 1 -d ' ')
	cat "$file_in" | qrencode --8bit -v 40 --size=13 --margin=1 --output "$file_out"

	if [[ $3 -eq 0 ]] ; then
		header="FILE: $filename\n\n"
		header+="This page contains the digitallify.sh script used to decrypt the rest of the pages." 
		sha1_text="SHA1: $chunksha\n" 
		sha1_text+="UNPACK: Scan this page to FILENAME.jpg and run " 
	        sha1_text+="'zbarimg --raw -Sbinary -1 FILENAME.jpg | head -c 2953 > digitallify.sh'"
		extra_comment=''
	else
		header="FILE: $filename\n\nCHUNK: $f\n\nTOTAL CHUNKS: $count"
		sha1_text="CHUNK ${f##*-} SHA1: $chunksha\n\nFINAL SHA1: $sha"
		extra_comment="$comment"
	fi

	convert -size 2490x3510 xc:white \( "$file_out" -gravity center \) -composite \
	    -font $FONT -pointsize 52 \
	    -gravity northwest -annotate +100+200 "$header" \
	    -gravity southwest -pointsize 41 -annotate +100+300 "$sha1_text" \
	    -gravity northeast -pointsize 41 -annotate +100+130 "$date" \
	    -gravity southeast -pointsize 41 -annotate +100+150 "$extra_comment" \
	    -gravity southwest -pointsize 41 -annotate +100+150 "github.com/alisinabh/paperify" "$file_out"


}

if [[ $prefacepdf -eq 1 ]]; then
	preface=$(mktemp -t tmpPrefaceXXXX.jpg)
	function finish {
	  rm -rf "$preface"
	}
	trap finish EXIT
	make_qr_image "../digitallify.sh" "$preface" 0
fi

for f in *
do
  echo "processing $f"
  chunksha=$(sha1sum "$f" | cut -f 1 -d ' ')
  make_qr_image "$f" "${f/\ /_}.png" 1
  rm "$f"
done

if [[ $topdf -eq 1 ]]; then
  out="${filename/\ /_}-qr.pdf"
  tmpFile=$(mktemp)
  convert $preface *.png ${out} 2>$tmpFile || exit_code=$?
  errtxt=$(<$tmpFile)
  rm $tmpFile
  if (( exit_code != 0 )) ; then
      echo -e "Creating PDF failed!\n$errtxt \n"
      if ( echo "$errtxt" | grep -q "operation not allowed" ) ; then
	echo 'More info about this permission problem can be found at'
	echo 'https://cromwell-intl.com/open-source/pdf-not-authorized.html'
      fi
  fi
fi



echo ""
echo "QR Code generation completed"
echo "You can now print files inside of $dir"
