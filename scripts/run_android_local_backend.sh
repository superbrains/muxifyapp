#!/usr/bin/env bash
# Physical Android (USB or wireless ADB): forward device 127.0.0.1:5116 → host :5116,
# then run the app with ApiConstants ADB_REVERSE so requests hit http://127.0.0.1:5116.
#
# Prerequisites: Docker/backend listening on your Mac at port 5116.
# Usage (from repo root or muxify):
#   ./scripts/run_android_local_backend.sh
#   ./scripts/run_android_local_backend.sh --release   # passes extra args to flutter run

set -euo pipefail
cd "$(dirname "$0")/.."

echo "Setting up adb reverse: device tcp:5116 -> host tcp:5116"
adb reverse tcp:5116 tcp:5116

echo "Starting Flutter (ADB_REVERSE=true)…"
exec flutter run --dart-define=ADB_REVERSE=true "$@"
