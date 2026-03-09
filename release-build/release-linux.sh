#! /bin/bash
set -euo pipefail

# Allow callers/CI to override the build output directory.
# Default keeps the historical path used by the original project.
BUILD_DIR="${BUILD_DIR:-../build-Gitnoter-Desktop_Qt_5_8_0_GCC_64bit-Release}"
APP_BIN="${BUILD_DIR}/Gitnoter"

rm -rf ./release/Gitnoter
mkdir -p ./release/Gitnoter

if [[ ! -f "${APP_BIN}" ]]; then
  echo "ERROR: App binary not found at: ${APP_BIN}"
  echo "Set BUILD_DIR to your Qt build output directory."
  exit 1
fi

cp -f "${APP_BIN}" ./release/Gitnoter/

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

# linuxdeployqt is expected to be installed and available on PATH.
linuxdeployqt ./release/Gitnoter/Gitnoter

# Keep compatibility with existing vendored libgit2 naming.
if [[ -f ../src/3rdparty/libgit2/lib/libgit2.so ]]; then
  mkdir -p ./release/Gitnoter/lib
  cp -f ../src/3rdparty/libgit2/lib/libgit2.so ./release/Gitnoter/lib/libgit2.so.24
fi

echo "app version: ${VERSION}"

(
  cd release
  tar -cvzf "Gitnoter-linux-v${VERSION}.tar.gz" Gitnoter
)
