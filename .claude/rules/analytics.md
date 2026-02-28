---
paths:
  - "lib/features/**/*.dart"
  - "lib/**/components/*.dart"
---

# Analytics 規約

## イベント記録
- ユーザーインタラクションのコールバック先頭で `analytics.logEvent` を呼び出す

## 命名
- name は40文字以内

## パラメータ
- parameters にはスコープ内で自然に取得できるIDを含める

