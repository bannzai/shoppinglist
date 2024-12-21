
.PHONY: secret
secret:
	echo $(IOS_FILE_FIREBASE) | base64 -D > ios/Firebase/GoogleService-Info.plist
	echo $(XCCONFIG_SECRET) | base64 -D > ios/Flutter/Secret.xcconfig
	./scripts/secret.sh



