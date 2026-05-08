#!/usr/bin/env bash
# config テンプレを stdout に出力する
# Usage: init.sh > my-app-iap-config.json

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cat "${SCRIPT_DIR}/config_template.json"
