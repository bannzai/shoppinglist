
# dev/prod の切替は環境変数の「値」で行う(Issue #410 / ADR 0030)。
# FIREBASE_BASE64_IOS / FIREBASE_BASE64_ANDROID に dev or prod の値をセットした環境で実行する
# (local 開発=dev は direnv 等、release 配布(flutter-deploy)=prod は CI Secrets)。
# bundleId / App Group / Keychain group は build configuration 側(Debug=dev/Release=prod)で分離する。
.PHONY: secret
secret:
	echo $(FIREBASE_BASE64_IOS) | base64 --decode > ios/Firebase/GoogleService-Info.plist
	echo $(FIREBASE_BASE64_ANDROID) | base64 --decode > android/app/google-services.json
	./scripts/secret.sh




# 引数なしの make で ios を実行する (人が手で動作確認するための入口。検査・テストは CI が行う)
.DEFAULT_GOAL := ios

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

# sim-boot で起動したプロジェクト固有の iOS Simulator へ debug ビルドを install + launch する (QA.md「起動方法」の flutter run と同じ。
# dart-define の値は direnv 等の環境変数から渡す。Firebase Emulator に繋ぐ時は flutter run に --dart-define=USE_FIREBASE_EMULATOR=true を足す)。
# flutter run は attach したまま前面で動き続けるため、確認が終わったら q で止める
.PHONY: ios
ios:
	@set -e; \
	simulator_udid="$(SIMULATOR_UDID)"; \
	[ -n "$$simulator_udid" ] || simulator_udid="$$(SCRIPT_QUIET=1 sim-boot | sed -n 's/^DEVICE_UDID=//p' | tail -n 1)"; \
	[ -n "$$simulator_udid" ] || { echo "Error: sim-boot で Simulator を解決できません (sim-boot が PATH にあるか確認するか、SIMULATOR_UDID=<UDID> を指定してください)" >&2; exit 1; }; \
	flutter run --debug -d "$$simulator_udid" --dart-define=SHOPPINGLIST_DEVELOPER_TOKEN=$(SHOPPINGLIST_DEVELOPER_TOKEN) --dart-define=REVENUECAT_TEST_STORE_API_KEY=$(REVENUECAT_TEST_STORE_API_KEY)
