# 0017. bool×SharedPreferences 設定を汎用 family Provider に統合する

## Status
Accepted

## Context
SharedPreferences の bool 値を 1 つ読み書きするだけの設定プロバイダが、ほぼ同形のまま 3 つ重複していた。

- `AutoNotifyShoppingListUpdate`（key: `autoNotifyShoppingListUpdate`、`toggle()`）
- `HasSeenOnboarding`（key: `hasSeenOnboarding`、`markAsSeen()`）
- `LocationReminderEnabled`（key: `locationReminderEnabled`、`setEnabled({required bool enabled})`）

いずれも次の同一ボイラープレートを各 feature ファイルに散在させていた。

- `ref.watch(sharedPreferencesProvider).getBool(_key) ?? false` で初期値を構築
- `setBool` して `state` を更新する 1 メソッド
- `sharedPreferencesProvider` が override 前提の keepAlive Provider のため、`@Riverpod(keepAlive: true, dependencies: [sharedPreferences])` を付ける必要がある（付け忘れると `UnimplementedError`）

新しい bool 設定を足すたびに同じ Notifier クラスを丸ごと書き写す必要があり、メソッド名（`toggle` / `markAsSeen` / `setEnabled`）も統一されていなかった。

## Decision
key を受け取る単一の汎用 Riverpod family Provider `BoolSharedPreferences` に統合する。

```dart
@Riverpod(keepAlive: true, dependencies: [sharedPreferences])
class BoolSharedPreferences extends _$BoolSharedPreferences {
  @override
  bool build({required String key}) {
    return ref.watch(sharedPreferencesProvider).getBool(key) ?? false;
  }

  /// 値を保存して state を更新する。冪等。
  Future<void> set({required bool value}) async {
    await ref.read(sharedPreferencesProvider).setBool(key, value);
    state = value;
  }

  /// 現在値を反転して保存する。内部で set を呼ぶ。
  /// 反転操作なので冪等ではない。固定値にしたい場合は set を使う。
  Future<void> toggle() => set(value: !state);
}
```

- **family のキーは `key` のみ**。Riverpod の family キャッシュにより、同じ `key` では同一インスタンスが返り、異なる `key` には別インスタンスが割り当てられる（`test/provider/bool_shared_preferences_test.dart` で検証）。
- **既定値は常に `false`**。`defaultValue` を family 引数にはしない。key 以外を引数に含めると「同じ key＝同じインスタンス」という識別性が崩れるため。
- **SharedPreferences のキー文字列は既存の `lib/utils/shared_preferences/keys.dart` の `BoolKey` extension（`static const String`）に集約**する。`StringKey.lastSignInFirebaseAuthUserID` と同じ idiom に揃え、マジック文字列を呼び出し元に散らさない。
- **メソッドは `set({required bool value})` に統一**（冪等）。`toggle()` は bool 値に限り利便のため残すが、反転操作で非冪等な旨をコメントで明記し、内部実装は `set` に委譲する。
- 今後 bool 設定を追加する際は、bespoke な Notifier クラスを新規作成せず、`BoolKey` にキーを足して `boolSharedPreferencesProvider(key: BoolKey.xxx)` を使う。

キー文字列は移行前後で据え置くため、既存ユーザーの永続値・既存テストには影響しない。

## Consequences

### 良い点
- 重複していた 3 クラスを削除でき、新しい bool 設定の追加が「`BoolKey` に 1 行 + 呼び出し」で済む。
- 読み書き API が `set` / `toggle` に統一され、`markAsSeen` / `setEnabled` のような機能ごとに異なるメソッド名がなくなる。
- キーが `BoolKey` extension に一元化され、一覧性・衝突検知が上がる。

### トレードオフ・制約
- この Provider は **bool 型固定**。String / int / enum など他の型の設定には使えない（必要になれば `StringKey` / `IntKey` 同様に別 family を切る）。
- **既定値は `false` 固定**。`true` を既定にしたい設定が出た場合は、build 側で個別対応するか別 Provider を検討する（key 以外を family 引数にすると同一性が崩れるため、安易に `defaultValue` 引数を足さない）。
- `toggle()` は非冪等。固定値を保存したい呼び出し（権限フローの結果反映など）は必ず `set(value:)` を使う。

## 参照
- `lib/provider/bool_shared_preferences.dart`
- `lib/utils/shared_preferences/keys.dart`（`BoolKey` extension）
- `test/provider/bool_shared_preferences_test.dart`（同一key→同一インスタンス / 異なるkey→別インスタンスの検証）
