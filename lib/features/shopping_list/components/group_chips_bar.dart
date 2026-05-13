import 'package:flutter/material.dart';
import 'package:shoppinglist/components/frame/app_chip.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// グループ切替の横スクロールチップ群（高さ 46）。
/// `design_handoff_shopping_list/source/screens-list.jsx#GroupChips` 相当。
/// グループが 1 つのときは非表示。
class GroupChipsBar extends StatelessWidget {
  final List<Group> groups;
  final String currentGroupID;
  final void Function(String groupID) onGroupChanged;

  const GroupChipsBar({
    super.key,
    required this.groups,
    required this.currentGroupID,
    required this.onGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.length <= 1) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // 仕様: padding `0 16px 8px`（screens-list.jsx L42）。上余白は ListTopBar 側で吸収。
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final group = groups[index];
          final selected = group.id == currentGroupID;
          return AppChip(
            label: group.name ?? 'グループ',
            active: selected,
            soft: true,
            // 仕様: active 時は check、非アクティブは people（複数人グループの抽象）。
            icon: selected ? Icons.check : Icons.people_outline,
            onTap: selected
                ? null
                : () {
                    analytics.logEvent(
                      name: 'tap_switch_group',
                      parameters: {
                        'fromGroupID': currentGroupID,
                        'toGroupID': group.id,
                      },
                    );
                    onGroupChanged(group.id);
                  },
          );
        },
      ),
    );
  }
}
