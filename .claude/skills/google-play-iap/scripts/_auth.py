#!/usr/bin/env python3
"""Service Account JSON (base64) から OAuth2 access token を取得する。

Usage (環境変数で渡す):
  GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64

stdout に access_token を出力。
"""
from __future__ import annotations

import base64
import json
import os
import sys
import time
import urllib.parse
import urllib.request

try:
    import jwt
except ImportError:
    sys.stderr.write("Error: PyJWT is required. Install with: pip3 install pyjwt cryptography\n")
    sys.exit(1)


SCOPE = "https://www.googleapis.com/auth/androidpublisher"
TOKEN_URL = "https://oauth2.googleapis.com/token"


def main() -> None:
    sa_b64 = os.environ.get("GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64")
    if not sa_b64:
        sys.stderr.write("Error: GOOGLE_PLAY_SERVICE_ACCOUNT_BASE64 is required\n")
        sys.exit(1)

    sa = json.loads(base64.b64decode(sa_b64))
    now = int(time.time())
    assertion = jwt.encode(
        payload={
            "iss": sa["client_email"],
            "scope": SCOPE,
            "aud": TOKEN_URL,
            "iat": now,
            "exp": now + 3600,
        },
        key=sa["private_key"],
        algorithm="RS256",
    )

    body = urllib.parse.urlencode({
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": assertion,
    }).encode("utf-8")

    request = urllib.request.Request(TOKEN_URL, data=body, method="POST")
    with urllib.request.urlopen(request) as response:
        result = json.loads(response.read())

    sys.stdout.write(result["access_token"])


if __name__ == "__main__":
    main()
