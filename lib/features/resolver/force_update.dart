import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/alert/ok.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/force_update.dart';
import 'package:shoppinglist/utils/logger/error.dart';
import 'package:shoppinglist/utils/config/platform.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateResolver extends HookConsumerWidget {
  final Widget Function(BuildContext) builder;

  const ForceUpdateResolver({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkForceUpdate = ref.watch(checkForceUpdateProvider);
    final shouldForceUpdate = useState(false);
    // 起動時に強制アップデートの要否を Remote Config ベースで確認する。
    // 依存配列は [checkForceUpdate] — provider が生存している限り同一インスタンスのため、
    // 実行はマウント時の1回のみ。Remote Config のリアルタイム更新は activate() を呼ぶだけで
    // remoteConfigParameterProvider を invalidate しないため、実行中の再チェックは行われない。
    useEffect(() {
      void f() async {
        try {
          // 多少データが変更される可能性があるが、それは許容する。ほとんど問題はないはず
          // 起動時間を優先する
          if (await checkForceUpdate()) {
            shouldForceUpdate.value = true;
          }
        } catch (e, st) {
          errorLogger.recordError(e, st);
        }
      }

      f();
      return null;
    }, [checkForceUpdate]);

    if (shouldForceUpdate.value) {
      Future.microtask(() async {
        if (!context.mounted) {
          return;
        }

        await showOKDialog(
          context,
          icon: Icons.error,
          title: context.l10n.forceUpdateTitle,
          message: context.l10n.forceUpdateMessage(storeName),
          ok: () async {
            await launchUrl(
              Uri.parse(forceUpdateStoreURL),
              mode: LaunchMode.externalApplication,
            );
          },
        );
      });
      return LaunchLoading.shared();
    }

    return builder(context);
  }
}
