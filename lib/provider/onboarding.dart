import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';

part 'onboarding.g.dart';

const _onboardingShownKey = 'hasSeenOnboarding';

/// オンボーディング画面（OnboardingPage）を表示済みかどうか。
/// `false` のときに未認証ユーザーへ OnboardingPage を出す。
/// 完了時に `markAsSeen()` を呼ぶと SharedPreferences に true が永続化される。
@Riverpod(keepAlive: true, dependencies: [sharedPreferences])
class HasSeenOnboarding extends _$HasSeenOnboarding {
  @override
  bool build() {
    return ref
            .watch(sharedPreferencesProvider)
            .getBool(_onboardingShownKey) ??
        false;
  }

  Future<void> markAsSeen() async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_onboardingShownKey, true);
    state = true;
  }
}
