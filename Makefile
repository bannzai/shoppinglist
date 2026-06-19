
# dev/prod の切替は環境変数の「値」で行う(Issue #410 / ADR 0030)。
# FIREBASE_BASE64_IOS / FIREBASE_BASE64_ANDROID に dev or prod の値をセットした環境で実行する
# (local 開発=dev は direnv 等、release 配布(flutter-deploy)=prod は CI Secrets)。
# bundleId / App Group / Keychain group は build configuration 側(Debug=dev/Release=prod)で分離する。
.PHONY: secret
secret:
	echo $(FIREBASE_BASE64_IOS) | base64 --decode > ios/Firebase/GoogleService-Info.plist
	echo $(FIREBASE_BASE64_ANDROID) | base64 --decode > android/app/google-services.json
	./scripts/secret.sh



