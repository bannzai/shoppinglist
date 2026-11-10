---
scope: repository
recorded: 2026-11-10
---
# `appShowModalBottomSheet` のシートの中で `appUserProvider` を読むと、読み込み中のまま null になる

`appShowModalBottomSheet` (`lib/utils/stdlib/show_modal_bottom_sheet.dart`) は、シートの中身を `AppResolvers` (`lib/features/resolver/app.dart`) で包み直す。モーダルは root Navigator の側に出て、ページの入れ子の `ProviderScope` の外になるため。

`AppResolvers` は `AuthResolver` → `UserDatabaseResolver` だけで、`AppEntityPrepareResolver` (`lib/features/resolver/app_entntiy_prepare.dart`) を含まない。`appUserProvider` (`lib/provider/app_user.dart`、`@Riverpod(dependencies: [userDatabase])` の Stream) は、本体の画面では `AppEntityPrepareResolver` が watch して値を保っているが、シートのスコープでは誰も watch していない。

そのため、シートの中の Widget が `ref.read(appUserProvider).asData?.value` を読むと `AsyncLoading` のままで null が返る。`if (appUser == null) return;` のような早期 return に入り、何も表示せずに処理が終わる (リストを追加できない不具合の原因がこれだった)。

**なぜ:** Riverpod の autoDispose の Provider は購読する側がいないと値を保たず、Stream の Provider は最初の状態が `AsyncLoading` になる。

**どう使う:** シートの中で `appUser` やプレミアムの判定など、本体のスコープに依る値が要る時は、次のどちらかにする。シートの中で直接 `ref.read` しない。

1. 値をシートの引数で渡す
2. 処理を本体の側に置き、シートからはコールバックで呼ぶ (閉じるための `sheetContext` は引数で受ける)
