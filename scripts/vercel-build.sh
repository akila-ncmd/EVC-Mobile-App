#!/usr/bin/env bash
# Vercel has no Flutter runtime, so fetch the SDK, then build the web bundle.
set -euo pipefail

FLUTTER_VERSION="3.44.6"
SDK_DIR="$HOME/flutter"

if [ ! -d "$SDK_DIR" ]; then
  echo "Fetching Flutter $FLUTTER_VERSION…"
  git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$SDK_DIR"
fi

export PATH="$SDK_DIR/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release
