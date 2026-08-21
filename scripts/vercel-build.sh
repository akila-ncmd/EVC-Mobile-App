#!/usr/bin/env bash
# Vercel's build image has no Flutter runtime, so fetch a pinned SDK and build
# the web bundle. Kept deliberately narrow: a shallow clone of one tag, and
# precache limited to web artifacts, so the build stays a few minutes rather
# than pulling every platform toolchain.
set -euo pipefail

FLUTTER_VERSION="3.44.6"
SDK_DIR="${SDK_DIR:-$HOME/flutter}"

export PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
mkdir -p "$PUB_CACHE"

if [ ! -x "$SDK_DIR/bin/flutter" ]; then
  echo "▸ Fetching Flutter $FLUTTER_VERSION…"
  rm -rf "$SDK_DIR"
  git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$SDK_DIR"
else
  echo "▸ Reusing cached Flutter SDK at $SDK_DIR"
fi

export PATH="$SDK_DIR/bin:$PATH"

# The SDK is cloned as a different owner than the build user on some images.
git config --global --add safe.directory "$SDK_DIR" || true

echo "▸ Flutter version"
flutter --version

echo "▸ Precaching web artifacts only"
flutter precache --web --no-android --no-ios --no-linux --no-macos --no-windows

echo "▸ Resolving dependencies"
flutter pub get

echo "▸ Building release bundle"
flutter build web --release

echo "▸ Build output"
ls -la build/web/index.html
