#!/bin/bash

IPA="$1"

if [ -z "$IPA" ]; then
  echo "Uso: $0 nome.ipa"
  exit 1
fi

NAME=$(basename "$IPA" .ipa)
TMPDIR="tmp_$NAME"

# Pulizia
rm -rf "$TMPDIR" "${NAME}_stripped.ipa"

# Estrai l'IPA
unzip -q "$IPA" -d "$TMPDIR"

# Rimuovi Watch e PlugIns
rm -rf "$TMPDIR"/Payload/*.app/Watch
rm -rf "$TMPDIR"/Payload/*.app/PlugIns

# Converti Info.plist binario in XML con plistutil
PLIST_PATH=$(find "$TMPDIR"/Payload -name Info.plist | head -n 1)
if [ -f "$PLIST_PATH" ]; then
  echo "ℹ️ Convertendo $PLIST_PATH in XML..."
  plistutil --infile "$PLIST_PATH" --outfile "$PLIST_PATH.xml"
  mv "$PLIST_PATH.xml" "$PLIST_PATH"
else
  echo "Info.plist non trovato"
fi

# Ricrea IPA
cd "$TMPDIR"
zip -qr "../${NAME}_stripped.ipa" Payload
cd ..

echo "IPA rigenerata: ${NAME}_stripped.ipa"

