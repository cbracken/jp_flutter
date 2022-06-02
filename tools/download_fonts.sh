#!/bin/sh

function printErr {
  echo "ERROR: $1"
  exit 1
}

if [ ! `which curl` ]; then
  printErr "curl not found."
fi
if [ ! `which unzip` ]; then
  printErr "unzip not found."
fi

CURL="`which curl`"
UNZIP="`which unzip`"

# Download font archives.
DLDIR=tmp
mkdir -p "$DLDIR"
"$CURL" -o "$DLDIR/ipafont.zip" https://moji.or.jp/wp-content/ipafont/IPAfont/IPAfont00303.zip
"$CURL" -o "$DLDIR/nanumgothic.zip" https://www.fontsquirrel.com/fonts/download/nanumgothic

# Copy fonts to font directory.
FONTDIR=fonts
unzip -d "$DLDIR" "$DLDIR/ipafont.zip"
unzip -d "$DLDIR" "$DLDIR/nanumgothic.zip"
mv "$DLDIR/IPAfont00303/ipag.ttf" "$FONTDIR"
mv "$DLDIR/NanumGothic-Regular.ttf" "$FONTDIR"

# Clean up.
rm -rf "$DLDIR"
