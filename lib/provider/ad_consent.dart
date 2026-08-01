import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 広告(UMP)のプライバシーオプションフォームの提示が必須かどうか。
/// EEA 等の規制地域では、初回の同意フォーム後もユーザーがいつでも同意内容を
/// 変更・撤回できる導線を用意することが UMP の要件のため、これが true の時だけ
/// 設定画面に「広告のプライバシー設定」を表示する。
///
/// 判定は AdMobNativeAdBanner の requestConsentInfoUpdate が更新した SDK 内の
/// キャッシュを参照する。設定画面を開くたびに再評価できるよう autoDispose にする
/// (更新前・platform channel が無いテスト環境では判定不能のため導線を出さない)。
final adPrivacyOptionsRequiredProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  try {
    return await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  } catch (_) {
    return false;
  }
});
