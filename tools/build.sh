#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
GODOT_BIN="${GODOT_BIN:-godot}"

mkdir -p "${BUILD_DIR}/windows" "${BUILD_DIR}/macos"

"${GODOT_BIN}" --headless --path "${PROJECT_ROOT}" --export-release "Windows Desktop" "${BUILD_DIR}/windows/PlatformerStarter.exe"
"${GODOT_BIN}" --headless --path "${PROJECT_ROOT}" --export-release "macOS" "${BUILD_DIR}/macos/PlatformerStarter.zip"
