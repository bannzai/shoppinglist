import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 同じグループの別メンバーが持つカテゴリ設定を、自分の設定へ取り込む導線。
class GroupCategoryImportAction extends StatelessWidget {
  final String groupID;
  final String currentUserID;
  final GroupCategoryAxis? destinationGroupCategoryAxis;

  const GroupCategoryImportAction({
    super.key,
    required this.groupID,
    required this.currentUserID,
    required this.destinationGroupCategoryAxis,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.groupCategoryImportTooltip,
    icon: const Icon(Icons.group_add_outlined),
    onPressed: () async {
      analytics.logEvent(
        name: 'tap_import_member_categories',
        parameters: {'groupID': groupID},
      );
      final importedAxisName = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => _GroupCategoryImportDialog(
              groupID: groupID,
              currentUserID: currentUserID,
              destinationGroupCategoryAxis: destinationGroupCategoryAxis,
            ),
      );
      if (importedAxisName != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            persist: false,
            content: Text(
              context.l10n.groupCategoryImportSuccess(importedAxisName),
            ),
          ),
        );
      }
    },
  );
}

class _GroupCategoryImportDialog extends ConsumerStatefulWidget {
  final String groupID;
  final String currentUserID;
  final GroupCategoryAxis? destinationGroupCategoryAxis;

  const _GroupCategoryImportDialog({
    required this.groupID,
    required this.currentUserID,
    required this.destinationGroupCategoryAxis,
  });

  @override
  ConsumerState<_GroupCategoryImportDialog> createState() =>
      _GroupCategoryImportDialogState();
}

class _GroupCategoryImportDialogState
    extends ConsumerState<_GroupCategoryImportDialog> {
  String? _importingGroupCategoryAxisID;

  @override
  Widget build(BuildContext context) {
    final shareableAxesAsync = ref.watch(
      shareableGroupCategoryAxesProvider(groupID: widget.groupID),
    );
    final profilesAsync = ref.watch(
      groupUserProfilesProvider(groupID: widget.groupID),
    );
    final groupCategoryImportFromMember = ref.watch(
      groupCategoryImportFromMemberProvider(groupID: widget.groupID),
    );

    return PopScope(
      canPop: _importingGroupCategoryAxisID == null,
      child: AlertDialog(
        title: Text(context.l10n.groupCategoryImportTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.groupCategoryImportDescription),
              const SizedBox(height: 16),
              Flexible(
                child: shareableAxesAsync.when(
                  data:
                      (axes) => profilesAsync.when(
                        data: (profiles) {
                          final sourceAxes =
                              axes
                                  .where(
                                    (axis) =>
                                        axis.userID != widget.currentUserID,
                                  )
                                  .toList();
                          if (sourceAxes.isEmpty) {
                            return Center(
                              child: Text(
                                context.l10n.groupCategoryImportEmpty,
                              ),
                            );
                          }
                          final displayNameByUserID = {
                            for (final profile in profiles)
                              profile.userID: profile.displayName,
                          };
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: sourceAxes.length,
                            itemBuilder: (context, index) {
                              final axis = sourceAxes[index];
                              final displayName =
                                  displayNameByUserID[axis.userID];
                              final isImporting =
                                  _importingGroupCategoryAxisID == axis.id;
                              return ListTile(
                                key: ValueKey(
                                  'import-category-axis-${axis.id}',
                                ),
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.person_outline),
                                title: Text(axis.name),
                                subtitle: Text(
                                  displayName == null ||
                                          displayName.trim().isEmpty
                                      ? context
                                          .l10n
                                          .groupCategoryImportMemberFallback
                                      : displayName,
                                ),
                                trailing:
                                    isImporting
                                        ? const SizedBox.square(
                                          dimension: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(Icons.download_outlined),
                                onTap:
                                    _importingGroupCategoryAxisID != null
                                        ? null
                                        : () => _import(
                                          sourceGroupCategoryAxis: axis,
                                          groupCategoryImportFromMember:
                                              groupCategoryImportFromMember,
                                        ),
                              );
                            },
                          );
                        },
                        error: _error,
                        loading: _loading,
                      ),
                  error: _error,
                  loading: _loading,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                _importingGroupCategoryAxisID == null
                    ? () => Navigator.pop(context)
                    : null,
            child: Text(context.l10n.commonCancel),
          ),
        ],
      ),
    );
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());

  Widget _error(Object error, StackTrace stackTrace) =>
      Center(child: Text(error.toString()));

  Future<void> _import({
    required GroupCategoryAxis sourceGroupCategoryAxis,
    required GroupCategoryImportFromMember groupCategoryImportFromMember,
  }) async {
    setState(() {
      _importingGroupCategoryAxisID = sourceGroupCategoryAxis.id;
    });
    try {
      await groupCategoryImportFromMember.call(
        destinationUserID: widget.currentUserID,
        sourceGroupCategoryAxis: sourceGroupCategoryAxis,
        destinationGroupCategoryAxis: widget.destinationGroupCategoryAxis,
      );
      if (mounted) {
        Navigator.pop(context, sourceGroupCategoryAxis.name);
      }
    } catch (error, stackTrace) {
      if (mounted) {
        setState(() {
          _importingGroupCategoryAxisID = null;
        });
        showErrorSnackBar(context, error, stackTrace);
      }
    }
  }
}
