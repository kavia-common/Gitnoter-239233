#! /bin/bash
set -euo pipefail

# Allow callers/CI to override the build output directory.
# Default keeps the historical path used by the original project.
BUILD_DIR="${BUILD_DIR:-../build-Gitnoter-Desktop_Qt_5_9_3_clang_64bit-Release}"
APP_SRC="${BUILD_DIR}/Gitnoter.app"

mkdir -p release/
rm -rf ./release/Gitnoter.app

if [[ ! -d "${APP_SRC}" ]]; then
  echo "ERROR: App bundle not found at: ${APP_SRC}"
  echo "Set BUILD_DIR to your Qt build output directory."
  exit 1
fi

cp -R "${APP_SRC}" ./release/

# Extract version from src/version.h in a robust way.
VERSION="$(
  grep -E 'VER_PRODUCTVERSION_STR' ../src/version.h \
    | sed -E 's/.*VER_PRODUCTVERSION_STR[[:space:]]+"([^"]+)".*/\1/' \
    | head -n 1
)"

if [[ -z "${VERSION}" ]]; then
  echo "ERROR: Could not extract VERSION from ../src/version.h"
  exit 1
fi

# macdeployqt is expected to be installed and available on PATH.
macdeployqt ./release/Gitnoter.app

# NOTE:
# The original script rewrote an OpenSSL 1.0.2 Homebrew Cellar path which is
# highly machine-specific and breaks on modern macOS/Homebrew.
# If you still need to patch OpenSSL dylib references, do it in a
# machine-specific packaging step (or migrate to a universal OpenSSL strategy).

# appdmg is expected to be installed and available on PATH.
appdmg ./package-osx/package.json "./release/Gitnoter-osx-v${VERSION}.dmg"
