#!/bin/sh
#
# shoot.sh — screenshot a URL with headless Chrome.
#
# Exists because the Claude-in-Chrome extension is regularly unavailable for a
# whole session, and the fallback has been to close visual work on typecheck and
# lint counts instead of looking at it. This needs no extension and no npm
# install: Chrome is already on the machine.
#
# Usage: shoot.sh <url> [out.png] [width] [height] [ms]
# Prints the output path on success so the caller can read the image back.
#
#   scripts/shoot.sh http://localhost:3000 /tmp/shot.png
#   scripts/shoot.sh http://localhost:5173/?scene=flight /tmp/f.png 1280 720 4000
#
# Capturing a PNG and never opening it is not looking. Read the file back.

set -eu

usage() {
    echo "usage: shoot.sh <url> [out.png] [width] [height] [ms]" >&2
    exit 2
}

[ $# -ge 1 ] || usage
case $1 in -h|--help) usage ;; esac

url=$1
out=${2:-/tmp/shot.png}
w=${3:-1280}
h=${4:-720}
ms=${5:-2000}

chrome=""
for c in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium" \
    "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary" \
    "$(command -v google-chrome 2>/dev/null || true)" \
    "$(command -v chromium 2>/dev/null || true)"
do
    if [ -n "$c" ] && [ -x "$c" ]; then
        chrome=$c
        break
    fi
done

if [ -z "$chrome" ]; then
    echo "shoot: no Chrome or Chromium found" >&2
    exit 1
fi

mkdir -p "$(dirname "$out")"
rm -f "$out"

# CanvasDrawElement keeps WebGL and canvas content from coming back blank.
# The backgrounding flags stop Chrome throttling rAF in an unfocused window.
"$chrome" \
    --headless \
    --disable-gpu \
    --no-sandbox \
    --hide-scrollbars \
    --enable-features=CanvasDrawElement \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --virtual-time-budget="$ms" \
    --window-size="$w,$h" \
    --screenshot="$out" \
    "$url" >/dev/null 2>&1 || true

if [ ! -s "$out" ]; then
    echo "shoot: no image written for $url" >&2
    echo "shoot: if the page is on localhost, check the dev server is up" >&2
    exit 1
fi

echo "$out"

# Two things this cannot do.
#
# A dead URL still produces a PNG, because Chrome screenshots its own error
# page. That is why the image has to be read back rather than trusted.
#
# --virtual-time-budget advances requestAnimationFrame but not proportionally:
# in testing, 500ms and 3000ms gave an identical frame while 9000ms differed. It
# is reliable for "does this render at all" and for static UI. To land on a
# chosen animation moment, drive the page with puppeteer-core and control the
# clock directly.
