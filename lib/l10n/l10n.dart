import 'package:flutter/widgets.dart';
import 'package:shoppinglist/l10n/app_localizations.dart';

export 'package:shoppinglist/l10n/app_localizations.dart';

/// BuildContext からローカライズ文字列へ `context.l10n.<キー>` で到達するための拡張。
extension L10nBuildContext on BuildContext {
  /// 現在のロケールの AppLocalizations。
  AppLocalizations get l10n => AppLocalizations.of(this);
}
