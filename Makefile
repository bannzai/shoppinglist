
# dev/prod の切替は環境変数の「値」で行う(Issue #410 / ADR 0030)。
# FIREBASE_BASE64_IOS / FIREBASE_BASE64_ANDROID に dev or prod の値をセットした環境で実行する
# (local 開発=dev は direnv 等、release 配布(flutter-deploy)=prod は CI Secrets)。
# bundleId / App Group / Keychain group は build configuration 側(Debug=dev/Release=prod)で分離する。
.PHONY: secret
secret:
	echo $(FIREBASE_BASE64_IOS) | base64 --decode > ios/Firebase/GoogleService-Info.plist
	echo $(FIREBASE_BASE64_ANDROID) | base64 --decode > android/app/google-services.json
	./scripts/secret.sh




# 引数なしの make で動作確認 (verify) を実行する
.DEFAULT_GOAL := verify

.PHONY: verify
verify:
	flutter pub get
	dart pub run build_runner build --delete-conflicting-outputs
	flutter analyze --no-pub --no-fatal-infos --fatal-warnings
	dart format --set-exit-if-changed ./
	flutter test
	cd firebase/functions && npm ci
	cd firebase/functions && npm run lint
	cd firebase/functions && npm run build
	cd firebase/functions && npm test
