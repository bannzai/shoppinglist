# shoppinglist

A new Flutter project.

## Release

TestFlight / Google Play への配布手順は [documents/release.md](documents/release.md) を参照。リリースのたびに `pubspec.yaml` の `version:` を上げる必要がある。

## ローカルの secret の復元

Firebase の設定ファイルと Google Maps のクライアントキーはリポジトリに入っていない。手元では SecChain に保管した値を渡して `make secret` で復元する (値の正は GCP Secret Manager。設計は [documents/adr/0035](documents/adr/0035-google-maps-keys-in-secret-manager-restored-by-make-secret.md))。

```sh
secchain run -- make secret
```

Maps キーの名前は `GOOGLE_MAPS_API_KEY_IOS_DEV` / `GOOGLE_MAPS_API_KEY_IOS_PROD` / `GOOGLE_MAPS_API_KEY_ANDROID_DEV` / `GOOGLE_MAPS_API_KEY_ANDROID_PROD` で、Secret Manager の `google-maps-sdk-ios-apikey` / `google-maps-sdk-android-apikey` (dev は `shoppinglist-dev-b2787`、prod は `shoppinglist-prod-857bb`) に対応する。SecChain に無い名前は、Secret Manager から値を画面に出さずに写す:

```sh
gcloud secrets versions access latest --secret=google-maps-sdk-ios-apikey --project=shoppinglist-dev-b2787 | secchain set GOOGLE_MAPS_API_KEY_IOS_DEV
```

`make secret` を通さないビルドでも地図以外は動く (Maps キーが空になり地図だけ描画されない)。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
