/// App Store / Google Play のスクリーンショットに焼き込むキャッチコピー。
///
/// アプリ本体には i18n 基盤が無く、ストアの対応言語とアプリの表示言語も一致しないため、
/// スクリーンショット専用の静的辞書として持つ。アプリ本体の文言とは独立して更新する。
library;

/// 1 枚のスクリーンショットに載せる見出しと補足。
class ScreenshotCopy {
  /// 大きく表示する主見出し。
  final String headline;

  /// 見出しの下に小さく添える補足。
  final String subheadline;

  const ScreenshotCopy({required this.headline, required this.subheadline});
}

/// ストアのロケール (`ja` / `en-US`) ごとの、ページ順に並んだキャッチコピー。
///
/// キーはストアが使うロケール識別子で、`ios/fastlane/metadata/` のディレクトリ名と揃える。
const screenshotCopies = <String, List<ScreenshotCopy>>{
  'ja': [
    ScreenshotCopy(
      headline: '家族と、ひとつの\n買い物リスト',
      subheadline: '追加も、チェックも、リアルタイムで共有',
    ),
    ScreenshotCopy(
      headline: '売り場ごとに\n自動でまとまる',
      subheadline: 'カテゴリ順は店内の動線に合わせて並べ替え',
    ),
    ScreenshotCopy(
      headline: 'レシートや広告を\n撮るだけで追加',
      subheadline: 'AI が品名を読み取ってリストにします',
    ),
    ScreenshotCopy(
      headline: 'AI が売り場まで\n振り分ける',
      subheadline: '追加したその場で、いつもの並び順に',
    ),
    ScreenshotCopy(
      headline: 'お店ごとに\nリストを分ける',
      subheadline: 'スーパー、ドラッグストア、いつもの店へ',
    ),
  ],
  'en-US': [
    ScreenshotCopy(
      headline: 'One list,\nshared with family',
      subheadline: 'Add and check off items in real time',
    ),
    ScreenshotCopy(
      headline: 'Sorted by\naisle, automatically',
      subheadline: 'Reorder categories to match your store',
    ),
    ScreenshotCopy(
      headline: 'Snap a receipt,\nget your list',
      subheadline: 'AI reads the item names for you',
    ),
    ScreenshotCopy(
      headline: 'AI sorts them\ninto aisles',
      subheadline: 'Added items land in your usual order',
    ),
    ScreenshotCopy(
      headline: 'A list for\nevery store',
      subheadline: 'Groceries, pharmacy, and your regular stops',
    ),
  ],
};
