import 'package:flutter/cupertino.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_create.g.dart';

/// サーバー側で上限チェックを行った上でグループを作成する。
class CreateGroup {
  /// グループを作成する。
  /// [iconName] は `design_handoff_shoppinglist/preview/screens-groups.jsx#GroupCreatePage`
  /// で許容される 6 種 (home / cart / fork / cookie / pets / bag) のいずれか。
  Future<void> call({
    required AppUser appUser,
    required String? name,
    required bool setAsDefault,
    required String iconName,
  }) async {
    try {
      await functions.createGroup(
        createUserID: appUser.id,
        name: name,
        setAsDefault: setAsDefault,
        iconName: iconName,
      );
    } catch (e) {
      debugPrint('Failed to create group: $e');
      rethrow;
    }
  }
}

@Riverpod()
CreateGroup createGroup(Ref ref) {
  return CreateGroup();
}
