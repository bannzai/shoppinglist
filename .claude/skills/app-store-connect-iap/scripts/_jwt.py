#!/usr/bin/env python3
"""ASC API JWT 生成。20 分有効。

Usage (環境変数で渡す):
  ASC_KEY_P8_BASE64   .p8 base64
  ASC_KEY_ID       Key ID
  ASC_ISSUER_ID    Issuer ID

stdout に JWT を出力。
"""
from __future__ import annotations

import base64
import os
import sys
import time

try:
    import jwt
except ImportError:
    sys.stderr.write("Error: PyJWT is required. Install with: pip install pyjwt cryptography\n")
    sys.exit(1)


def main() -> None:
    key_b64 = os.environ.get("ASC_KEY_P8_BASE64")
    key_id = os.environ.get("ASC_KEY_ID")
    issuer_id = os.environ.get("ASC_ISSUER_ID")

    if not all([key_b64, key_id, issuer_id]):
        sys.stderr.write(
            "Error: ASC_KEY_P8_BASE64 / ASC_KEY_ID / ASC_ISSUER_ID are required\n"
        )
        sys.exit(1)

    private_key = base64.b64decode(key_b64).decode("utf-8")
    now = int(time.time())
    token = jwt.encode(
        payload={
            "iss": issuer_id,
            "iat": now,
            "exp": now + 20 * 60,
            "aud": "appstoreconnect-v1",
        },
        key=private_key,
        algorithm="ES256",
        headers={"kid": key_id, "typ": "JWT"},
    )
    sys.stdout.write(token)


if __name__ == "__main__":
    main()
