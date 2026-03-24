
.PHONY: secret
secret:
	echo $(FIREBASE_BASE64_IOS) | base64 --decode > ios/Firebase/GoogleService-Info.plist
	echo $(FIREBASE_BASE64_ANDROID) | base64 --decode > android/app/src/google-services.json
	echo $(XCCONFIG_SECRET) | base64 --decode > ios/Flutter/Secret.xcconfig
	./scripts/secret.sh



