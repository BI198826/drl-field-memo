#!/bin/sh
# Rebuild the hosted page (../index.html) from app.html, and copy assets to the repo root.
cd "$(dirname "$0")"
{
  echo '<!doctype html><html lang="en"><head><meta charset="utf-8">'
  echo '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">'
  echo '<meta name="theme-color" content="#263746"><link rel="manifest" href="manifest.webmanifest">'
  echo '<link rel="icon" href="icon.svg"><link rel="apple-touch-icon" href="icon-192.png">'
  echo '<meta name="apple-mobile-web-app-capable" content="yes"><meta name="mobile-web-app-capable" content="yes"><meta name="apple-mobile-web-app-title" content="Field Memo">'
  echo '<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style>'
  sed -n '1,/<\/style>/p' app.html
  echo '</head><body>'
  sed -n '/<\/style>/,$p' app.html | tail -n +2
  echo '</body></html>'
} > ../index.html
cp manifest.webmanifest sw.js icon.svg icon-192.png icon-512.png ../
