#!/bin/bash

# Check if IPA file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 path/to/app.ipa"
    exit 1
fi

IPA="$1"
TMP_DIR="extracted_ipa"

echo "[*] Extracting IPA..."
rm -rf "$TMP_DIR"
unzip -qq "$IPA" -d "$TMP_DIR"

# Find the .app directory inside Payload/
APP_DIR=$(find "$TMP_DIR/Payload" -name "*.app" -type d | head -n1)
if [ -z "$APP_DIR" ]; then
    echo "[-] No .app directory found"
    exit 2
fi

# Find the main Mach-O binary inside the .app root
APP_BINARY=$(find "$APP_DIR" -maxdepth 1 -type f -exec file {} \; | grep "Mach-O" | cut -d: -f1 | head -n1)
if [ ! -f "$APP_BINARY" ]; then
    echo "[-] No Mach-O binary found"
    exit 3
fi

echo "[*] App binary found: $APP_BINARY"

# List of linked libraries in the binary (from otool)
LINKED_LIBS=$(otool -L "$APP_BINARY" | tail -n +2 | awk '{print $1}' | sort)

# List of embedded frameworks (.framework)
INCLUDED_FRAMEWORKS=$(find "$APP_DIR/Frameworks" -name "*.framework" -type d 2>/dev/null | xargs -n1 basename | sort)

# List of embedded dynamic libraries (.dylib)
INCLUDED_DYLIBS=$(find "$APP_DIR" -name "*.dylib" -type f 2>/dev/null | xargs -n1 basename | sort)

# List of embedded bundles (.bundle)
INCLUDED_BUNDLES=$(find "$APP_DIR" -name "*.bundle" -type d 2>/dev/null | xargs -n1 basename | sort)

# Print all components
echo ""
echo "📦 Embedded Frameworks:"
echo "$INCLUDED_FRAMEWORKS"
echo ""
echo "📦 Embedded .dylib Libraries:"
echo "$INCLUDED_DYLIBS"
echo ""
echo "📦 Embedded .bundle Plugins:"
echo "$INCLUDED_BUNDLES"
echo ""
echo "🔗 Libraries Linked by the Main Binary:"
echo "$LINKED_LIBS"
echo ""

# Analyze framework usage
echo "🔍 Framework Usage Analysis:"
echo "$INCLUDED_FRAMEWORKS" | while read fw; do
    fwname="${fw%.framework}"
    match=$(echo "$LINKED_LIBS" | grep -i "$fwname" || true)
    if [[ -n "$match" ]]; then
        echo "✔️  $fwname — USED (linked in binary)"
    else
        echo "❌  $fwname — NOT USED (embedded but not linked)"
    fi
done

# Analyze .dylib usage
echo ""
echo "🔍 .dylib Usage Analysis:"
echo "$INCLUDED_DYLIBS" | while read dylib; do
    dylibname="${dylib%.dylib}"
    match=$(echo "$LINKED_LIBS" | grep -i "$dylibname" || true)
    if [[ -n "$match" ]]; then
        echo "✔️  $dylib — USED (linked in binary)"
    else
        echo "❌  $dylib — NOT USED (embedded but not linked)"
    fi
done

# .bundle analysis (cannot determine usage statically)
echo ""
echo "🔍 .bundle Plugin Analysis (⚠️ manual dynamic inspection required):"
echo "$INCLUDED_BUNDLES" | while read bundle; do
    echo "❓  $bundle — embedded (check runtime loading via NSBundle or similar)"
done
