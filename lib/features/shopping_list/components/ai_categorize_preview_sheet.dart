import 'package:flutter/material.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// AIカテゴリ分けの確認・調整シートで扱う1アイテムの候補。
class AICategorizeCandidate {
  /// アイテム名（買い物リストの message）。
  final String itemName;

  /// 割り当てるカテゴリ名。シート上でユーザーが変更できる。
  final String categoryName;

  /// 登録対象に含めるか。
  final bool included;

  const AICategorizeCandidate({
    required this.itemName,
    required this.categoryName,
    required this.included,
  });

  AICategorizeCandidate copyWith({String? categoryName, bool? included}) =>
      AICategorizeCandidate(
        itemName: itemName,
        categoryName: categoryName ?? this.categoryName,
        included: included ?? this.included,
      );
}

/// AIカテゴリ分け結果を確認・調整する Bottom Sheet を表示する。
///
/// カテゴリごとに候補をまとめて表示し、各候補のカテゴリ変更・除外ができる。
///
/// 戻り値:
/// - `null`: キャンセル（背景タップや「キャンセル」）
/// - 1件以上の List: 登録する候補（調整後・included のみ）
Future<List<AICategorizeCandidate>?> showAICategorizePreviewSheet({
  required BuildContext context,
  required List<({String name, String categoryName})> categorized,
  required List<String> existingCategoryNames,
}) {
  analytics.logEvent(
    name: 'open_ai_categorize_sheet',
    parameters: {'itemCount': categorized.length.toString()},
  );
  return showModalBottomSheet<List<AICategorizeCandidate>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.tokens.neutral.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (_) => _AICategorizePreviewSheet(
      categorized: categorized,
      existingCategoryNames: existingCategoryNames,
    ),
  );
}

class _AICategorizePreviewSheet extends StatefulWidget {
  final List<({String name, String categoryName})> categorized;
  final List<String> existingCategoryNames;

  const _AICategorizePreviewSheet({
    required this.categorized,
    required this.existingCategoryNames,
  });

  @override
  State<_AICategorizePreviewSheet> createState() =>
      _AICategorizePreviewSheetState();
}

class _AICategorizePreviewSheetState extends State<_AICategorizePreviewSheet> {
  late List<AICategorizeCandidate> _candidates;

  @override
  void initState() {
    super.initState();
    _candidates = widget.categorized
        .map((e) => AICategorizeCandidate(
              itemName: e.name,
              categoryName: e.categoryName,
              included: true,
            ))
        .toList();
  }

  /// 選択肢として提示するカテゴリ名（既存 ∪ AI提案）。表示順は安定させる。
  List<String> get _categoryNameOptions {
    final names = <String>[];
    for (final name in [
      ...widget.existingCategoryNames,
      ...widget.categorized.map((e) => e.categoryName),
    ]) {
      if (!names.contains(name)) {
        names.add(name);
      }
    }
    return names;
  }

  void _toggle(int index) {
    analytics.logEvent(
      name: 'toggle_ai_categorize_candidate',
      parameters: {'index': index.toString()},
    );
    setState(() {
      _candidates[index] =
          _candidates[index].copyWith(included: !_candidates[index].included);
    });
  }

  void _changeCategory(int index, String categoryName) {
    analytics.logEvent(
      name: 'change_ai_categorize_category',
      parameters: {'index': index.toString()},
    );
    setState(() {
      _candidates[index] =
          _candidates[index].copyWith(categoryName: categoryName);
    });
  }

