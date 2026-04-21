#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE_DIR="${ROOT_DIR}/openim-sdk-core"
ANDROID_AAR_SRC="${CORE_DIR}/open_im_sdk.aar"
ANDROID_AAR_DST="${ROOT_DIR}/android/libs/open_im_sdk.aar"
IOS_XCFRAMEWORK_SRC="${CORE_DIR}/build/OpenIMCore.xcframework"
IOS_XCFRAMEWORK_DST_DIR="${ROOT_DIR}/ios/Framework"
IOS_XCFRAMEWORK_DST="${IOS_XCFRAMEWORK_DST_DIR}/OpenIMCore.xcframework"
EXAMPLE_IOS_DIR="${ROOT_DIR}/example/ios"

log() {
  printf '[update-local-core] %s\n' "$1"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

setup_go_bin_path() {
  local gobin
  gobin="$(go env GOBIN)"
  if [[ -z "${gobin}" ]]; then
    gobin="$(go env GOPATH)/bin"
  fi
  export PATH="${gobin}:${PATH}"
}

ensure_gomobile() {
  require_cmd go
  setup_go_bin_path

  if ! command -v gomobile >/dev/null 2>&1; then
    log "Installing gomobile"
    go install golang.org/x/mobile/cmd/gomobile@latest
  fi

  if ! command -v gobind >/dev/null 2>&1; then
    log "Installing gobind"
    go install golang.org/x/mobile/cmd/gobind@latest
  fi

  log "Initializing gomobile"
  gomobile init
}

build_android_aar() {
  log "Building Android AAR from ${CORE_DIR}"
  (
    cd "${CORE_DIR}"
    GOARCH=amd64 gomobile bind -v -trimpath -ldflags="-s -w" \
      -o "${ANDROID_AAR_SRC}" -target=android ./open_im_sdk/ ./open_im_sdk_callback/
  )
}

build_ios_xcframework() {
  log "Building iOS xcframework from ${CORE_DIR}"
  (
    cd "${CORE_DIR}"
    rm -rf build/ open_im_sdk/t_friend_sdk.go open_im_sdk/t_group_sdk.go open_im_sdk/ws_wrapper/
    GOARCH=arm64 gomobile bind -v -trimpath -ldflags="-s -w" \
      -o build/OpenIMCore.xcframework -target=ios ./open_im_sdk/ ./open_im_sdk_callback/
  )
}

copy_ios_framework() {
  mkdir -p "${IOS_XCFRAMEWORK_DST_DIR}"
  rm -rf "${IOS_XCFRAMEWORK_DST}"
  cp -R "${IOS_XCFRAMEWORK_SRC}" "${IOS_XCFRAMEWORK_DST}"
}

main() {
  if [[ ! -d "${CORE_DIR}" ]]; then
    printf 'Core directory not found: %s\n' "${CORE_DIR}" >&2
    exit 1
  fi

  require_cmd flutter
  require_cmd pod
  ensure_gomobile

  build_android_aar

  if [[ ! -f "${ANDROID_AAR_SRC}" ]]; then
    printf 'Android AAR not found after build: %s\n' "${ANDROID_AAR_SRC}" >&2
    exit 1
  fi

  mkdir -p "$(dirname "${ANDROID_AAR_DST}")"
  cp "${ANDROID_AAR_SRC}" "${ANDROID_AAR_DST}"
  log "Copied Android AAR to ${ANDROID_AAR_DST}"

  if [[ "$(uname -s)" != "Darwin" ]]; then
    printf 'iOS build requires macOS. Current OS: %s\n' "$(uname -s)" >&2
    exit 1
  fi

  build_ios_xcframework

  if [[ ! -d "${IOS_XCFRAMEWORK_SRC}" ]]; then
    printf 'iOS xcframework not found after build: %s\n' "${IOS_XCFRAMEWORK_SRC}" >&2
    exit 1
  fi

  copy_ios_framework
  log "Copied iOS xcframework to ${IOS_XCFRAMEWORK_DST}"

  log "Refreshing Flutter dependencies"
  (
    cd "${ROOT_DIR}"
    flutter clean
    flutter pub get
  )

  log "Running pod install for example app"
  (
    cd "${EXAMPLE_IOS_DIR}"
    pod install
  )

  log "Done"
}

main "$@"
