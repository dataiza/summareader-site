#!/usr/bin/env bash
# Copies the assets this site borrows from the app repo, and says so when the
# documents it was written from have moved on.
#
# It cannot tell you *what* changed — only that something did, at the point
# where fixing it is cheap. That is the whole job.
set -euo pipefail

app="${1:-../summareader}"
[ -d "$app/docs/images" ] || { echo "No app repo at $app. Pass its path." >&2; exit 1; }

cp "$app"/docs/images/*.png img/
cp "$app"/assets/fonts/*.ttf fonts/

drifted=0
check() {  # <file in the app repo> <page here that was written from it>
  want=$(sha256sum "$app/$1" | cut -d' ' -f1)
  have=$(grep -o 'sha256:[0-9a-f]\{64\}' "$2" | head -1 | cut -d: -f2)
  if [ "$want" != "$have" ]; then
    echo "$1 has changed since $2 was written from it."
    echo "  read the diff, bring $2 with it, then pin: sha256:$want"
    drifted=1
  fi
}
check docs/USER_GUIDE.md guide.html
check PRIVACY.md privacy.html

if [ "$(git status --porcelain img fonts)" ]; then
  echo "img/ or fonts/ changed — commit the new ones."
fi
[ "$drifted" = 0 ] && echo "In step with $app."
exit "$drifted"
