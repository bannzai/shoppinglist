# shoppinglist

A new Flutter project.

## Release

TestFlight / Google Play への配布手順は [documents/release.md](documents/release.md) を参照。リリースのたびに `pubspec.yaml` の `version:` を上げる必要がある。

## Firebase Functions のデプロイ

`gh workflow run firebase-deploy.yml -f project=<dev|prod> -f deploy_all=true` で GitHub Actions から行う。認証は Workload Identity Federation で、Secret の SA 鍵は持たない。事前準備と認証の仕組みは [.github/workflows/firebase-deploy.yml](.github/workflows/firebase-deploy.yml) のヘッダーコメント、GCP 側の設定は [scripts/setup-github-actions-wif.sh](scripts/setup-github-actions-wif.sh) を参照。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
