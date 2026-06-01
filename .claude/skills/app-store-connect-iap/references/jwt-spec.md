# App Store Connect JWT 仕様

## 概要
- アルゴリズム: **ES256** (P-256 ECDSA) のみ
- 有効期限: **20 分以内**（一部 GET 専用 endpoint は最長 6 ヶ月）
- ヘッダ: `Authorization: Bearer <signed-token>`

## ヘッダ
```json
{
  "alg": "ES256",
  "kid": "<Key ID>",
  "typ": "JWT"
}
```

## ペイロード（Team Key）
```json
{
  "iss": "<Issuer ID>",
  "iat": <UNIX epoch>,
  "exp": <UNIX epoch>,
  "aud": "appstoreconnect-v1"
}
```

## ペイロード（Individual Key）
`iss` の代わりに `sub: "user"` 固定。

## scope（任意）
ペイロードに以下を追加すると、トークンの操作対象を制限できる:
```json
"scope": ["GET /v1/apps?filter[platform]=IOS"]
```

## Skill での実装
`_common.sh` の `generate_jwt()` 関数で生成。Python の `cryptography` または `openssl ecparam` + `openssl ec` + base64 で署名。
本 Skill では Python 経由で生成（事前に `pip install pyjwt cryptography` が必要）。

## 参考
- [Generating Tokens for API Requests](https://developer.apple.com/documentation/appstoreconnectapi/generating-tokens-for-api-requests)
