// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_category.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupCategoryAxes)
final groupCategoryAxesProvider = GroupCategoryAxesFamily._();

final class GroupCategoryAxesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupCategoryAxis>>,
          List<GroupCategoryAxis>,
          Stream<List<GroupCategoryAxis>>
        >
    with
        $FutureModifier<List<GroupCategoryAxis>>,
        $StreamProvider<List<GroupCategoryAxis>> {
  GroupCategoryAxesProvider._({
    required GroupCategoryAxesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupCategoryAxesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;
  static final $allTransitiveDependencies1 = currentUserIDProvider;
  static final $allTransitiveDependencies2 =
      CurrentUserIDProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$groupCategoryAxesHash();

  @override
  String toString() {
    return r'groupCategoryAxesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupCategoryAxis>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupCategoryAxis>> create(Ref ref) {
    final argument = this.argument as String;
    return groupCategoryAxes(ref, groupID: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryAxesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupCategoryAxesHash() => r'c6d00a94280e72e264ff31760d0b33e9aa884990';

final class GroupCategoryAxesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<GroupCategoryAxis>>, String> {
  GroupCategoryAxesFamily._()
    : super(
        retry: null,
        name: r'groupCategoryAxesProvider',
        dependencies: <ProviderOrFamily>[
          groupDatabaseProvider,
          currentUserIDProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupCategoryAxesProvider.$allTransitiveDependencies0,
          GroupCategoryAxesProvider.$allTransitiveDependencies1,
          GroupCategoryAxesProvider.$allTransitiveDependencies2,
        ],
        isAutoDispose: true,
      );

  GroupCategoryAxesProvider call({required String groupID}) =>
      GroupCategoryAxesProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupCategoryAxesProvider';
}

@ProviderFor(shareableGroupCategoryAxes)
final shareableGroupCategoryAxesProvider = ShareableGroupCategoryAxesFamily._();

final class ShareableGroupCategoryAxesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupCategoryAxis>>,
          List<GroupCategoryAxis>,
          Stream<List<GroupCategoryAxis>>
        >
    with
        $FutureModifier<List<GroupCategoryAxis>>,
        $StreamProvider<List<GroupCategoryAxis>> {
  ShareableGroupCategoryAxesProvider._({
    required ShareableGroupCategoryAxesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shareableGroupCategoryAxesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;
  static final $allTransitiveDependencies1 = groupProvider;

  @override
  String debugGetCreateSourceHash() => _$shareableGroupCategoryAxesHash();

  @override
  String toString() {
    return r'shareableGroupCategoryAxesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupCategoryAxis>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupCategoryAxis>> create(Ref ref) {
    final argument = this.argument as String;
    return shareableGroupCategoryAxes(ref, groupID: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ShareableGroupCategoryAxesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shareableGroupCategoryAxesHash() =>
    r'a63e833a778ecfc12da501a03470123ab5aa9df7';

final class ShareableGroupCategoryAxesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<GroupCategoryAxis>>, String> {
  ShareableGroupCategoryAxesFamily._()
    : super(
        retry: null,
        name: r'shareableGroupCategoryAxesProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider, groupProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          ShareableGroupCategoryAxesProvider.$allTransitiveDependencies0,
          ShareableGroupCategoryAxesProvider.$allTransitiveDependencies1,
        ],
        isAutoDispose: true,
      );

  ShareableGroupCategoryAxesProvider call({required String groupID}) =>
      ShareableGroupCategoryAxesProvider._(argument: groupID, from: this);

  @override
  String toString() => r'shareableGroupCategoryAxesProvider';
}

@ProviderFor(groupCategoryAxisAdd)
final groupCategoryAxisAddProvider = GroupCategoryAxisAddFamily._();

final class GroupCategoryAxisAddProvider
    extends
        $FunctionalProvider<
          GroupCategoryAxisAdd,
          GroupCategoryAxisAdd,
          GroupCategoryAxisAdd
        >
    with $Provider<GroupCategoryAxisAdd> {
  GroupCategoryAxisAddProvider._({
    required GroupCategoryAxisAddFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupCategoryAxisAddProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$groupCategoryAxisAddHash();

  @override
  String toString() {
    return r'groupCategoryAxisAddProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GroupCategoryAxisAdd> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupCategoryAxisAdd create(Ref ref) {
    final argument = this.argument as String;
    return groupCategoryAxisAdd(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupCategoryAxisAdd value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupCategoryAxisAdd>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryAxisAddProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupCategoryAxisAddHash() =>
    r'42254d5778dd8761fb182c8890a73ba38eaec7dc';

final class GroupCategoryAxisAddFamily extends $Family
    with $FunctionalFamilyOverride<GroupCategoryAxisAdd, String> {
  GroupCategoryAxisAddFamily._()
    : super(
        retry: null,
        name: r'groupCategoryAxisAddProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupCategoryAxisAddProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  GroupCategoryAxisAddProvider call({required String groupID}) =>
      GroupCategoryAxisAddProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupCategoryAxisAddProvider';
}

@ProviderFor(groupCategoryAxisDelete)
final groupCategoryAxisDeleteProvider = GroupCategoryAxisDeleteFamily._();

final class GroupCategoryAxisDeleteProvider
    extends
        $FunctionalProvider<
          GroupCategoryAxisDelete,
          GroupCategoryAxisDelete,
          GroupCategoryAxisDelete
        >
    with $Provider<GroupCategoryAxisDelete> {
  GroupCategoryAxisDeleteProvider._({
    required GroupCategoryAxisDeleteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupCategoryAxisDeleteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$groupCategoryAxisDeleteHash();

  @override
  String toString() {
    return r'groupCategoryAxisDeleteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GroupCategoryAxisDelete> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupCategoryAxisDelete create(Ref ref) {
    final argument = this.argument as String;
    return groupCategoryAxisDelete(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupCategoryAxisDelete value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupCategoryAxisDelete>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryAxisDeleteProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupCategoryAxisDeleteHash() =>
    r'c0b68bb509392b5f1eaafe6b537e7e6091877003';

final class GroupCategoryAxisDeleteFamily extends $Family
    with $FunctionalFamilyOverride<GroupCategoryAxisDelete, String> {
  GroupCategoryAxisDeleteFamily._()
    : super(
        retry: null,
        name: r'groupCategoryAxisDeleteProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupCategoryAxisDeleteProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  GroupCategoryAxisDeleteProvider call({required String groupID}) =>
      GroupCategoryAxisDeleteProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupCategoryAxisDeleteProvider';
}

@ProviderFor(groupCategories)
final groupCategoriesProvider = GroupCategoriesFamily._();

final class GroupCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupCategory>>,
          List<GroupCategory>,
          Stream<List<GroupCategory>>
        >
    with
        $FutureModifier<List<GroupCategory>>,
        $StreamProvider<List<GroupCategory>> {
  GroupCategoriesProvider._({
    required GroupCategoriesFamily super.from,
    required ({String groupID, String categoryAxisID}) super.argument,
  }) : super(
         retry: null,
         name: r'groupCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;
  static final $allTransitiveDependencies1 = currentUserIDProvider;
  static final $allTransitiveDependencies2 =
      CurrentUserIDProvider.$allTransitiveDependencies0;

  @override
  String debugGetCreateSourceHash() => _$groupCategoriesHash();

  @override
  String toString() {
    return r'groupCategoriesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupCategory>> create(Ref ref) {
    final argument = this.argument as ({String groupID, String categoryAxisID});
    return groupCategories(
      ref,
      groupID: argument.groupID,
      categoryAxisID: argument.categoryAxisID,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupCategoriesHash() => r'7eba7948c221f65f731060d009b5754bf0e0a649';

final class GroupCategoriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<GroupCategory>>,
          ({String groupID, String categoryAxisID})
        > {
  GroupCategoriesFamily._()
    : super(
        retry: null,
        name: r'groupCategoriesProvider',
        dependencies: <ProviderOrFamily>[
          groupDatabaseProvider,
          currentUserIDProvider,
        ],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupCategoriesProvider.$allTransitiveDependencies0,
          GroupCategoriesProvider.$allTransitiveDependencies1,
          GroupCategoriesProvider.$allTransitiveDependencies2,
        ],
        isAutoDispose: true,
      );

  GroupCategoriesProvider call({
    required String groupID,
    required String categoryAxisID,
  }) => GroupCategoriesProvider._(
    argument: (groupID: groupID, categoryAxisID: categoryAxisID),
    from: this,
  );

  @override
  String toString() => r'groupCategoriesProvider';
}

@ProviderFor(groupCategoryAdd)
final groupCategoryAddProvider = GroupCategoryAddFamily._();

final class GroupCategoryAddProvider
    extends
        $FunctionalProvider<
          GroupCategoryAdd,
          GroupCategoryAdd,
          GroupCategoryAdd
        >
    with $Provider<GroupCategoryAdd> {
  GroupCategoryAddProvider._({
    required GroupCategoryAddFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupCategoryAddProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$groupCategoryAddHash();

  @override
  String toString() {
    return r'groupCategoryAddProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GroupCategoryAdd> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupCategoryAdd create(Ref ref) {
    final argument = this.argument as String;
    return groupCategoryAdd(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupCategoryAdd value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupCategoryAdd>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryAddProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupCategoryAddHash() => r'7b6ae53a4483afe2d9f1c167d366a6ac6e87bfdc';

final class GroupCategoryAddFamily extends $Family
    with $FunctionalFamilyOverride<GroupCategoryAdd, String> {
  GroupCategoryAddFamily._()
    : super(
        retry: null,
        name: r'groupCategoryAddProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupCategoryAddProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  GroupCategoryAddProvider call({required String groupID}) =>
      GroupCategoryAddProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupCategoryAddProvider';
}

@ProviderFor(groupCategoryUpdate)
final groupCategoryUpdateProvider = GroupCategoryUpdateFamily._();

final class GroupCategoryUpdateProvider
    extends
        $FunctionalProvider<
          GroupCategoryUpdate,
          GroupCategoryUpdate,
          GroupCategoryUpdate
        >
    with $Provider<GroupCategoryUpdate> {
  GroupCategoryUpdateProvider._({
    required GroupCategoryUpdateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupCategoryUpdateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$groupCategoryUpdateHash();

  @override
  String toString() {
    return r'groupCategoryUpdateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GroupCategoryUpdate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupCategoryUpdate create(Ref ref) {
    final argument = this.argument as String;
    return groupCategoryUpdate(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupCategoryUpdate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupCategoryUpdate>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryUpdateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupCategoryUpdateHash() =>
    r'f29ef09ff481015f44999f6847d63c6686fd60f1';

final class GroupCategoryUpdateFamily extends $Family
    with $FunctionalFamilyOverride<GroupCategoryUpdate, String> {
  GroupCategoryUpdateFamily._()
    : super(
        retry: null,
        name: r'groupCategoryUpdateProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupCategoryUpdateProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  GroupCategoryUpdateProvider call({required String groupID}) =>
      GroupCategoryUpdateProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupCategoryUpdateProvider';
}

@ProviderFor(groupCategoryDelete)
final groupCategoryDeleteProvider = GroupCategoryDeleteFamily._();

final class GroupCategoryDeleteProvider
    extends
        $FunctionalProvider<
          GroupCategoryDelete,
          GroupCategoryDelete,
          GroupCategoryDelete
        >
    with $Provider<GroupCategoryDelete> {
  GroupCategoryDeleteProvider._({
    required GroupCategoryDeleteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupCategoryDeleteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$groupCategoryDeleteHash();

  @override
  String toString() {
    return r'groupCategoryDeleteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GroupCategoryDelete> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupCategoryDelete create(Ref ref) {
    final argument = this.argument as String;
    return groupCategoryDelete(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupCategoryDelete value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupCategoryDelete>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryDeleteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupCategoryDeleteHash() =>
    r'cdb3eb76537d83d87349546fe68d5f38b8b476d3';

final class GroupCategoryDeleteFamily extends $Family
    with $FunctionalFamilyOverride<GroupCategoryDelete, String> {
  GroupCategoryDeleteFamily._()
    : super(
        retry: null,
        name: r'groupCategoryDeleteProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupCategoryDeleteProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  GroupCategoryDeleteProvider call({required String groupID}) =>
      GroupCategoryDeleteProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupCategoryDeleteProvider';
}

@ProviderFor(groupCategoryBatchUpdate)
final groupCategoryBatchUpdateProvider = GroupCategoryBatchUpdateFamily._();

final class GroupCategoryBatchUpdateProvider
    extends
        $FunctionalProvider<
          GroupCategoryBatchUpdate,
          GroupCategoryBatchUpdate,
          GroupCategoryBatchUpdate
        >
    with $Provider<GroupCategoryBatchUpdate> {
  GroupCategoryBatchUpdateProvider._({
    required GroupCategoryBatchUpdateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupCategoryBatchUpdateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$groupCategoryBatchUpdateHash();

  @override
  String toString() {
    return r'groupCategoryBatchUpdateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GroupCategoryBatchUpdate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupCategoryBatchUpdate create(Ref ref) {
    final argument = this.argument as String;
    return groupCategoryBatchUpdate(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupCategoryBatchUpdate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupCategoryBatchUpdate>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryBatchUpdateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupCategoryBatchUpdateHash() =>
    r'a70103975b726e18559c9af0b31883446a72053f';

final class GroupCategoryBatchUpdateFamily extends $Family
    with $FunctionalFamilyOverride<GroupCategoryBatchUpdate, String> {
  GroupCategoryBatchUpdateFamily._()
    : super(
        retry: null,
        name: r'groupCategoryBatchUpdateProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupCategoryBatchUpdateProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  GroupCategoryBatchUpdateProvider call({required String groupID}) =>
      GroupCategoryBatchUpdateProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupCategoryBatchUpdateProvider';
}

@ProviderFor(groupCategoryImportFromMember)
final groupCategoryImportFromMemberProvider =
    GroupCategoryImportFromMemberFamily._();

final class GroupCategoryImportFromMemberProvider
    extends
        $FunctionalProvider<
          GroupCategoryImportFromMember,
          GroupCategoryImportFromMember,
          GroupCategoryImportFromMember
        >
    with $Provider<GroupCategoryImportFromMember> {
  GroupCategoryImportFromMemberProvider._({
    required GroupCategoryImportFromMemberFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupCategoryImportFromMemberProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$groupCategoryImportFromMemberHash();

  @override
  String toString() {
    return r'groupCategoryImportFromMemberProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GroupCategoryImportFromMember> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupCategoryImportFromMember create(Ref ref) {
    final argument = this.argument as String;
    return groupCategoryImportFromMember(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupCategoryImportFromMember value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupCategoryImportFromMember>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryImportFromMemberProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupCategoryImportFromMemberHash() =>
    r'69dd7ed81872479ea28c7f55a52a5e853f93021c';

final class GroupCategoryImportFromMemberFamily extends $Family
    with $FunctionalFamilyOverride<GroupCategoryImportFromMember, String> {
  GroupCategoryImportFromMemberFamily._()
    : super(
        retry: null,
        name: r'groupCategoryImportFromMemberProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupCategoryImportFromMemberProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  GroupCategoryImportFromMemberProvider call({required String groupID}) =>
      GroupCategoryImportFromMemberProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupCategoryImportFromMemberProvider';
}

@ProviderFor(groupCategoryKeywordAdd)
final groupCategoryKeywordAddProvider = GroupCategoryKeywordAddFamily._();

final class GroupCategoryKeywordAddProvider
    extends
        $FunctionalProvider<
          GroupCategoryKeywordAdd,
          GroupCategoryKeywordAdd,
          GroupCategoryKeywordAdd
        >
    with $Provider<GroupCategoryKeywordAdd> {
  GroupCategoryKeywordAddProvider._({
    required GroupCategoryKeywordAddFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupCategoryKeywordAddProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$groupCategoryKeywordAddHash();

  @override
  String toString() {
    return r'groupCategoryKeywordAddProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GroupCategoryKeywordAdd> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupCategoryKeywordAdd create(Ref ref) {
    final argument = this.argument as String;
    return groupCategoryKeywordAdd(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupCategoryKeywordAdd value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupCategoryKeywordAdd>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupCategoryKeywordAddProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupCategoryKeywordAddHash() =>
    r'ee267ec1aae08d5169e96a129f2a7121af068995';

final class GroupCategoryKeywordAddFamily extends $Family
    with $FunctionalFamilyOverride<GroupCategoryKeywordAdd, String> {
  GroupCategoryKeywordAddFamily._()
    : super(
        retry: null,
        name: r'groupCategoryKeywordAddProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          GroupCategoryKeywordAddProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  GroupCategoryKeywordAddProvider call({required String groupID}) =>
      GroupCategoryKeywordAddProvider._(argument: groupID, from: this);

  @override
  String toString() => r'groupCategoryKeywordAddProvider';
}

@ProviderFor(aiCategorizeApply)
final aiCategorizeApplyProvider = AiCategorizeApplyFamily._();

final class AiCategorizeApplyProvider
    extends
        $FunctionalProvider<
          AICategorizeApply,
          AICategorizeApply,
          AICategorizeApply
        >
    with $Provider<AICategorizeApply> {
  AiCategorizeApplyProvider._({
    required AiCategorizeApplyFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'aiCategorizeApplyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$aiCategorizeApplyHash();

  @override
  String toString() {
    return r'aiCategorizeApplyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AICategorizeApply> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AICategorizeApply create(Ref ref) {
    final argument = this.argument as String;
    return aiCategorizeApply(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AICategorizeApply value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AICategorizeApply>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AiCategorizeApplyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$aiCategorizeApplyHash() => r'a841b666e6f93a6712cfc631d9b3dc5dba3df204';

final class AiCategorizeApplyFamily extends $Family
    with $FunctionalFamilyOverride<AICategorizeApply, String> {
  AiCategorizeApplyFamily._()
    : super(
        retry: null,
        name: r'aiCategorizeApplyProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          AiCategorizeApplyProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  AiCategorizeApplyProvider call({required String groupID}) =>
      AiCategorizeApplyProvider._(argument: groupID, from: this);

  @override
  String toString() => r'aiCategorizeApplyProvider';
}

@ProviderFor(moveItemCategoryKeyword)
final moveItemCategoryKeywordProvider = MoveItemCategoryKeywordFamily._();

final class MoveItemCategoryKeywordProvider
    extends
        $FunctionalProvider<
          MoveItemCategoryKeyword,
          MoveItemCategoryKeyword,
          MoveItemCategoryKeyword
        >
    with $Provider<MoveItemCategoryKeyword> {
  MoveItemCategoryKeywordProvider._({
    required MoveItemCategoryKeywordFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'moveItemCategoryKeywordProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  static final $allTransitiveDependencies0 = groupDatabaseProvider;

  @override
  String debugGetCreateSourceHash() => _$moveItemCategoryKeywordHash();

  @override
  String toString() {
    return r'moveItemCategoryKeywordProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<MoveItemCategoryKeyword> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MoveItemCategoryKeyword create(Ref ref) {
    final argument = this.argument as String;
    return moveItemCategoryKeyword(ref, groupID: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MoveItemCategoryKeyword value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MoveItemCategoryKeyword>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MoveItemCategoryKeywordProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$moveItemCategoryKeywordHash() =>
    r'90d6a93a3f3ded7817a269f24d5b1596a077c413';

final class MoveItemCategoryKeywordFamily extends $Family
    with $FunctionalFamilyOverride<MoveItemCategoryKeyword, String> {
  MoveItemCategoryKeywordFamily._()
    : super(
        retry: null,
        name: r'moveItemCategoryKeywordProvider',
        dependencies: <ProviderOrFamily>[groupDatabaseProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          MoveItemCategoryKeywordProvider.$allTransitiveDependencies0,
        ],
        isAutoDispose: true,
      );

  MoveItemCategoryKeywordProvider call({required String groupID}) =>
      MoveItemCategoryKeywordProvider._(argument: groupID, from: this);

  @override
  String toString() => r'moveItemCategoryKeywordProvider';
}
