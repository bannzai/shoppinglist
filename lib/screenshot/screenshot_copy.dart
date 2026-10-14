/// App Store / Google Play のスクリーンショットに焼き込むキャッチコピー。
///
/// アプリ本体には i18n 基盤が無く、ストアの対応言語とアプリの表示言語も一致しないため、
/// スクリーンショット専用の静的辞書として持つ。アプリ本体の文言とは独立して更新する。
library;

import 'dart:ui';

/// ストアのロケール (`screenshotCopies` のキー) に対応する、アプリ画面の表示ロケール。
///
/// アプリの arb は言語コードだけで分かれている (`app_ja.arb` / `app_en.arb`) ため、
/// `en-US` のような地域付きのキーは言語コードに落とす。
Locale screenshotAppLocale({required String storeLocale}) =>
    Locale(storeLocale.split('-').first);

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
      headline: 'キーワードを覚えて\n自動で仕分け',
      subheadline: '一度登録すれば、次からは勝手にまとまる',
    ),
    ScreenshotCopy(
      headline: 'レシートや広告を\n撮るだけで追加',
      subheadline: 'AI が品名を読み取ってリストにします',
    ),
    ScreenshotCopy(
      headline: 'AI が売り場まで\n振り分ける',
      subheadline: '追加したその場で、いつもの並び順に',
    ),
    ScreenshotCopy(headline: 'リストごとに\n細かく調整', subheadline: '保存期間・招待・複製をこの画面から'),
  ],
  'en-US': [
    ScreenshotCopy(
      headline: 'One list,\nshared with family',
      subheadline: 'Add and check off items in real time',
    ),
    ScreenshotCopy(
      headline: 'Teach it once,\nsorted forever',
      subheadline: 'Keywords file new items automatically',
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
      headline: 'Fine-tune\neach list',
      subheadline: 'Retention, invites, and duplication in one place',
    ),
  ],
};
