import 'package:flutter/cupertino.dart';
import 'package:shoppinglist/entity/app_user.dart';
import 'package:shoppinglist/utils/functions/firebase_function.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_create.g.dart';

/// サーバー側で上限チェックを行った上でグループを作成する。
class CreateGroup {
  /// グループを作成する。
  Future<void> call({
    required AppUser appUser,
    required String? name,
    required bool setAsDefault,
  }) async {
    try {
      await functions.createGroup(
        createUserID: appUser.id,
        name: name,
        setAsDefault: setAsDefault,
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
