
# 接続先 project(dev/prod)は環境変数 FILE_GOOGLE_APPLICATION_CREDENTIALS の「値」で切り替える(Issue #410 / ADR 0030)。
# restoreInquirySnapshot 等はこの GOOGLE_APPLICATION_CREDENTIALS.json で接続先 project が決まる。
.PHONY: secret
secret:
	echo $(FILE_GOOGLE_APPLICATION_CREDENTIALS) | base64 -D > secret/GOOGLE_APPLICATION_CREDENTIALS.json




