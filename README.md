# Paperify

Use QR codes to backup your data on papers.

## Sample

![Paperify](paperify.png)

## Requirements

Make sure you have these binaries installed on your system.

 - `qrencode` (qrencode)
 - `convert` (imagemagick)
 - `zbarimg` (zbar)

## Usage


```
# Creates FILE-qr directory with generated qr codes inside.
# Then you can print those files and store them.
./paperify.sh FILE


# Reads all files inside the DIRECTORY which you have all your
# scanned pages inside. Make sure the file namings are correct 
./digitalify.sh OUTPUT_FILE DIRECTORY
```
