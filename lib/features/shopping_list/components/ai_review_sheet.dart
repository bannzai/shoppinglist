import 'package:flutter/material.dart';
import 'package:shoppinglist/components/primitives/app_pill.dart';
import 'package:shoppinglist/style/tokens.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// AI で抽出したアイテム候補。
/// `design_handoff_shoppinglist/preview/widgets-and-micro.jsx#MicroAIProgress` の
/// 「NEW バッジ候補リスト」相当。レビュー画面で選択を切り替えて add する。
class AIShoppingListCandidate {
  /// 抽出されたアイテム名。レビュー画面の TextField で編集できる。
  final String name;

  /// レビュー画面でユーザーが選択しているか。
  final bool selected;

  const AIShoppingListCandidate({required this.name, required this.selected});

  AIShoppingListCandidate copyWith({String? name, bool? selected}) =>
      AIShoppingListCandidate(
        name: name ?? this.name,
        selected: selected ?? this.selected,
      );
}

/// AI で抽出した候補を「追加前にレビュー」する Bottom Sheet を表示する。
/// `design_handoff_shoppinglist/preview/screens-list.jsx` の AI Processing 状態 →
/// 確定までの間をつなぐ。
///
/// 戻り値:
/// - `null`: キャンセル (ユーザーが背景タップや閉じるを押した)
/// - 空 List: 「全件除外して閉じる」
/// - 1 件以上の List: 選択中のアイテム
Future<List<AIShoppingListCandidate>?> showAIReviewSheet({
  required BuildContext context,
  required List<String> rawNames,
  required String source,
}) {
  analytics.logEvent(
    name: 'open_ai_review_sheet',
    parameters: {'source': source, 'rawCount': rawNames.length.toString()},
  );
  return showModalBottomSheet<List<AIShoppingListCandidate>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appTheme.neutral.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder:
        (sheetContext) => _AIReviewSheet(rawNames: rawNames, source: source),
  );
}

class _AIReviewSheet extends StatefulWidget {
  final List<String> rawNames;
  final String source;
  const _AIReviewSheet({required this.rawNames, required this.source});

  @override
  State<_AIReviewSheet> createState() => _AIReviewSheetState();
}

class _AIReviewSheetState extends State<_AIReviewSheet> {
  late List<AIShoppingListCandidate> _candidates;

  /// 各候補のアイテム名を編集するための TextEditingController。
  /// `_candidates` と同じ index で対応する。
  late List<TextEditingController> _nameControllers;

  @override
  void initState() {
    super.initState();
    final distinct =
        widget.rawNames
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty && e.length <= 100)
            .toSet()
            .toList();
    _candidates =
        distinct
            .map((name) => AIShoppingListCandidate(name: name, selected: true))
            .toList();
    _nameControllers =
        _candidates.map((c) => TextEditingController(text: c.name)).toList();
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggle(int index) {
    analytics.logEvent(
      name: 'toggle_ai_review_candidate',
      parameters: {'source': widget.source, 'index': index.toString()},
    );
    setState(() {
      _candidates[index] = _candidates[index].copyWith(
        selected: !_candidates[index].selected,
      );
    });
  }

  void _confirm() {
    // TextField で編集された名前を反映し、空になった候補は除外して返す。
    final reviewed =
        [
          for (final (index, c) in _candidates.indexed)
            c.copyWith(name: _nameControllers[index].text.trim()),
        ].where((c) => c.name.isNotEmpty).toList();
    analytics.logEvent(
      name: 'confirm_ai_review_sheet',
      parameters: {
        'source': widget.source,
        'selectedCount': reviewed.where((c) => c.selected).length.toString(),
      },
    );
    Navigator.pop<List<AIShoppingListCandidate>>(context, reviewed);
  }

  void _cancel() {
    analytics.logEvent(
      name: 'cancel_ai_review_sheet',
      parameters: {'source': widget.source},
    );
    Navigator.pop<List<AIShoppingListCandidate>?>(context, null);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final neutral = tokens.neutral;
    final selectedCount = _candidates.where((c) => c.selected).length;
    return Padding(
      // キーボード表示中はシート全体をキーボードの上に退避させる。これが無いと
      // 候補名の TextField 編集時に下部の候補行とフッターのボタンがキーボードに
      // 隠れて操作できない (Issue #487)。
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.92,
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
                            '読み取った候補',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: neutral.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '追加するアイテムを選んでください',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: neutral.ink3),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.accentSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$selectedCount / ${_candidates.length}',
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
                child:
                    _candidates.isEmpty
                        ? Center(
                          child: Text(
                            '候補がありませんでした',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: neutral.ink3),
                          ),
                        )
                        : ListView.separated(
                          controller: scrollController,
                          itemCount: _candidates.length,
                          separatorBuilder:
                              (_, __) => Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: neutral.divider2,
                              ),
                          itemBuilder: (_, index) {
                            final c = _candidates[index];
                            return CheckboxListTile(
                              value: c.selected,
                              onChanged: (_) => _toggle(index),
                              title: TextField(
                                controller: _nameControllers[index],
                                maxLines: 1,
                                textInputAction: TextInputAction.done,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: neutral.ink),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isCollapsed: true,
                                ),
                                cursorColor: tokens.accent,
                                onSubmitted: (_) {
                                  analytics.logEvent(
                                    name: 'edit_ai_review_candidate',
                                    parameters: {
                                      'source': widget.source,
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                              activeColor: tokens.accent,
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
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
                          label: '$selectedCount 件追加',
                          variant: AppPillVariant.accent,
                          large: true,
                          expanded: true,
                          onPressed: selectedCount == 0 ? null : _confirm,
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
      ),
    );
  }
}
