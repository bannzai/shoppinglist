import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/entity/group_user_profile.dart';
import 'package:shoppinglist/features/group_category/import_action.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/group_category.dart';
import 'package:shoppinglist/provider/group_user_profile.dart';
import 'package:shoppinglist/style/theme.dart';
import 'package:shoppinglist/style/tokens.dart';

import '../../helpers/localized_test_app.dart';

const _groupID = 'group-001';
const _currentUserID = 'user-current';
const _memberUserID = 'user-member';
const _destinationAxis = GroupCategoryAxis(
  id: 'axis-current',
  groupID: _groupID,
  userID: _currentUserID,
  name: '自分の売り場',
  order: 0,
);
const _memberAxis = GroupCategoryAxis(
  id: 'axis-member',
  groupID: _groupID,
  userID: _memberUserID,
  name: '共有の売り場',
  order: 0,
);

class _RecordingImport extends GroupCategoryImportFromMember {
  String? destinationUserID;
  GroupCategoryAxis? sourceGroupCategoryAxis;
  GroupCategoryAxis? destinationGroupCategoryAxis;
  final Completer<void>? completion;

  _RecordingImport({this.completion})
    : super(database: GroupDatabase(groupID: _groupID));

  @override
  Future<int> call({
    required String destinationUserID,
    required GroupCategoryAxis sourceGroupCategoryAxis,
    required GroupCategoryAxis? destinationGroupCategoryAxis,
  }) async {
    this.destinationUserID = destinationUserID;
    this.sourceGroupCategoryAxis = sourceGroupCategoryAxis;
    this.destinationGroupCategoryAxis = destinationGroupCategoryAxis;
    await completion?.future;
    return 2;
  }
}

Widget _app({
  required List<GroupCategoryAxis> axes,
  required _RecordingImport import,
}) => ProviderScope(
  overrides: [
    shareableGroupCategoryAxesProvider(
      groupID: _groupID,
    ).overrideWith((ref) => Stream.value(axes)),
    groupUserProfilesProvider(groupID: _groupID).overrideWith(
      (ref) => Stream.value(const [
        GroupUserProfile(
          id: 'profile-member',
          groupID: _groupID,
          userID: _memberUserID,
          displayName: '家族',
        ),
      ]),
    ),
    groupCategoryImportFromMemberProvider(
      groupID: _groupID,
    ).overrideWith((ref) => import),
  ],
  child: localizedTestApp(
    theme: buildAppTheme(accent: AccentPreset.shu),
    home: Scaffold(
      appBar: AppBar(
        actions: const [
          GroupCategoryImportAction(
            groupID: _groupID,
            currentUserID: _currentUserID,
            destinationGroupCategoryAxis: _destinationAxis,
          ),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('別メンバーのカテゴリ軸だけを表示し、自分の軸へ取り込む', (tester) async {
    final import = _RecordingImport();
    await tester.pumpWidget(
      _app(axes: const [_destinationAxis, _memberAxis], import: import),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('メンバーのカテゴリを取り込む'));
    await tester.pumpAndSettle();

    expect(find.text('カテゴリ設定を取り込む'), findsOneWidget);
    expect(find.text('共有の売り場'), findsOneWidget);
    expect(find.text('家族'), findsOneWidget);
    expect(find.text('自分の売り場'), findsNothing);

    await tester.tap(find.text('共有の売り場'));
    await tester.pumpAndSettle();

    expect(import.destinationUserID, _currentUserID);
    expect(import.sourceGroupCategoryAxis, _memberAxis);
    expect(import.destinationGroupCategoryAxis, _destinationAxis);
    expect(find.text('共有の売り場を取り込みました'), findsOneWidget);
  });

  testWidgets('別メンバーのカテゴリ軸が無い場合は空表示にする', (tester) async {
    await tester.pumpWidget(
      _app(axes: const [_destinationAxis], import: _RecordingImport()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('メンバーのカテゴリを取り込む'));
    await tester.pumpAndSettle();

    expect(find.text('取り込めるカテゴリ設定はありません'), findsOneWidget);
  });

  testWidgets('取り込み中はバリアとシステムの戻る操作で閉じない', (tester) async {
    final completion = Completer<void>();
    await tester.pumpWidget(
      _app(
        axes: const [_destinationAxis, _memberAxis],
        import: _RecordingImport(completion: completion),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('メンバーのカテゴリを取り込む'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('共有の売り場'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'キャンセル'))
          .onPressed,
      isNull,
    );
    await tester.tapAt(const Offset(1, 1));
    await tester.pump();
    expect(find.text('カテゴリ設定を取り込む'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('カテゴリ設定を取り込む'), findsOneWidget);

    completion.complete();
    await tester.pumpAndSettle();
    expect(find.text('カテゴリ設定を取り込む'), findsNothing);
  });
}
