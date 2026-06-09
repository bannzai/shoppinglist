import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shoppinglist/components/dashed_border_box.dart';
import 'package:shoppinglist/components/primitives/app_dialog_shell.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 招待コード表示ダイアログ。
/// `design_handoff_shopping_list/preview/screens-list-settings.jsx#InviteCodeDialog` 準拠。
/// 大きい mono コード + 動的残り時間 (1分ごとに再描画) + コピー (ghost) / 共有 (accent) Pill。
class InvitationCodeDialog extends HookWidget {
  /// 表示する招待コード。
  final String invitationCode;

  /// 招待コードの有効期限。`Functions` から ISO8601 で返ってきたものを `DateTime.parse` した値。
  final DateTime expiresDateTime;

  const InvitationCodeDialog({
    super.key,
    required this.invitationCode,
    required this.expiresDateTime,
  });

  @override
  Widget build(BuildContext context) {
    // 残り時間表示を 1 分ごとに再計算する。Timer は build 内で 1 回だけ作成し、
    // dispose 時に cancel する。
    final now = useState(DateTime.now());
    useEffect(() {
      final timer = Timer.periodic(const Duration(minutes: 1), (_) {
        now.value = DateTime.now();
      });
      return timer.cancel;
    }, const []);

    final neutral = context.appTheme.neutral;
    final remaining = expiresDateTime.difference(now.value);
    final isExpired = remaining.isNegative;
    final remainingText = isExpired
        ? '有効期限切れ'
        : '有効期限: 7日間 ・ 残り ${remaining.inDays}日${remaining.inHours.remainder(24)}時間';

    return AppDialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '招待コード',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: neutral.ink2,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          DashedBorderBox(
            color: neutral.divider,
            borderRadius: 14,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: neutral.surface2,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SelectableText(
                invitationCode,
                textAlign: TextAlign.center,
                style: monoTextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 8,
                  color: neutral.ink,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            remainingText,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: neutral.ink3),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppPill(
                  label: 'コピー',
                  icon: Icons.copy_outlined,
                  variant: AppPillVariant.ghost,
                  large: true,
                  expanded: true,
                  onPressed: () async {
                    analytics.logEvent(
                        name: 'tap_copy_list_invite_code', parameters: null);
                    await Clipboard.setData(
                      ClipboardData(text: invitationCode),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('招待コードをコピーしました')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppPill(
                  label: '共有',
                  icon: Icons.ios_share_outlined,
                  variant: AppPillVariant.accent,
                  large: true,
                  expanded: true,
                  onPressed: () async {
                    analytics.logEvent(
                        name: 'tap_share_list_invite_code', parameters: null);
                    final box = context.findRenderObject() as RenderBox?;
                    await SharePlus.instance.share(
                      ShareParams(
                        text: '買い物リストの招待コード: $invitationCode',
                        sharePositionOrigin: box == null
                            ? null
                            : box.localToGlobal(Offset.zero) & box.size,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
