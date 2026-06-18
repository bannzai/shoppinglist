import 'package:flutter/material.dart';
import 'package:shoppinglist/components/primitives/app_chip.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// グループ切替の横スクロールチップ群（高さ 46）。
/// `design_handoff_shopping_list/source/screens-list.jsx#GroupChips` 相当。
/// 旧 `GroupSwitcher` を置き換える。グループが 1 つのときは非表示。
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
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final group = groups[index];
          final selected = group.id == currentGroupID;
          return AppChip(
            label: group.name ?? 'グループ',
            active: selected,
            soft: true,
            icon: selected ? Icons.check : null,
            onTap:
                selected
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
            dotColor: null,
          );
        },
      ),
    );
  }
}
