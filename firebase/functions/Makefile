
# 接続先 project(dev/prod)は環境変数 FILE_GOOGLE_APPLICATION_CREDENTIALS の「値」で切り替える(Issue #410 / ADR 0030)。
# restoreInquirySnapshot 等はこの GOOGLE_APPLICATION_CREDENTIALS.json で接続先 project が決まる。
# 書き出し先は Functions の source (このディレクトリ) の外にする。source 内に置くと firebase deploy が
# 関数のソースと一緒に鍵をアップロードするため(Issue #675)。
.PHONY: secret
secret:
	mkdir -p ../.secret
	echo $(FILE_GOOGLE_APPLICATION_CREDENTIALS) | base64 -D > ../.secret/GOOGLE_APPLICATION_CREDENTIALS.json




