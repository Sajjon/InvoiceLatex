#!/usr/bin/env bash

# List of LaTeX packages
pkgs=(
  babel-english
  fancyhdr.sty
  arydshln.sty
  lastpage.sty
  datetime2.sty
  fp.sty
  ragged2e.sty
  xstring.sty
  fancybox.sty
  luacode.sty
  threeparttable.sty
)

# Check each package with kpsewhich
for pkg in "${pkgs[@]}"; do
  if ! kpsewhich "${pkg}" > /dev/null; then
    echo "Missing package: ${pkg}" >&2
    exit 1
  fi
done

# All packages found
echo "✅ All required LaTeX packages are installed."
exit 0