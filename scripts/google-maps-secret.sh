#!/bin/bash
# Google Maps クライアントキーを環境変数から build config 用のローカルファイルへ書き出す (`make secret` から呼ぶ)。
#
# 入力 (環境変数。未設定は空として書く):
#   GOOGLE_MAPS_API_KEY_IOS_DEV / GOOGLE_MAPS_API_KEY_IOS_PROD / GOOGLE_MAPS_API_KEY_ANDROID_DEV / GOOGLE_MAPS_API_KEY_ANDROID_PROD
# 出力 (どちらも gitignore 済み):
#   ios/Flutter/GoogleMaps.xcconfig  (Debug.xcconfig / Release.xcconfig が #include? で読む)
#   android/google-maps.properties   (android/app/build.gradle が読む)
#
# 値の正は GCP Secret Manager の google-maps-sdk-ios-apikey / google-maps-sdk-android-apikey (dev / prod の各プロジェクト)。
# CI は Workload Identity Federation で Secret Manager から環境変数に取り出し、ローカルは SecChain から
# `secchain run -- make secret` で渡す (ADR 0035)。
# 冪等: 同じ環境変数で何度実行しても同じ内容を上書きする。
set -e
set -o pipefail

cat > ios/Flutter/GoogleMaps.xcconfig <<EOF
// make secret が生成する。手で編集しない (生成元: scripts/google-maps-secret.sh)
GOOGLE_MAPS_API_KEY_IOS_DEV = ${GOOGLE_MAPS_API_KEY_IOS_DEV:-}
GOOGLE_MAPS_API_KEY_IOS_PROD = ${GOOGLE_MAPS_API_KEY_IOS_PROD:-}
EOF

cat > android/google-maps.properties <<EOF
# make secret が生成する。手で編集しない (生成元: scripts/google-maps-secret.sh)
googleMapsApiKeyDev=${GOOGLE_MAPS_API_KEY_ANDROID_DEV:-}
googleMapsApiKeyProd=${GOOGLE_MAPS_API_KEY_ANDROID_PROD:-}
EOF
