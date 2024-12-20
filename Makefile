
.PHONY: secret
secret:
	echo $(FILE_FIREBASE) | base64 -D > ios/Firebase/GoogleService-Info.plist


