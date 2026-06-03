import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/provider/app_user.dart';
import 'package:shoppinglist/provider/current_group_id.dart';

/// RootPage の Resolver パターンに倣い、currentGroupID を確定させてから子を描画する。
/// 親(AppEntityPrepareResolver)が defaultGroupID の存在を保証済みのため、ここでは
/// currentGroupID が未設定の間だけ appUser.defaultGroupID を流し込む初期化責務を持つ。
class CurrentGroupResolver extends HookConsumerWidget {
  final Widget Function(BuildContext context) builder;

  const CurrentGroupResolver({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGroupID = ref.watch(currentGroupIDProvider);
    final defaultGroupID =
        ref.watch(appUserProvider).valueOrNull?.defaultGroupID;

    // currentGroupID が未設定の時だけ defaultGroupID で初期化する。
    // build 中の state 変更を避けるため postFrame で反映する。手動切替後は
    // currentGroupID が非nullになるため、この初期化は既存の選択を上書きしない。
    // 依存配列は [currentGroupID, defaultGroupID] — どちらかが変わった時に再評価する。
    useEffect(() {
      if (currentGroupID == null && defaultGroupID != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(currentGroupIDProvider.notifier).update(defaultGroupID);
        });
      }
      return null;
    }, [currentGroupID, defaultGroupID]);

    if (currentGroupID == null) {
      return LaunchLoading.shared();
    }
    return builder(context);
  }
}