  Future<void> _pickCategory(int index) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.tokens.neutral.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => _CategoryPickerSheet(
        options: _categoryNameOptions,
        current: _candidates[index].categoryName,
      ),
    );
    if (selected != null && selected.isNotEmpty) {
      _changeCategory(index, selected);
    }
  }

  void _confirm() {
    analytics.logEvent(
      name: 'confirm_ai_categorize_sheet',
      parameters: {
        'includedCount':
            _candidates.where((c) => c.included).length.toString(),
      },
    );
    Navigator.pop<List<AICategorizeCandidate>>(context, _candidates);
  }

  void _cancel() {
    analytics.logEvent(name: 'cancel_ai_categorize_sheet', parameters: {});
    Navigator.pop<List<AICategorizeCandidate>?>(context, null);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    final includedCount = _candidates.where((c) => c.included).length;

    // カテゴリ名ごとに候補をまとめる。表示順は _categoryNameOptions に従う。
    final indicesByCategory = <String, List<int>>{};
    for (final (index, candidate) in _candidates.indexed) {
      indicesByCategory.putIfAbsent(candidate.categoryName, () => []).add(index);
    }
    final orderedCategoryNames = [
      ..._categoryNameOptions.where(indicesByCategory.containsKey),
      ...indicesByCategory.keys
          .where((name) => !_categoryNameOptions.contains(name)),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetContext, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: neutral.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI のカテゴリ分け',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: neutral.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'カテゴリを確認・調整して登録してください',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: neutral.ink3,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tokens.accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$includedCount / ${_candidates.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.accent,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 0.5, thickness: 0.5, color: neutral.divider),
            Expanded(
              child: _candidates.isEmpty
                  ? Center(
                      child: Text(
                        '分類できる候補がありませんでした',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: neutral.ink3),
                      ),
                    )
                  : ListView(
                      controller: scrollController,
                      children: [
                        for (final categoryName in orderedCategoryNames) ...[
                          _CategoryHeader(name: categoryName),
                          for (final index in indicesByCategory[categoryName]!)
                            _CandidateRow(
                              candidate: _candidates[index],
                              onToggle: () => _toggle(index),
                              onTapCategory: () => _pickCategory(index),
                            ),
                        ],
                      ],
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: AppPill(
                        label: 'キャンセル',
                        variant: AppPillVariant.ghost,
                        expanded: true,
                        onPressed: _cancel,
                        icon: null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppPill(
                        label: '$includedCount 件を登録',
                        variant: AppPillVariant.accent,
                        large: true,
                        expanded: true,
                        onPressed: includedCount == 0 ? null : _confirm,
                        icon: null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// カテゴリ名のセクションヘッダー。
class _CategoryHeader extends StatelessWidget {
  final String name;

  const _CategoryHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        name,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: tokens.accent,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// 1アイテムの行。チェックボックス + アイテム名 + カテゴリ変更チップ。
class _CandidateRow extends StatelessWidget {
  final AICategorizeCandidate candidate;
  final VoidCallback onToggle;
  final VoidCallback onTapCategory;

  const _CandidateRow({
    required this.candidate,
    required this.onToggle,
    required this.onTapCategory,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Checkbox(
            value: candidate.included,
            onChanged: (_) => onToggle(),
            activeColor: tokens.accent,
          ),
          Expanded(
            child: Text(
              candidate.itemName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: candidate.included ? neutral.ink : neutral.ink3,
                    decoration: candidate.included
                        ? null
                        : TextDecoration.lineThrough,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTapCategory,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: neutral.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: neutral.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    candidate.categoryName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: neutral.ink2,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more, size: 16, color: neutral.ink3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// カテゴリ選択シート。既存 ∪ AI提案 のカテゴリ名一覧 + 新規入力。
class _CategoryPickerSheet extends StatefulWidget {
  final List<String> options;
  final String current;

  const _CategoryPickerSheet({required this.options, required this.current});

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  final _newCategoryController = TextEditingController();

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final neutral = tokens.neutral;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: neutral.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'カテゴリを選択',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: neutral.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final option in widget.options)
                    ListTile(
                      title: Text(option),
                      trailing: option == widget.current
                          ? Icon(Icons.check, color: tokens.accent)
                          : null,
                      onTap: () => Navigator.pop<String>(context, option),
                    ),
                ],
              ),
            ),
            Divider(height: 0.5, thickness: 0.5, color: neutral.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newCategoryController,
                      decoration: const InputDecoration(
                        hintText: '新しいカテゴリ名',
                        isDense: true,
                      ),
                      onSubmitted: (value) {
                        final name = value.trim();
                        if (name.isNotEmpty) {
                          Navigator.pop<String>(context, name);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppPill(
                    label: '追加',
                    variant: AppPillVariant.accent,
                    onPressed: () {
                      final name = _newCategoryController.text.trim();
                      if (name.isNotEmpty) {
                        Navigator.pop<String>(context, name);
                      }
                    },
                    icon: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
