import 'package:flutter/widgets.dart';
import 'package:shoppinglist/l10n/l10n.dart';

/// お問い合わせの種類。
///
/// [wireValue] は Firebase Functions(submitInquiry)の categoryType と一致させること
/// (firebase/functions/src/entity/inquiry.ts の InquiryCategorySchema と同期)。
enum InquiryCategory {
  /// 不具合の報告。
  bugReport(wireValue: 'bugReport'),

  /// 操作方法に関する質問。
  howToUse(wireValue: 'howToUse'),

  /// 機能要望・改善要望。
  request(wireValue: 'request'),

  /// その他。
  other(wireValue: 'other');

  const InquiryCategory({required this.wireValue});

  /// Functions へ送る際の識別子。
  final String wireValue;
}

extension InquiryCategoryL10n on InquiryCategory {
  /// UI 表示用のラベル。
  String label(BuildContext context) => switch (this) {
    InquiryCategory.bugReport => context.l10n.inquiryCategoryBugReport,
    InquiryCategory.howToUse => context.l10n.inquiryCategoryHowToUse,
    InquiryCategory.request => context.l10n.inquiryCategoryRequest,
    InquiryCategory.other => context.l10n.inquiryCategoryOther,
  };
}
