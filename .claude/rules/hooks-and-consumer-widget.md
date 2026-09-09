---
paths:
  - "lib/**/*.dart"
---

# Hooks・Widget の状態管理ルール

- `useState` の初期値は最初の build でのみ使われるため、Widget 内部でユーザー操作によって変更するローカル状態に使う。
- Provider・Stream・親の引数の最新値は `useState` にコピーせず、build 内で直接参照する。子 Widget で最新性が必要なら子自身で `ref.watch` して購読する。親の引数を build 内でそのまま使う形でも更新を受け取れる。
- hooks を使う Widget は `HookConsumerWidget`、使わない Widget は `ConsumerWidget` にする。
