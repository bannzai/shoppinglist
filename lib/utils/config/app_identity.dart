import 'package:flutter/foundation.dart';

/// dev(debug)ビルドを本番と分離するための識別子サフィックス。
///
/// iOS build configuration(Debug=dev / Release=prod), Swift `#if DEBUG`,
/// Android `applicationIdSuffix` と必ず一致させること(Issue #410 / ADR 0030)。
/// `kDebugMode` は const のため、この値以下もすべて const に解決される。
const _environmentSuffix = kDebugMode ? '.dev' : '';

/// Firebase Auth の Keychain 共有グループ(本体と Widget で共有)。dev/prod で分離する。
///
/// `ios/Runner/Runner.entitlements` / `ios/ShoppingListWidget/ShoppingListWidget.entitlements`
/// の `keychain-access-groups`(= `$(AppIdentifierPrefix)$(KEYCHAIN_ACCESS_GROUP)`)と同じ値になる。
const keychainAccessGroup =
    'TQPN82UBBY.com.bannzai.shoppinglist$_environmentSuffix';

/// 本体と Widget が共有する App Group ID。dev/prod で分離する。
///
/// entitlements の `com.apple.security.application-groups`(= `$(APP_GROUP_ID)`)と同じ値になる。
const appGroupId = 'group.com.bannzai.shoppinglist$_environmentSuffix';
