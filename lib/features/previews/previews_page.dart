import 'package:flutter/material.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/features/auth/page.dart';
import 'package:shoppinglist/features/group_create/page.dart';
import 'package:shoppinglist/features/group_invitation/page.dart';
import 'package:shoppinglist/features/group_list/page.dart';
import 'package:shoppinglist/features/group_setting/page.dart';
import 'package:shoppinglist/features/group_category_edit/page.dart';
import 'package:shoppinglist/features/group_category/page.dart';
import 'package:shoppinglist/features/home/page.dart';
import 'package:shoppinglist/features/inquiry/page.dart';
import 'package:shoppinglist/features/onboarding/page.dart';
import 'package:shoppinglist/features/previews/mock/mock_data.dart';
import 'package:shoppinglist/features/previews/screens/ai_categorize_preview_sheet_preview.dart';
import 'package:shoppinglist/features/previews/screens/ai_review_sheet_preview.dart';
import 'package:shoppinglist/features/previews/screens/group_category_empty_state_preview.dart';
import 'package:shoppinglist/features/previews/screens/invitation_verifying_preview.dart';
import 'package:shoppinglist/features/previews/screens/shopping_list_preview.dart';
import 'package:shoppinglist/features/previews/screens/shopping_list_setting_preview.dart';
import 'package:shoppinglist/features/previews/screens/sign_out_dialog_preview.dart';
import 'package:shoppinglist/features/settings/page.dart';
import 'package:shoppinglist/features/shopping_location/page.dart';

class _PreviewEntry {
  final String title;
  final Widget Function(BuildContext context) builder;

  const _PreviewEntry({required this.title, required this.builder});
}

final _previewEntries = <_PreviewEntry>[
  _PreviewEntry(
    title: 'LaunchLoading',
    builder: (_) => const LaunchLoading(),
  ),
  _PreviewEntry(
    title: 'OnboardingPage',
    builder: (_) => const OnboardingPage(),
  ),
  _PreviewEntry(
    title: 'AuthPage',
    builder: (_) => const AuthPage(),
  ),
  _PreviewEntry(
    title: 'HomePage',
    builder: (_) => const HomePage(),
  ),
  _PreviewEntry(
    title: 'ShoppingListPage',
    builder: (_) => const ShoppingListPreview(),
  ),
  _PreviewEntry(
    title: 'SettingPage',
    builder: (_) => const SettingPage(),
  ),
  _PreviewEntry(
    title: 'InquiryPage',
    builder: (_) => const InquiryPage(),
  ),
  _PreviewEntry(
    title: 'GroupListPage',
    builder: (_) => const GroupListPage(),
  ),
  _PreviewEntry(
    title: 'GroupCategoryEmptyState',
    builder: (_) => const GroupCategoryEmptyStatePreview(),
  ),
  _PreviewEntry(
    title: 'GroupCreatePage',
    builder: (_) => const GroupCreatePage(),
  ),
  _PreviewEntry(
    title: 'GroupSettingPage',
    builder: (_) => GroupSettingPage(groupID: mockGroupID),
  ),
  _PreviewEntry(
    title: 'GroupInvitationAcceptPage',
    builder: (_) => const GroupInvitationAcceptPage(),
  ),
  _PreviewEntry(
    title: 'ShoppingLocationPage',
    builder: (_) => ShoppingLocationPage(groupID: mockGroupID),
  ),
  _PreviewEntry(
    title: 'GroupCategoryPage',
    builder: (_) => GroupCategoryPage(groupID: mockGroupID),
  ),
  _PreviewEntry(
    title: 'GroupCategoryEditPage',
    builder: (_) => GroupCategoryEditPage(
      groupID: mockGroupID,
      categoryAxisID: mockCategoryAxisID,
      categoryID: mockCategoryID,
    ),
  ),
  _PreviewEntry(
    title: 'ShoppingListSettingPage',
    builder: (_) => const ShoppingListSettingPreview(),
  ),
  _PreviewEntry(
    title: 'AIReviewSheet',
    builder: (_) => const AIReviewSheetPreview(),
  ),
  _PreviewEntry(
    title: 'AICategorizeSheet',
    builder: (_) => const AICategorizePreviewSheetPreview(),
  ),
  _PreviewEntry(
    title: 'SignOutDialog',
    builder: (_) => const SignOutDialogPreview(),
  ),
  _PreviewEntry(
    title: 'GroupInvitationVerifying',
    builder: (_) => const GroupInvitationVerifyingPreview(),
  ),
];

class PreviewsPage extends StatelessWidget {
  const PreviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previews')),
      body: ListView.separated(
        itemCount: _previewEntries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = _previewEntries[index];
          return ListTile(
            title: Text(entry.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: entry.builder,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
