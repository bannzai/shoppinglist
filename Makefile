
.PHONY: secret
secret:
	echo $(FILE_FIREBASE) | base64 -D > shoppinglist/ios/GoogleService-Info.plist


