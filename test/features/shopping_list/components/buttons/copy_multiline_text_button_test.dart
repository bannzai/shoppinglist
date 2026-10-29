import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_shopping_list_item.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/features/shopping_list/components/buttons/copy_multiline_text_button.dart';
import 'package:shoppinglist/provider/current_user_id.dart';
import 'package:shoppinglist/provider/shopping_list_item.dart';

/// #486 / #492 のバグクラス回帰テスト。
///
/// 固定したい挙動: コールバックが `await`（ここでは `Clipboard.getData`）した後、
/// その await 中に対象 widget が unmount されても、後半の追加処理（Firestore 書き込み相当）が
/// 完走し、`StateError('Cannot use "ref" after the widget was disposed.')` を握りつぶさないこと。
///
/// 新規約（build 内で `ref.watch` → ローカル変数キャプチャ → コールバックは変数だけ参照）では、
/// コールバックが `ref` に触れないため unmount 後も安全に完走する。旧規約（コールバック内 `ref.read`）
/// では unmount 後に `ref.read` が StateError を投げて追加が 1 件も実行されなかった（#486 の症状）。
/// 後者の事実は末尾の「アンチパターン検証」テストで固定する。
void main() {
  // 追加処理の呼び出しを記録する `AddShoppingListItem` の差し替え（Firestore を叩かない）。
  // #486 では「コールバック後半 = この call が実行されない」ため、記録した message で完走を検証する。

  testWidgets('unmount 後もクリップボード貼り付けの追加処理が完走し StateError を握りつぶさない', (
    tester,
  ) async {
    final recordingAdd = _RecordingAddShoppingListItem();

    // Clipboard.getData の await を Completer で制御する。
    // これで「await 中に対象 widget を unmount → その後 await を完了」というシーケンスを作れる。
    final clipboardGate = Completer<void>();
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          await clipboardGate.future;
          return <String, dynamic>{'text': '牛乳\n卵'};
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    // true/false で対象 widget のツリー着脱を切り替える。false にすると unmount される。
    final visible = ValueNotifier<bool>(true);
    addTearDown(visible.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIDProvider.overrideWithValue('u'),
          addShoppingListItemProvider(
            groupID: 'g',
          ).overrideWith((ref) => recordingAdd),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: visible,
              builder: (context, show, _) {
                return show
                    ? const CopyMultilineTextButton(
                      groupID: 'g',
                      shoppingListID: 's',
                      shoppingListItems: [],
                    )
                    : const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // タップ → onPressed 開始 → Clipboard.getData の await に入る。
    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();

    // await 中に対象 widget をツリーから外す（unmount）。
    visible.value = false;
    await tester.pump();
    expect(
      find.byType(CopyMultilineTextButton),
      findsNothing,
      reason: '対象 widget が unmount された状態を作る',
    );

    // await を完了させ、コールバック後半（追加処理のループ）を走らせる。
    clipboardGate.complete();
    await tester.pumpAndSettle();

    // build でキャプチャした addShoppingListItem を使うため、unmount 後も追加が完走する。
    // 重複しない 2 行なので 2 件追加される。
    expect(recordingAdd.addedMessages, [
      '牛乳',
      '卵',
    ], reason: 'unmount 後もコールバック後半の追加処理が完走する');
    // unmount 後の ref 使用による StateError 等が発生・握りつぶされていないこと。
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    '[アンチパターン検証] コールバック内 ref.read は unmount 後に StateError を投げる（#486 の旧挙動）',
    (tester) async {
      // #486 の握りつぶしを再現するため、旧規約 widget の catch で StateError を捕捉して記録する。
      final capturedErrors = <Object>[];
      final gate = Completer<void>();
      final visible = ValueNotifier<bool>(true);
      addTearDown(visible.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserIDProvider.overrideWithValue('u'),
            addShoppingListItemProvider(
              groupID: 'g',
            ).overrideWith((ref) => _RecordingAddShoppingListItem()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ValueListenableBuilder<bool>(
                valueListenable: visible,
                builder: (context, show, _) {
                  return show
                      ? _RefReadAfterAwaitButton(
                        gate: gate.future,
                        onError: capturedErrors.add,
                      )
                      : const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // タップ → onPressed 開始 → gate の await に入る。
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      // await 中に対象 widget を unmount する。
      visible.value = false;
      await tester.pump();

      // await を完了 → コールバック後半の ref.read が走る。
      gate.complete();
      await tester.pumpAndSettle();

      // 旧規約は unmount 後に ref.read が StateError を投げる。この事実が #492 の
      // 書き換え（build でキャプチャ）の必要性と、上の回帰テストの意義を裏付ける。
      expect(capturedErrors, hasLength(1));
      expect(capturedErrors.single, isStateError);
      expect(
        (capturedErrors.single as StateError).message,
        // Riverpod 3 の文言 (flutter_riverpod の ConsumerStatefulElement._assertNotDisposed)。
        contains('has been unmounted is unsafe'),
      );
    },
  );
}

/// 追加処理の呼び出しを記録する `AddShoppingListItem` の差し替え（Firestore を叩かない）。
class _RecordingAddShoppingListItem extends AddShoppingListItem {
  /// call された message を順に記録する。unmount 後も後半処理が完走したかの検証に使う。
  final List<String> addedMessages = [];

  _RecordingAddShoppingListItem()
    : super(database: GroupDatabase(groupID: 'g'));

  @override
  Future<GroupShoppingListItem> call({
    required String shoppingListID,
    required String userID,
    required String message,
    required int order,
    required String? description,
    required String? color,
  }) async {
    addedMessages.add(message);
    return GroupShoppingListItem(
      id: 'id',
      groupID: 'g',
      shoppingListID: shoppingListID,
      userID: userID,
      message: message,
      order: order,
      description: description,
      color: color,
      checkedByUserID: null,
      imageURL: null,
      lastEditedByUserID: null,
    );
  }
}

/// #486 の旧規約（コールバック内 `ref.read`）を再現する検証専用 widget。
/// コールバックが await した後に build でキャプチャせず `ref.read` するため、await 中に
/// unmount されると `ref.read` が StateError を投げる。実際の #486 と同様に catch で捕捉し、
/// [onError] へ渡して握りつぶし挙動まで再現する。
class _RefReadAfterAwaitButton extends ConsumerWidget {
  final Future<void> gate;
  final void Function(Object error) onError;
  const _RefReadAfterAwaitButton({required this.gate, required this.onError});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () async {
        await gate;
        try {
          ref.read(addShoppingListItemProvider(groupID: 'g'));
        } catch (e) {
          onError(e);
        }
      },
      child: const Icon(Icons.content_paste_go),
    );
  }
}
