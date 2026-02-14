# Riverpod 使用ルール

## ref.watch と ref.read の使い分け

### build メソッド内では `ref.watch` を使う
`ConsumerWidget` や `HookConsumerWidget` の `build` メソッド内でProviderの値を取得する場合は、必ず `ref.watch` を使用する。`ref.read` を使うとProviderの値が変化してもWidgetが再ビルドされず、UIに反映されない。

```dart
// OK
@override
Widget build(BuildContext context, WidgetRef ref) {
  final myProvider = ref.watch(myProviderProvider);
  ...
}

// NG: build内でref.readを使ってはいけない
@override
Widget build(BuildContext context, WidgetRef ref) {
  final myProvider = ref.read(myProviderProvider);
  ...
}
```

### `ref.read` を使うべき場面
`onPressed` などのコールバック内や非同期処理のクロージャ内など、build外で一度だけProviderの値を読み取りたい場合に使用する。

```dart
onPressed: () {
  final value = ref.read(someProvider);
  value.doSomething();
}
```

### firestoreのDBに書き込むProviderでの ref.read
firestoreのDBに書き込むProviderでは、`ref.read` を使用してクロージャの中で呼ぶ。
