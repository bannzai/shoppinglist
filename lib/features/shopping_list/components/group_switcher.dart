import 'package:flutter/material.dart';
import 'package:shoppinglist/entity/group.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

class GroupSwitcher extends StatelessWidget {
  final List<Group> groups;
  final String currentGroupID;
  final void Function(String groupID) onGroupChanged;

  const GroupSwitcher({
    super.key,
    required this.groups,
    required this.currentGroupID,
    required this.onGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    // グループが1つの場合は非表示
    if (groups.length <= 1) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: groups.map((group) {
          final isSelected = group.id == currentGroupID;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(group.name ?? 'グループ'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  analytics.logEvent(name: 'tap_switch_group', parameters: {'fromGroupID': currentGroupID, 'toGroupID': group.id});
                  onGroupChanged(group.id);
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : TextColor.gray,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
