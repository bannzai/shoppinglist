// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '買い物リスト';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonDone => '完了';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDelete => '削除';

  @override
  String get commonAdd => '追加';

  @override
  String get commonRetry => '再試行';

  @override
  String get commonUndo => '元に戻す';

  @override
  String get commonUpgrade => 'アップグレード';

  @override
  String get commonSettings => '設定';

  @override
  String get commonCategory => 'カテゴリ';

  @override
  String get commonUncategorized => '未分類';

  @override
  String get commonGroup => 'グループ';

  @override
  String get commonCamera => 'カメラ';

  @override
  String get commonPhotoLibrary => 'フォトライブラリ';

  @override
  String get commonErrorOccurred => 'エラーが発生しました';

  @override
  String get errorUnknownTitle => '不明なエラーが発生しました';

  @override
  String get errorUnexpectedTitle => '予期せぬエラーが発生しました';

  @override
  String get errorFaqLink => 'FAQを見る';

  @override
  String get authGoogleSignIn => 'Google でサインイン';

  @override
  String get loadingPreparing => '準備中...';

  @override
  String get accountDeleteButton => 'アカウントを削除する';

  @override
  String get accountDeleteConfirmTitle => 'ユーザー情報を削除します';

  @override
  String get accountDeleteConfirmMessage => 'アカウントを削除すると、ユーザー情報がすべて削除されます。';

  @override
  String get accountDeleteConfirmButton => '削除する';

  @override
  String get accountDeleteReauthTitle => '再ログインしてください';

  @override
  String get accountDeleteReauthMessage => 'アカウントを削除するには、再ログインしてください。';

  @override
  String get accountDeleteReauthButton => '再ログインする';

  @override
  String get accountDeleteCompletedTitle => 'アカウントを削除しました';

  @override
  String get accountDeleteExitAppQuestion => 'アプリを終了しますか？';

  @override
  String get accountDeleteExitAppButton => '終了する';

  @override
  String get shoppingListDefaultName => '買い物リスト';

  @override
  String get shoppingListSettingTooltip => 'リスト設定';

  @override
  String get shoppingListEmptyTitle => '買い物リストがありません';

  @override
  String get shoppingListEmptyMessage => '新しい買い物リストを作成しましょう';

  @override
  String get shoppingListEmptyCreateButton => '買い物リストを作成';

  @override
  String get shoppingListLoadErrorTitle => 'リストを読み込めませんでした';

  @override
  String get shoppingListPickerTitle => 'リストを切り替える';

  @override
  String get shoppingListPickerAddList => '新しいリストを追加';

  @override
  String get shoppingListCreateListTooltip => 'リストを追加';

  @override
  String get shoppingListCreateTodayList => '今日の日付でリストを追加';

  @override
  String get shoppingListDuplicateCurrentList => '現在のリストを複製';

  @override
  String get shoppingListDuplicateUncheckedOnly => '未チェックのみ引き継いで複製';

  @override
  String get shoppingListDuplicated => 'リストを複製しました';

  @override
  String shoppingListDuplicatedFrom(String name) {
    return '$nameから複製';
  }

  @override
  String get shoppingListDeletedListName => '削除済みリスト';

  @override
  String get shoppingListDuplicateSourceDeleted => '複製元の買い物リストは削除されています';

  @override
  String get shoppingListRetentionBannerMessage => '無料プランは作成から30日でリストが整理されます';

  @override
  String get shoppingListRetentionBannerDetail => '詳しく';

  @override
  String get shoppingListSpotlightTitle => '新しい買い物リストはここから追加できます';

  @override
  String get shoppingListSpotlightMessage => '日付ごとのリストを作ったり、今のリストを複製したりできます。';

  @override
  String get shoppingListSpotlightDismiss => 'タップして閉じる';

  @override
  String get shoppingListAiProcessingImage => '画像から候補を抽出中...';

  @override
  String get shoppingListAiProcessingUrl => 'URL から候補を抽出中...';

  @override
  String get shoppingListAiProcessingCategorize => 'カテゴリ分けを実行中...';

  @override
  String shoppingListAiLimitUpsell(int limit) {
    return '。プレミアムにアップグレードすると月$limit回まで利用できます';
  }

  @override
  String shoppingListAiCategorizeButton(int count) {
    return '自動でカテゴリ分け（$count件）';
  }

  @override
  String shoppingListAiCategorizeLimitReached(int limit) {
    return '自動カテゴリ分けの月間利用回数（$limit回）に達しました';
  }

  @override
  String shoppingListAiCategorizeRegistered(int count) {
    return '$count件をカテゴリに登録しました';
  }

  @override
  String get shoppingListAiCategorizeSheetTitle => '自動カテゴリ分け';

  @override
  String get shoppingListAiCategorizeSheetSubtitle => 'カテゴリを確認・調整して登録してください';

  @override
  String get shoppingListAiCategorizeSheetEmpty => '分類できる候補がありませんでした';

  @override
  String shoppingListAiCategorizeSheetConfirm(int count) {
    return '$count 件を登録';
  }

  @override
  String get shoppingListCategorySelect => 'カテゴリを選択';

  @override
  String get shoppingListCategoryChange => 'カテゴリを変更';

  @override
  String get shoppingListNewCategoryHint => '新しいカテゴリ名';

  @override
  String get shoppingListAddCategoryLabel => 'カテゴリを追加';

  @override
  String get shoppingListAiReviewTitle => '読み取った候補';

  @override
  String get shoppingListAiReviewSubtitle => '追加するアイテムを選んでください';

  @override
  String get shoppingListAiReviewEmpty => '候補がありませんでした';

  @override
  String shoppingListAiReviewConfirm(int count) {
    return '$count 件追加';
  }

  @override
  String get shoppingListFabAddFromPhoto => '写真から追加';

  @override
  String get shoppingListFabAddFromUrl => 'URL から追加';

  @override
  String get shoppingListFabPasteText => 'テキスト貼り付け';

  @override
  String shoppingListImageRecognitionLimitReached(int limit) {
    return '画像読み取りの月間利用回数（$limit回）に達しました';
  }

  @override
  String shoppingListUrlRecognitionLimitReached(int limit) {
    return 'URL読み取りの月間利用回数（$limit回）に達しました';
  }

  @override
  String get shoppingListUrlDialogTitle => 'URLから買い物リストを生成';

  @override
  String get shoppingListUrlDialogGenerate => '生成';

  @override
  String get shoppingListUrlRequired => 'URLを入力してください';

  @override
  String get shoppingListUrlInvalid => '有効なHTTPS URLを入力してください';

  @override
  String get shoppingListStarterRowLabel => 'タップで入力開始';

  @override
  String get shoppingListHintExample1 => '例: 牛乳 1L';

  @override
  String get shoppingListHintExample2 => '例: 卵 1パック';

  @override
  String get shoppingListHintExample3 => '例: パン';

  @override
  String get shoppingListHintExample4 => '例: 玉ねぎ 2個';

  @override
  String get shoppingListHintExample5 => '例: トマト';

  @override
  String get shoppingListHintCardTitle => 'こんな風に使えます';

  @override
  String get shoppingListHintTap => '・タップしてそのまま入力';

  @override
  String get shoppingListHintReturn => '・return で次の行へ';

  @override
  String get shoppingListHintDelete => '・空行で delete で行を消せます';

  @override
  String get shoppingListHintFabPrefix => '・右下の ';

  @override
  String get shoppingListHintFabSuffix => ' を長押しすると写真やURLから追加できます';

  @override
  String get shoppingListItemDetailTooltip => 'アイテム詳細';

  @override
  String get shoppingListItemDeleteTooltip => 'アイテムを削除';

  @override
  String get shoppingListItemDeleteConfirm => 'このアイテムを削除しますか？';

  @override
  String get shoppingListItemDeleted => 'アイテムを削除しました';

  @override
  String get shoppingListItemMemoHint => 'メモを書く...';

  @override
  String get shoppingListNotifyGroup => 'グループに通知';

  @override
  String get shoppingListNotifyGroupSent => 'グループに通知しました';

  @override
  String get shoppingListNotifyGroupGuideLabel => 'グループ通知の説明';

  @override
  String get shoppingListNotifyGroupGuideMessage =>
      'このボタンを押すと、買い物リストを更新したことをグループの他のメンバーにプッシュ通知でお知らせします。';

  @override
  String get shoppingListNotifyGroupSend => '通知を送る';
}
