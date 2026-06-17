# 0028. エラー表示をタイトル・メッセージ・StackTrace に分離する

## Status

Accepted

## Context

エラーを UI に表示する際、`catch (e) { ... Text(e.toString()) }` のように `e.toString()` をそのまま画面へ流す箇所がアプリ全体に多数存在していた。

`FirebaseException`（`FirebaseFunctionsException` 等を含む）の `toString()` は本文末尾に `\n\n$stackTrace` を連結する仕様のため、これをトーストやスナックバーに渡すと **画面に StackTrace がそのまま露出** する。レシート投稿の `uploadReceiptImage` が `[firebase_functions/internal] INTERNAL` を返した際、トーストに長大な StackTrace が表示され、ユーザーが驚く状態になっていた。

一方でコーディング規約（`.claude/rules/coding-conventions.md`）は「エラーメッセージは基本的にそのまま表示する（`e.toString()` の加工・プレフィックス除去等はしない）」と定めており、メッセージ本文を勝手に書き換えることはできない。

要件を整理すると次のとおり:

- アラート・スナックバー・トーストでは、エラーメッセージ／タイトルはそのまま表示しつつ StackTrace は隠す。
- ページ全体にエラーを表示する場合は、メッセージ／タイトルはそのまま表示し、StackTrace もレベルを落として（小さく・控えめな色で）そのまま表示する。
- どの表示経路でも、`debugPrint` と Crashlytics には生のエラー（StackTrace 込み）を記録する。

## Decision

エラーを `(title, message, stackTrace)` のレコードに分解する関数を中核に置き、表示種別で出し分ける。

- `lib/utils/error/error_display.dart`
  - `describeError(Object error, [StackTrace? stackTrace]) → ({String? title, String message, StackTrace? stackTrace})`
    - `FirebaseException` の場合のみ、`toString()` が連結する前の `[plugin/code] message` を本文とし、StackTrace を分離する。それ以外は `error.toString()` をそのまま本文にする。
    - **メッセージ本文は加工しない**（規約踏襲）。整形は「本文から StackTrace を分離すること」だけに限定する。
    - 特定のエラーコード（`firebase_functions/internal` / `unauthenticated` / `permission-denied`）にだけ、ユーザーに意味が伝わる `title` を補う。該当しなければ `title = null`。
  - `logError(Object error, StackTrace? stackTrace)`: `debugPrint` + Crashlytics に生のまま記録する。記録自体が描画を巻き込んで落ちないよう `try/catch` でガードする（Firebase 未初期化のテスト環境で `FirebaseCrashlytics.instance` が `[core/no-app]` を投げるため）。
  - `showErrorSnackBar(BuildContext, Object, [StackTrace?])`: ログ + StackTrace 非表示の SnackBar 表示。
- `lib/components/toast/toast_overlay.dart` の `showGlobalErrorToast(Object, [StackTrace?])`: ログ + StackTrace 非表示のグローバルトースト。
- `lib/components/error/error_view.dart` の `ErrorView`: ページ全体エラー用。タイトル・本文に加え StackTrace を控えめ色・小サイズで常時表示し、表示時に `logError` で一度だけ記録する（`HookWidget` + `useEffect([error])`）。`RetryPage` は `ErrorView` を内包する。
- `lib/components/error/alert.dart` の `showErrorAlert` も `describeError` を利用する。

| 表示種別 | タイトル | メッセージ | StackTrace | ログ(debugPrint/Crashlytics) |
|---|---|---|---|---|
| トースト / スナックバー / アラート | そのまま | そのまま | 隠す | 生のまま記録 |
| ページ全体（ErrorView/RetryPage） | そのまま | そのまま | 控えめに常時表示 | 生のまま記録 |

業務的に意図された例外（`ShoppingListLimitExceededException` のプレミアム上限 upsell 等、アクション付きで StackTrace 露出が無いもの）はこの分離の対象外とする。

## Consequences

### 良い点
- StackTrace の画面露出がなくなり、ユーザー向け表示が一貫する。
- エラー表示箇所が `describeError` / `showErrorSnackBar` / `showGlobalErrorToast` / `ErrorView` に集約され、新規コードも同じ経路で書ける。
- どの表示経路でも生のエラーが必ず `debugPrint` + Crashlytics に残るため、調査時の情報欠落がない。
- メッセージ本文は無加工のため、既存の「エラーはそのまま表示」規約と矛盾しない。

### トレードオフ・注意点
- `describeError` は `FirebaseException` 前提の整形ロジック（`toString()` が StackTrace を連結する仕様への対処）を内部に持つ。Firebase 以外で同様に `toString()` へ StackTrace を連結する独自例外が現れた場合は分岐の追加が必要。
- 特定エラーコードへの `title` 補完は switch によるハードコードのため、コード追加時はここを更新する。

## 参照
- `.claude/rules/coding-conventions.md`（エラーメッセージはそのまま表示）
- [0025. OverlayEntry による前面トースト表示](0025-overlay-entry-foreground-toast.md)
