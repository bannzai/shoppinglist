import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinglist/entity/group_category.dart';
import 'package:shoppinglist/entity/group_category_axis.dart';
import 'package:shoppinglist/provider/group_category.dart';

void main() {
  group('カテゴリ設定取り込みの決定的ID', () {
    test('同じ元ユーザー・元軸・元カテゴリなら常に同じカテゴリIDを返す', () {
      final first = importedGroupCategoryDocumentID(
        sourceUserID: 'source-user',
        sourceGroupCategoryAxisID: 'source-axis',
        sourceGroupCategoryID: 'source-category',
      );
      final second = importedGroupCategoryDocumentID(
        sourceUserID: 'source-user',
        sourceGroupCategoryAxisID: 'source-axis',
        sourceGroupCategoryID: 'source-category',
      );

      expect(second, first);
      expect(
        first,
        startsWith(
          importedGroupCategoryDocumentIDPrefix(
            sourceUserID: 'source-user',
            sourceGroupCategoryAxisID: 'source-axis',
          ),
        ),
      );
    });

    test('元カテゴリまたは元軸が異なると別のカテゴリIDを返す', () {
      final base = importedGroupCategoryDocumentID(
        sourceUserID: 'source-user',
        sourceGroupCategoryAxisID: 'source-axis',
        sourceGroupCategoryID: 'source-category',
      );

      expect(
        importedGroupCategoryDocumentID(
          sourceUserID: 'source-user',
          sourceGroupCategoryAxisID: 'source-axis',
          sourceGroupCategoryID: 'another-category',
        ),
        isNot(base),
      );
      expect(
        importedGroupCategoryDocumentID(
          sourceUserID: 'source-user',
          sourceGroupCategoryAxisID: 'another-axis',
          sourceGroupCategoryID: 'source-category',
        ),
        isNot(base),
      );
    });

    test('取込先に軸が無い場合の軸IDは取込先ユーザーを含めて決定する', () {
      final first = importedGroupCategoryAxisDocumentID(
        destinationUserID: 'destination-user',
        sourceUserID: 'source-user',
        sourceGroupCategoryAxisID: 'source-axis',
      );
      final second = importedGroupCategoryAxisDocumentID(
        destinationUserID: 'another-destination-user',
        sourceUserID: 'source-user',
        sourceGroupCategoryAxisID: 'source-axis',
      );

      expect(first, startsWith('imported_'));
      expect(second, isNot(first));
    });
  });

  test('現在のグループメンバーが所有するカテゴリ軸だけを共有候補にする', () {
    final currentMemberAxis = GroupCategoryAxis(
      id: 'current-member-axis',
      groupID: 'group-001',
      userID: 'current-member',
      name: '現在のメンバー',
      order: 0,
    );
    final removedMemberAxis = GroupCategoryAxis(
      id: 'removed-member-axis',
      groupID: 'group-001',
      userID: 'removed-member',
      name: '削除済みメンバー',
      order: 1,
    );

    expect(
      filterShareableGroupCategoryAxes(
        groupCategoryAxes: [currentMemberAxis, removedMemberAxis],
        memberUserIDs: const ['current-member'],
      ),
      [currentMemberAxis],
    );
  });

  test('取り込んだカテゴリを自作カテゴリの後ろへ配置し、再取り込みでも順序を変えない', () {
    const sourceAxis = GroupCategoryAxis(
      id: 'source-axis',
      groupID: 'group',
      userID: 'source-user',
      name: '売り場',
      order: 0,
    );
    const sourceCategories = [
      GroupCategory(
        id: 'source-category-1',
        groupID: 'group',
        userID: 'source-user',
        groupCategoryAxisID: 'source-axis',
        name: '野菜',
        order: 0,
        locationOrders: {'store': 1},
        keywords: [],
        color: null,
        iconName: null,
      ),
      GroupCategory(
        id: 'source-category-2',
        groupID: 'group',
        userID: 'source-user',
        groupCategoryAxisID: 'source-axis',
        name: '肉',
        order: 1,
        locationOrders: {'store': 0},
        keywords: [],
        color: null,
        iconName: null,
      ),
    ];
    const localCategory = GroupCategory(
      id: 'local-category',
      groupID: 'group',
      userID: 'destination-user',
      groupCategoryAxisID: 'destination-axis',
      name: '自作',
      order: 2,
      locationOrders: {'store': 4},
      keywords: [],
      color: null,
      iconName: null,
    );
    final updatedDateTime = DateTime(2026, 9);

    final firstImport = buildImportedGroupCategories(
      groupID: 'group',
      destinationUserID: 'destination-user',
      destinationGroupCategoryAxisID: 'destination-axis',
      sourceGroupCategoryAxis: sourceAxis,
      sourceCategories: sourceCategories,
      destinationCategories: const [localCategory],
      updatedDateTime: updatedDateTime,
    );
    final anotherImportedCategory = GroupCategory(
      id: importedGroupCategoryDocumentID(
        sourceUserID: 'another-source-user',
        sourceGroupCategoryAxisID: 'another-source-axis',
        sourceGroupCategoryID: 'another-source-category',
      ),
      groupID: 'group',
      userID: 'destination-user',
      groupCategoryAxisID: 'destination-axis',
      name: '別メンバーから取り込み済み',
      order: 5,
      locationOrders: const {'store': 8},
      keywords: const [],
      color: null,
      iconName: null,
    );
    final secondImport = buildImportedGroupCategories(
      groupID: 'group',
      destinationUserID: 'destination-user',
      destinationGroupCategoryAxisID: 'destination-axis',
      sourceGroupCategoryAxis: sourceAxis,
      sourceCategories: sourceCategories,
      destinationCategories: [
        localCategory,
        ...firstImport,
        anotherImportedCategory,
      ],
      updatedDateTime: updatedDateTime,
    );

    expect(firstImport.map((category) => category.order), [3, 4]);
    expect(firstImport.map((category) => category.locationOrders['store']), [
      6,
      5,
    ]);
    expect(
      firstImport.map((category) => category.userID),
      everyElement('destination-user'),
    );
    expect(
      firstImport.map((category) => category.groupCategoryAxisID),
      everyElement('destination-axis'),
    );
    expect(secondImport.map((category) => category.id), [
      for (final category in firstImport) category.id,
    ]);
    expect(secondImport.map((category) => category.order), [3, 4]);
    expect(secondImport.map((category) => category.locationOrders['store']), [
      6,
      5,
    ]);
  });
}
