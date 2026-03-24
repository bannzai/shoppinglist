import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shoppinglist/provider/shared_preferences.dart';

part 'notification_setting.g.dart';

const _autoNotifyKey = 'autoNotifyShoppingListUpdate';

@Riverpod(keepAlive: true, dependencies: [sharedPreferences])
class AutoNotifyShoppingListUpdate extends _$AutoNotifyShoppingListUpdate {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_autoNotifyKey) ?? false;
  }

  Future<void> toggle() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final newValue = !state;
    await prefs.setBool(_autoNotifyKey, newValue);
    state = newValue;
  }
}
