#!/usr/bin/env python3
# CI 補助: ios/.symlinks/plugins/<plugin> を .flutter-plugins-dependencies から再生成する。
#
# 背景: ios/Podfile は先頭で
#   require '.symlinks/plugins/firebase_core/ios/firebase_sdk_version.rb'
# を読むが、ios/.symlinks は .gitignore 対象でクリーンチェックアウトの CI には存在しない。
# しかも `flutter pub get` / `flutter build ios --config-only` では .symlinks は生成されず
# （pod install 内の flutter_install_all_ios_pods で作られるが、それは Podfile 解析後 ＝ 上記
# require より後で間に合わない）、pod install が require 失敗で落ちる。
# そこで pod install 前に本スクリプトで .symlinks を用意する（冪等）。
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEPS = os.path.join(ROOT, ".flutter-plugins-dependencies")
DEST = os.path.join(ROOT, "ios", ".symlinks", "plugins")

os.makedirs(DEST, exist_ok=True)

with open(DEPS) as f:
    data = json.load(f)

for plugin in data.get("plugins", {}).get("ios", []):
    name = plugin["name"]
    target = plugin["path"]
    link = os.path.join(DEST, name)
    if os.path.islink(link) or os.path.exists(link):
        os.remove(link)
    os.symlink(target, link)
    print(f"{name} -> {target}")
