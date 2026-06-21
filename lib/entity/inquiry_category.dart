/// お問い合わせの種類。
///
/// [wireValue] は Firebase Functions(submitInquiry)の categoryType と一致させること
/// (firebase/functions/src/entity/inquiry.ts の InquiryCategorySchema と同期)。
enum InquiryCategory {
  /// 不具合の報告。
  bugReport(wireValue: 'bugReport', label: '不具合報告'),

  /// 操作方法に関する質問。
  howToUse(wireValue: 'howToUse', label: '操作方法について'),

  /// 機能要望・改善要望。
  request(wireValue: 'request', label: 'ご要望・改善要望'),

  /// その他。
  other(wireValue: 'other', label: 'その他');

  const InquiryCategory({required this.wireValue, required this.label});

  /// Functions へ送る際の識別子。
  final String wireValue;

  /// UI 表示用の日本語ラベル。
  final String label;
}
