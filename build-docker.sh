#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

CONFIG="${SIGNING_CONFIG:-$ROOT/.build-signing.env}"

if [[ ! -f "$CONFIG" ]]; then
    cat >&2 <<EOF
Missing signing configuration:

  $CONFIG

Create it from the example first:

  cp .build-signing.env.example .build-signing.env

Then edit SIGNING_KEYSTORE so it points to the SAME keystore used to sign
your already-published Silent APK.
EOF
    exit 1
fi

set -a
# shellcheck disable=SC1090
source "$CONFIG"
set +a

: "${SIGNING_KEYSTORE:?SIGNING_KEYSTORE is not set}"
: "${SIGNING_STORE_PASSWORD:?SIGNING_STORE_PASSWORD is not set}"
: "${SIGNING_KEY_ALIAS:?SIGNING_KEY_ALIAS is not set}"
: "${SIGNING_KEY_PASSWORD:?SIGNING_KEY_PASSWORD is not set}"

if [[ ! -f "$SIGNING_KEYSTORE" ]]; then
    echo "Keystore does not exist: $SIGNING_KEYSTORE" >&2
    exit 1
fi

SIGNING_KEYSTORE="$(realpath "$SIGNING_KEYSTORE")"

if [[ ! -d .git ]]; then
    echo "Run this script from the root of the Git checkout." >&2
    exit 1
fi

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    echo "Refusing to build a checkout with modified tracked files." >&2
    echo "Commit/stash your changes first, or set ALLOW_DIRTY=1." >&2
    if [[ "${ALLOW_DIRTY:-0}" != "1" ]]; then
        exit 1
    fi
fi

COMMIT="$(git rev-parse --short=12 HEAD)"
BRANCH="$(git branch --show-current || true)"
SUFFIX="${RELEASE_NAME:-$COMMIT}"
OUT_NAME="EnableScreenshot-Silent-${SUFFIX}.apk"

mkdir -p out
GRADLE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/enable-screenshot-silent/gradle"
mkdir -p "$GRADLE_CACHE"

IMAGE="enable-screenshot-silent-builder:android-37.1"

echo "Building builder image..."
docker build \
    -f "$ROOT/docker/Dockerfile" \
    -t "$IMAGE" \
    "$ROOT/docker"

echo
echo "Building checkout:"
echo "  branch : ${BRANCH:-detached HEAD}"
echo "  commit : $COMMIT"
echo "  output : out/$OUT_NAME"
echo

rm -f "$ROOT/out/$OUT_NAME"

docker run --rm \
    -e HOST_UID="$(id -u)" \
    -e HOST_GID="$(id -g)" \
    -e OUT_NAME="$OUT_NAME" \
    -e SIGNING_STORE_PASSWORD="$SIGNING_STORE_PASSWORD" \
    -e SIGNING_KEY_ALIAS="$SIGNING_KEY_ALIAS" \
    -e SIGNING_KEY_PASSWORD="$SIGNING_KEY_PASSWORD" \
    -v "$ROOT:/src:ro" \
    -v "$SIGNING_KEYSTORE:/signing/release.jks:ro" \
    -v "$ROOT/out:/out" \
    -v "$GRADLE_CACHE:/root/.gradle" \
    "$IMAGE" \
    bash -lc '
        set -euo pipefail

        rm -rf /work/src
        mkdir -p /work/src

        # Copy the exact current checkout, including .git. The project uses Git
        # metadata when calculating its versionCode.
        cp -a /src/. /work/src/
        cd /work/src

        cat > local.properties <<EOF
storeFile=/signing/release.jks
storePassword=${SIGNING_STORE_PASSWORD}
keyAlias=${SIGNING_KEY_ALIAS}
keyPassword=${SIGNING_KEY_PASSWORD}
EOF

        chmod +x ./gradlew

        ./gradlew --no-daemon --stacktrace :app:assembleRelease

        APK="app/build/outputs/apk/release/app-release.apk"
        test -f "$APK"

        /opt/android-sdk/build-tools/36.1.0/apksigner verify \
            --verbose \
            --print-certs \
            "$APK"

        cp "$APK" "/out/$OUT_NAME"
        sha256sum "/out/$OUT_NAME"

        chown "$HOST_UID:$HOST_GID" "/out/$OUT_NAME"
    '

echo
echo "Built successfully:"
echo "  $ROOT/out/$OUT_NAME"
echo
sha256sum "$ROOT/out/$OUT_NAME"
