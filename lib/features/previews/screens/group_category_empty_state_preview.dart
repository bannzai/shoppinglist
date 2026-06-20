import 'package:flutter/material.dart';
import 'package:shoppinglist/features/group_category/category_empty_state.dart';
import 'package:shoppinglist/style/tokens.dart';

/// カテゴリ画面の空状態（価値訴求カード）の見た目を確認するための preview。
///
/// 実画面（`GroupCategoryPage`）は mock データでカテゴリありの状態になり空状態が出ないため、
/// `CategoryEmptyState` を実画面と同じ chrome（paper 背景＋「カテゴリ」AppBar）で単体表示する。
class GroupCategoryEmptyStatePreview extends StatelessWidget {
  const GroupCategoryEmptyStatePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    return Scaffold(
      backgroundColor: tokens.neutral.paper,
      appBar: AppBar(
        title: const Text('カテゴリ'),
        backgroundColor: tokens.neutral.paper,
      ),
      body: CategoryEmptyState(onAddCategory: () {}),
    );
  }
}
