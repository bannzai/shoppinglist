// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '쇼핑 리스트';

  @override
  String get commonCancel => '취소';

  @override
  String get commonClose => '닫기';

  @override
  String get commonDone => '완료';

  @override
  String get commonOk => '확인';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonAdd => '추가';

  @override
  String get commonRetry => '다시 시도';

  @override
  String get commonUndo => '실행 취소';

  @override
  String get commonUpgrade => '프리미엄';

  @override
  String get commonSettings => '설정';

  @override
  String get commonCategory => '카테고리';

  @override
  String get commonUncategorized => '분류 없음';

  @override
  String get commonGroup => '그룹';

  @override
  String get commonCamera => '카메라';

  @override
  String get commonPhotoLibrary => '사진 라이브러리';

  @override
  String get commonErrorOccurred => '오류가 발생했습니다';

  @override
  String get errorUnknownTitle => '알 수 없는 오류가 발생했습니다';

  @override
  String get errorUnexpectedTitle => '예상치 못한 오류가 발생했습니다';

  @override
  String get errorFaqLink => 'FAQ 보기';

  @override
  String get authGoogleSignIn => 'Google로 계속하기';

  @override
  String get loadingPreparing => '준비 중...';

  @override
  String get accountDeleteButton => '계정 삭제';

  @override
  String get accountDeleteConfirmTitle => '계정 정보를 삭제하시겠어요?';

  @override
  String get accountDeleteConfirmMessage => '계정을 삭제하면 모든 사용자 정보가 제거됩니다.';

  @override
  String get accountDeleteConfirmButton => '삭제';

  @override
  String get accountDeleteReauthTitle => '다시 로그인해 주세요';

  @override
  String get accountDeleteReauthMessage => '계정을 삭제하려면 다시 로그인해 주세요.';

  @override
  String get accountDeleteReauthButton => '다시 로그인';

  @override
  String get accountDeleteCompletedTitle => '계정이 삭제되었습니다';

  @override
  String get accountDeleteExitAppQuestion => '앱을 종료할까요?';

  @override
  String get accountDeleteExitAppButton => '종료';

  @override
  String get shoppingListDefaultName => '쇼핑 목록';

  @override
  String get shoppingListSettingTooltip => '목록 설정';

  @override
  String get shoppingListEmptyTitle => '아직 쇼핑 목록이 없어요';

  @override
  String get shoppingListEmptyMessage => '새 쇼핑 목록 만들기';

  @override
  String get shoppingListEmptyCreateButton => '쇼핑 목록 만들기';

  @override
  String get shoppingListLoadErrorTitle => '목록을 불러오지 못했습니다';

  @override
  String get shoppingListPickerTitle => '목록 전환';

  @override
  String get shoppingListPickerAddList => '새 목록 추가';

  @override
  String get shoppingListCreateListTooltip => '목록 추가';

  @override
  String get shoppingListCreateTodayList => '현재 날짜로 목록 추가';

  @override
  String get shoppingListDuplicateCurrentList => '현재 목록 복제';

  @override
  String get shoppingListDuplicateUncheckedOnly => '체크 안 된 항목만 복제';

  @override
  String get shoppingListDuplicated => '목록을 복제했어요';

  @override
  String shoppingListDuplicatedFrom(String name) {
    return '$name에서 복제됨';
  }

  @override
  String get shoppingListDeletedListName => '삭제된 목록';

  @override
  String get shoppingListDuplicateSourceDeleted => '원본 쇼핑 목록이 삭제되었습니다';

  @override
  String get shoppingListRetentionBannerMessage =>
      '무료 요금제에서는 리스트가 생성 후 30일이 지나면 자동으로 정리됩니다';

  @override
  String get shoppingListRetentionBannerDetail => '자세히';

  @override
  String get shoppingListSpotlightTitle => '여기에 새 쇼핑 목록을 추가할 수 있어요';

  @override
  String get shoppingListSpotlightMessage =>
      '각 날짜별로 목록을 만들거나, 지금 사용 중인 목록을 복제하세요.';

  @override
  String get shoppingListSpotlightDismiss => '탭하여 닫기';

  @override
  String get shoppingListAiProcessingImage => '사진에서 추천 항목을 가져오는 중...';

  @override
  String get shoppingListAiProcessingUrl => 'URL에서 추천을 추출하는 중…';

  @override
  String get shoppingListAiProcessingCategorize => '카테고리별로 정리하는 중...';

  @override
  String shoppingListAiLimitUpsell(int limit) {
    return '. 프리미엄으로 업그레이드하면 한 달에 $limit회까지 사용할 수 있습니다';
  }

  @override
  String shoppingListAiCategorizeButton(int count) {
    return '자동 분류 ($count개 항목)';
  }

  @override
  String shoppingListAiCategorizeLimitReached(int limit) {
    return '자동 분류의 월간 한도($limit회)에 도달했습니다';
  }

  @override
  String shoppingListAiCategorizeRegistered(int count) {
    return '$count개 항목을 카테고리로 등록했습니다';
  }

  @override
  String get shoppingListAiCategorizeSheetTitle => '자동 분류';

  @override
  String get shoppingListAiCategorizeSheetSubtitle =>
      '저장하기 전에 카테고리를 확인하고 조정하세요';

  @override
  String get shoppingListAiCategorizeSheetEmpty => '분류할 수 있는 항목이 없습니다';

  @override
  String shoppingListAiCategorizeSheetConfirm(int count) {
    return '$count개 항목 등록';
  }

  @override
  String get shoppingListCategorySelect => '카테고리 선택';

  @override
  String get shoppingListCategoryChange => '카테고리 변경';

  @override
  String get shoppingListNewCategoryHint => '새 카테고리 이름';

  @override
  String get shoppingListAddCategoryLabel => '카테고리 추가';

  @override
  String get shoppingListAiReviewTitle => '추출된 सुझाव';

  @override
  String get shoppingListAiReviewSubtitle => '추가할 항목을 선택하세요';

  @override
  String get shoppingListAiReviewEmpty => '추천 항목이 없습니다';

  @override
  String shoppingListAiReviewConfirm(int count) {
    return '$count개 항목 추가';
  }

  @override
  String get shoppingListFabAddFromPhoto => '사진에서 추가';

  @override
  String get shoppingListFabAddFromUrl => 'URL에서 추가';

  @override
  String get shoppingListFabPasteText => '텍스트 붙여넣기';

  @override
  String shoppingListImageRecognitionLimitReached(int limit) {
    return '사진 인식의 월간 한도($limit회)에 도달했습니다';
  }

  @override
  String shoppingListUrlRecognitionLimitReached(int limit) {
    return 'URL 인식의 월간 이용 횟수($limit회)를 초과했습니다';
  }

  @override
  String get shoppingListUrlDialogTitle => 'URL에서 쇼핑 목록 만들기';

  @override
  String get shoppingListUrlDialogGenerate => '생성';

  @override
  String get shoppingListUrlRequired => 'URL을 입력하세요';

  @override
  String get shoppingListUrlInvalid => '유효한 HTTPS URL을 입력하세요';

  @override
  String get shoppingListStarterRowLabel => '탭하여 입력 시작';

  @override
  String get shoppingListHintExample1 => '예: 우유 1L';

  @override
  String get shoppingListHintExample2 => '예: 달걀, 1팩';

  @override
  String get shoppingListHintExample3 => '예: 빵';

  @override
  String get shoppingListHintExample4 => '예: 양파 x2';

  @override
  String get shoppingListHintExample5 => '예: 토마토';

  @override
  String get shoppingListHintCardTitle => '사용 방법';

  @override
  String get shoppingListHintTap => '・행을 탭하고 바로 입력하세요';

  @override
  String get shoppingListHintReturn => '・Enter 키를 누르면 다음 줄로 이동합니다';

  @override
  String get shoppingListHintDelete => '・빈 줄에서 삭제를 누르면 제거할 수 있어요';

  @override
  String get shoppingListHintFabPrefix => '오른쪽 아래의 ';

  @override
  String get shoppingListHintFabSuffix => ' 사진이나 URL에서 추가하려면';

  @override
  String get shoppingListItemDetailTooltip => '항목 상세';

  @override
  String get shoppingListSectionMoveUpTooltip => '카테고리를 위로 이동';

  @override
  String get shoppingListSectionMoveDownTooltip => '카테고리를 아래로 이동';

  @override
  String get shoppingListItemDeleteTooltip => '항목 삭제';

  @override
  String get shoppingListItemDeleteConfirm => '이 항목을 삭제할까요?';

  @override
  String get shoppingListItemDeleted => '항목을 삭제했어요';

  @override
  String get shoppingListItemMemoHint => '메모를 작성하세요...';

  @override
  String get shoppingListNotifyGroup => '그룹에 알리기';

  @override
  String get shoppingListNotifyGroupSent => '그룹에 알림 전송됨';

  @override
  String get shoppingListNotifyGroupGuideLabel => '그룹 알림에 대하여';

  @override
  String get shoppingListNotifyGroupGuideMessage =>
      '이 버튼을 탭하면 그룹의 다른 멤버에게 푸시 알림이 전송되어 쇼핑 목록을 업데이트했다는 사실을 알려줍니다.';

  @override
  String get shoppingListNotifyGroupSend => '알림 보내기';

  @override
  String get commonCopy => '복사';

  @override
  String get commonShare => '공유';

  @override
  String get settingsProfileSection => '프로필';

  @override
  String get settingsDisplayNameLabel => '표시 이름';

  @override
  String get settingsDisplayNameHint => '표시 이름을 입력하세요';

  @override
  String get settingsDisplayNameUpdated => '표시 이름이 업데이트되었습니다';

  @override
  String get settingsGroupManagement => '그룹 관리';

  @override
  String get settingsJoinGroupWithInvitationCode => '초대 코드로 그룹에 참여';

  @override
  String get settingsAppearanceSection => '모양';

  @override
  String get settingsNotificationSection => '알림';

  @override
  String get settingsAboutSection => '이 앱에 대하여';

  @override
  String get settingsTermsOfService => '이용약관';

  @override
  String get settingsPrivacyPolicy => '개인정보처리방침';

  @override
  String get settingsCommercialTransactionAct => '특정 상거래법에 따른 표기';

  @override
  String get settingsInquiry => '문의하기';

  @override
  String get settingsOssLicense => '오픈소스 라이선스';

  @override
  String get settingsDebugSection => '디버그';

  @override
  String get settingsDeveloperOptions => '개발자 옵션';

  @override
  String get settingsPremiumCardTitlePremium => '프리미엄 회원';

  @override
  String get settingsPremiumCardTitleFree => '프리미엄으로 업그레이드';

  @override
  String get settingsPremiumCardSubtitlePremium => '모든 기능을 사용할 수 있습니다';

  @override
  String get settingsPremiumCardSubtitleFree => '5가지 색상 테마, 더 많은 사진/URL 스캔 등';

  @override
  String get settingsPremiumCardStartButton => '시작하기';

  @override
  String get settingsSignOut => '로그아웃';

  @override
  String get settingsSignOutConfirmBarrierLabel => '로그아웃 확인 대화상자';

  @override
  String get settingsSignOutConfirmTitle => '로그아웃할까요?';

  @override
  String get settingsSignOutConfirmMessage =>
      '다시 로그인할 때까지 이 기기에서는 목록에 접근할 수 없습니다.';

  @override
  String get settingsSignOutConfirmMessageGuest =>
      '현재 게스트로 앱을 사용 중이므로, 로그아웃하면 같은 계정으로 다시 로그인할 수 없고 현재 목록과 그룹에 대한 접근 권한도 영구적으로 잃게 됩니다.';

  @override
  String get settingsSignOutCompletedTitle => '로그아웃되었습니다';

  @override
  String get settingsSignOutExitAppMessage => '이제 앱이 종료됩니다';

  @override
  String get settingsThemeColorTitle => '테마 색상';

  @override
  String get settingsThemeColorDescription =>
      '앱 전반에 사용되는 강조 색상을 바꾸려면 다섯 가지 전통 일본 색상 중에서 선택하세요.';

  @override
  String get settingsThemeColorChanged => '테마 색상이 변경되었습니다';

  @override
  String settingsThemeColorSwatchLabel(String label) {
    return '$label 테마 색상';
  }

  @override
  String get settingsThemeColorPremiumOnly => '테마 색상 변경은 프리미엄 기능입니다';

  @override
  String get settingsLocationReminderTitle => '위치 알림';

  @override
  String get settingsLocationReminderSubtitle => '매장 근처에 있을 때 쇼핑 목록을 알려주세요';

  @override
  String get settingsLocationReminderNotificationPermissionRequired =>
      '알림을 허용해야 사용할 수 있어요';

  @override
  String get settingsLocationReminderAlwaysPermissionRequired =>
      '이 기능을 사용하려면 백그라운드 위치 접근을 \'항상 허용\'으로 설정하세요';

  @override
  String get settingsLocationReminderPremiumOnly => '위치 알림은 프리미엄 기능입니다';

  @override
  String get settingsAccountSection => '계정';

  @override
  String get settingsAccountLinked => '계정이 연결되었습니다';

  @override
  String get settingsAccountGuestDescription =>
      '현재 게스트로 앱을 사용 중입니다. 계정을 연결하면 기기를 바꾸거나 다른 기기에서도 같은 목록과 그룹을 사용할 수 있습니다.';

  @override
  String get settingsAccountLinkWithApple => 'Apple로 계정을 연결';

  @override
  String get settingsAccountLinkWithGoogle => 'Google로 계정을 연결';

  @override
  String settingsAccountSignedInWith(String providerName) {
    return '$providerName로 로그인됨';
  }

  @override
  String get settingsAccountReSignInBarrierLabel => '다시 로그인 확인';

  @override
  String get settingsAccountAlreadyInUseTitle => '이 계정은 이미 다른 사용자가 사용 중입니다';

  @override
  String get settingsAccountReSignInMessage =>
      '이 계정으로 다시 로그인하시겠어요?\n다시 로그인하면 현재 게스트 데이터(목록과 그룹)는 이어지지 않습니다.';

  @override
  String get settingsAccountReSignInButton => '다시 로그인';

  @override
  String get listSettingTitle => '쇼핑 목록 설정';

  @override
  String get listSettingNameSection => '목록 이름';

  @override
  String get listSettingShoppingLocationSection => '쇼핑 장소';

  @override
  String get listSettingLocationUnset => '미설정';

  @override
  String get listSettingLocationChangeDetail => '변경';

  @override
  String get listSettingCategorySubtitle => '자동 분류 키워드 관리';

  @override
  String get listSettingStoragePeriodSection => '보관 기간';

  @override
  String get listSettingStoragePeriodPremium => '프리미엄: 무제한';

  @override
  String get listSettingStoragePeriodFree => '생성 후 30일';

  @override
  String get listSettingStoragePeriodUpsell =>
      '프리미엄을 사용하면 목록을 기간 제한 없이 보관할 수 있어요';

  @override
  String get listSettingShareSection => '공유';

  @override
  String get listSettingSendInvitationCode => 'グループに招待コードを送信';

  @override
  String get listSettingGroupSetting => '그룹 설정';

  @override
  String get listSettingGroupNameRequired => '누군가를 초대하기 전에 그룹 이름을 설정하세요';

  @override
  String get listSettingListActionsSection => '목록 작업';

  @override
  String get listSettingDeleteList => '이 목록 삭제';

  @override
  String get listSettingDeleteConfirmBarrierLabel => '쇼핑 리스트 삭제 확인';

  @override
  String get listSettingDeleteConfirmTitle => '이 목록을 삭제할까요?';

  @override
  String listSettingDeleteConfirmMessage(String name, int count) {
    return '\"$name\"과(와) 그 안의 $count개 항목이 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get listSettingInvitationCodeTitle => '초대 코드';

  @override
  String get listSettingInvitationExpired => '만료됨';

  @override
  String listSettingInvitationRemaining(int days, int hours) {
    return '7일 동안 유효 ・ $days일 $hours시간 남음';
  }

  @override
  String get listSettingInvitationCodeCopied => '초대 코드를 복사했습니다';

  @override
  String listSettingInvitationShareText(String code) {
    return '쇼핑 리스트 초대 코드: $code';
  }

  @override
  String get listSettingSelectShoppingLocationTitle => '쇼핑할 위치 선택';

  @override
  String get listSettingLocationNone => '없음';

  @override
  String get listSettingLocationSelected => '선택됨';

  @override
  String get commonDefault => '기본';

  @override
  String get commonUnnamed => '이름 없음';

  @override
  String get commonCreating => '만드는 중…';

  @override
  String get groupNameLabel => '그룹 이름';

  @override
  String get groupNameHint => '그룹 이름을 입력하세요';

  @override
  String get groupCategoryLocationOrderLabel => '쇼핑 장소별로 정렬';

  @override
  String get groupCategoryLocationOrderPremiumOnly =>
      '쇼핑 위치별 카테고리 재정렬은 프리미엄 기능입니다';

  @override
  String groupCategoryKeywordCount(int count) {
    return '키워드: $count';
  }

  @override
  String groupCategoryDeleteConfirmTitle(String name) {
    return '\"$name\"을(를) 삭제할까요?';
  }

  @override
  String get groupCategoryDeleteConfirmMessage => '이 카테고리에 설정된 키워드도 삭제됩니다';

  @override
  String get groupCategoryEmptyTitle => '구매한 항목을 자동으로 분류해요';

  @override
  String get groupCategoryEmptyUseCaseAutoGroup =>
      '토마토와 양파를 \"채소\"로 등록하면 목록의 채소 섹션에 자동으로 그룹화됩니다';

  @override
  String get groupCategoryEmptyUseCaseLocationOrder =>
      '각 매장마다 카테고리 순서를 바꿀 수 있어, 통로 순서대로 쇼핑할 수 있어요.';

  @override
  String get groupCategoryImportTooltip => '멤버의 카테고리 가져오기';

  @override
  String get groupCategoryImportTitle => '카테고리 설정 가져오기';

  @override
  String get groupCategoryImportDescription =>
      '다른 멤버의 카테고리와 매장별 정렬 순서를 내 설정으로 복사할 수 있어요. 이전 복사본을 업데이트하려면 다시 가져오세요.';

  @override
  String get groupCategoryImportEmpty => '가져올 수 있는 카테고리 설정이 없어요';

  @override
  String groupCategoryImportSuccess(String name) {
    return '$name 가져왔어요';
  }

  @override
  String get groupCategoryImportMemberFallback => '그룹 멤버';

  @override
  String get groupCategoryEditTitle => '카테고리 편집';

  @override
  String get groupCategoryEditNotFound => '카테고리를 찾을 수 없습니다';

  @override
  String get groupCategoryEditNameLabel => '카테고리 이름';

  @override
  String get groupCategoryEditNameHint => '카테고리 이름을 입력하세요';

  @override
  String get groupCategoryEditColorLabel => '카테고리 색상';

  @override
  String get groupCategoryEditIconLabel => '카테고리 아이콘';

  @override
  String get groupCategoryEditKeywordsLabel => '키워드';

  @override
  String get groupCategoryEditAddKeyword => '키워드 추가';

  @override
  String get groupCategoryEditKeywordsEmpty => '아직 키워드가 없어요';

  @override
  String get groupCategoryEditKeywordHint => '키워드를 입력하세요';

  @override
  String get groupCategoryEditMatchingLabel => '일치 방식';

  @override
  String get groupCategoryEditMatchingExact => '정확히 일치';

  @override
  String get groupCategoryEditMatchingPartial => '부분 일치';

  @override
  String get groupCategoryEditMatchingRegex => '정규식';

  @override
  String groupCategoryEditRegexTooComplex(int maxLength) {
    return '정규식이 너무 복잡합니다. $maxLength자 이내로 하고 (a+)+ 같은 반복의 중첩은 사용하지 마세요';
  }

  @override
  String get groupCreateTitle => '그룹 만들기';

  @override
  String get groupCreateIconLabel => '아이콘';

  @override
  String get groupCreateSubmit => '만들기';

  @override
  String get groupCreateIconHome => '집';

  @override
  String get groupCreateIconCart => '장바구니';

  @override
  String get groupCreateIconFork => '음식';

  @override
  String get groupCreateIconCookie => '간식';

  @override
  String get groupCreateIconPets => '반려동물';

  @override
  String get groupCreateIconBag => '가방';

  @override
  String get groupCreateInvitationDialogTitle => '멤버 초대';

  @override
  String get groupCreateInvitationDialogMessage => '가족에게 초대 코드를 공유하세요';

  @override
  String get groupInvitationTitle => '초대 코드로 참여하기';

  @override
  String get groupInvitationHeading => '초대 코드를 입력하세요';

  @override
  String get groupInvitationDescription => '그룹 구성원이 공유한 8자리 코드를 입력하세요';

  @override
  String get groupInvitationJoining => '참여 중...';

  @override
  String get groupInvitationJoin => '가입';

  @override
  String get groupInvitationVerifyingTitle => '초대 코드를 확인하는 중';

  @override
  String get groupInvitationVerifyingMessage => '서버에서 그룹 참여 요청을 처리하고 있습니다.';

  @override
  String get groupJoinHeading => '시작해 볼까요';

  @override
  String get groupJoinDescription =>
      '가족이나 파트너에게 초대 코드를 받으셨나요?\n코드로 참여하면 같은 쇼핑 목록을 함께 사용할 수 있어요.';

  @override
  String get groupJoinCreateSolo => '내 목록 만들기';

  @override
  String get groupListEmpty => '아직 어떤 그룹에도 속해 있지 않습니다';

  @override
  String groupListMemberCount(int count) {
    return '멤버 $count명';
  }

  @override
  String get groupListFreeLimitBanner => '무료 플랜에서는 그룹을 1개 추가로 사용할 수 있어요';

  @override
  String get groupListFreeLimitAction => '잠금 해제';

  @override
  String get groupSettingMembersSection => '구성원';

  @override
  String get groupSettingMemberOwner => '소유자';

  @override
  String get groupSettingMemberSelf => '내';

  @override
  String get groupSettingMemberFallbackName => '멤버';

  @override
  String get groupSettingShoppingLocationSubtitle => '매장 추가 및 수정';

  @override
  String get groupSettingInvitationSection => '그룹 초대';

  @override
  String get groupSettingCreatingInvitation => '초대 코드를 생성하는 중...';

  @override
  String get groupSettingCreateInvitation => '초대 코드 발급';

  @override
  String groupSettingRemoveMemberConfirmTitle(String name) {
    return '$name님을 그룹에서 제거할까요?';
  }

  @override
  String get groupSettingRemoveMemberConfirmMessage =>
      '삭제된 멤버는 더 이상 이 그룹에 액세스할 수 없습니다';

  @override
  String groupSettingMemberRemoved(String name) {
    return '$name님을 그룹에서 제거했습니다';
  }

  @override
  String get groupSettingInvitationCodeMessage => '아래 코드를 공유하세요';

  @override
  String get groupSettingInvitationExpiry => '7일 동안 유효';

  @override
  String get commonSave => '저장';

  @override
  String get authHeroTitle => '가족의 쇼핑,\n한 리스트에';

  @override
  String get authHeroDescription =>
      '로그인하면 목록이 기기 간에 자동으로 동기화됩니다. 광고도, 뉴스레터도 없습니다.';

  @override
  String get authStartWithoutSignIn => '로그인 없이 시작';

  @override
  String get authLinkAccountLaterNote => '설정 화면에서 나중에 계정을 연결할 수 있어요';

  @override
  String authAgreementNote(String terms, String privacy) {
    return '계속하면 $terms 및 $privacy에 동의하는 것으로 간주됩니다.';
  }

  @override
  String get inquiryDescription =>
      '보내주신 내용은 모두 읽고 앱 개선에 사용합니다. 답변을 원하시면 이메일 주소를 함께 적어 주세요.';

  @override
  String get inquiryEmailLabel => '이메일 주소';

  @override
  String get inquiryEmailRequired => '이메일 주소를 입력해 주세요';

  @override
  String get inquiryEmailInvalid => '이메일 주소 형식이 올바르지 않습니다';

  @override
  String get inquiryCategoryLabel => '문의 유형';

  @override
  String get inquiryCategoryRequired => '문의 유형을 선택해 주세요';

  @override
  String get inquiryContentLabel => '메시지';

  @override
  String get inquiryContentRequired => '메시지를 입력해 주세요';

  @override
  String get inquiryContentHint => '불편한 점이나 원하시는 기능을 알려 주세요';

  @override
  String get inquirySubmitting => '전송 중...';

  @override
  String get inquirySubmit => '보내기';

  @override
  String get inquirySubmitted => '문의가 전송되었습니다';

  @override
  String get notificationPermissionBarrierLabel => '푸시 알림 권한';

  @override
  String get notificationPermissionTitle => '푸시 알림을 켜세요';

  @override
  String get notificationPermissionMessage =>
      '그룹 구성원이 쇼핑 목록을 업데이트하고 알려 주면 바로 푸시 알림을 받을 수 있어요. 다음에 나오는 확인 창에서 알림을 허용해 주세요.';

  @override
  String get notificationPermissionLater => '나중에';

  @override
  String get notificationPermissionAllow => '알림 허용';

  @override
  String get onboardingSlide1Title => '가족과 함께 만드는\n장보기 목록';

  @override
  String get onboardingSlide1Body =>
      '누군가 집에서 떠올린 물건을 추가하고, 다른 누군가는 매장에서 체크해요. \"이거 좀 사다 줄래?\" 하는 걸 모두 이 한 장에 모아보세요.';

  @override
  String get onboardingSlide2Title => '같은 목록을 동시에 수정';

  @override
  String get onboardingSlide2Body =>
      '초대 코드로 가족, 파트너 또는 룸메이트를 초대하면 모두가 같은 목록을 수정할 수 있어요. 중요한 건 누가 추가했는지가 아니라, 빠뜨리는 것이 없다는 점이에요.';

  @override
  String get onboardingSlide3Title => '매장 근처에 가면\n알려드려요';

  @override
  String get onboardingSlide3Body =>
      '등록한 매장 근처에 가면 쇼핑 리스트를 부드럽게 보여드려요. 꼭 필요할 때만 알림을 보내고, 지나치게 방해하지 않아요.';

  @override
  String get onboardingSkip => '건너뛰기';

  @override
  String get onboardingStart => '시작하기';

  @override
  String get onboardingNext => '다음';

  @override
  String get paywallHeroTitle => '프리미엄으로 업그레이드';

  @override
  String get paywallHeroDescription => '모든 기능을 잠금 해제하고 온 가족과 함께 앱을 즐겨보세요.';

  @override
  String get paywallFeatureLocationOrder => '매장별 카테고리 정렬 순서';

  @override
  String get paywallFeaturePhotoExtraction => '사진에서 항목 추출 (월 50회)';

  @override
  String get paywallFeatureUrlExtraction => 'URL에서 항목 추출 (월 50회)';

  @override
  String get paywallFeatureThemeColors => '5가지 테마 색상';

  @override
  String get paywallFeatureUnlimitedRetention => '목록 무제한 보관';

  @override
  String get paywallFeatureReceipt => '영수증을 목록에 저장';

  @override
  String get paywallSubscriptionNote =>
      '언제든지 취소 가능 ・ 자동 갱신은 갱신 24시간 전까지 취소할 수 있습니다';

  @override
  String get paywallPrivacyLink => '개인정보 보호';

  @override
  String get paywallRestore => '구매 복원';

  @override
  String get paywallRestored => '구매 내역을 복원했습니다';

  @override
  String get paywallNoPlans => '현재 이용 가능한 요금제가 없습니다';

  @override
  String get paywallRecommendedBadge => '추천';

  @override
  String get paywallPurchaseCompleted => '구매해 주셔서 감사합니다';

  @override
  String get paywallPurchaseButton => '구매';

  @override
  String get receiptAdd => '영수증 추가';

  @override
  String get receiptEdit => '영수증 수정';

  @override
  String get receiptSheetTitle => '영수증';

  @override
  String get receiptTakePhoto => '사진 찍기';

  @override
  String get receiptChooseFromLibrary => '사진 보관함에서 선택';

  @override
  String get receiptAmountLabel => '금액';

  @override
  String get receiptMemoLabel => '메모';

  @override
  String get receiptMemoHint => '매장 이름이나 구매한 품목 같은 메모를 적어 주세요';

  @override
  String get receiptCaptureOrSelect => '영수증 사진을 찍거나 선택하세요';

  @override
  String get forceUpdateTitle => '앱을 업데이트해 주세요';

  @override
  String forceUpdateMessage(String storeName) {
    return '앱을 업데이트해 주세요. $storeName에서 최신 버전으로 업데이트해 주세요.';
  }

  @override
  String get shoppingLocationTitle => '쇼핑 위치';

  @override
  String get shoppingLocationEmpty => '아직 등록된 쇼핑 위치가 없어요';

  @override
  String get shoppingLocationGeoConfigured => '위치가 설정됨';

  @override
  String get shoppingLocationAddTitle => '위치 추가하기';

  @override
  String get shoppingLocationEditTitle => '위치 편집';

  @override
  String get shoppingLocationNameHint => '위치 이름';

  @override
  String get shoppingLocationNameHintWithExample => '위치 이름(예: 슈퍼마켓)';

  @override
  String get shoppingLocationPositionSet => '좌표 설정됨';

  @override
  String get shoppingLocationSetOnMap => '지도에서 위치를 설정하세요';

  @override
  String shoppingLocationDeleteConfirmTitle(String name) {
    return '\"$name\"을(를) 삭제할까요?';
  }

  @override
  String get shoppingLocationDeleteConfirmMessage =>
      '이 위치를 삭제해도 이 위치가 설정된 쇼핑 목록에는 영향을 주지 않습니다';

  @override
  String get shoppingLocationPickerTitle => '지도에서 위치를 선택하기';

  @override
  String get shoppingLocationPickerConfirm => '이 위치 사용하기';

  @override
  String get settingsThemeColorShu => '주홍';

  @override
  String get settingsThemeColorMatcha => '말차';

  @override
  String get settingsThemeColorAi => '인디고';

  @override
  String get settingsThemeColorSumi => '먹색';

  @override
  String get settingsThemeColorKuchiba => '고목색';

  @override
  String get inquiryCategoryBugReport => '버그 신고';

  @override
  String get inquiryCategoryHowToUse => '사용 방법';

  @override
  String get inquiryCategoryRequest => '기능 제안';

  @override
  String get inquiryCategoryOther => '기타';

  @override
  String shoppingListLimitExceeded(int limit) {
    return '무료 요금제에서는 그룹당 $limit개의 목록까지 만들 수 있습니다. 무제한 목록을 사용하려면 프리미엄으로 업그레이드하세요.';
  }

  @override
  String get platformGoogleAccountName => 'Google 계정';

  @override
  String get purchaseNotActivated => '구매가 아직 활성화되지 않았습니다. 잠시 후 다시 확인해 주세요.';

  @override
  String get errorTitleServerError => '서버 오류가 발생했어요';

  @override
  String get errorTitleSignInRequired => '로그인이 필요합니다';

  @override
  String get errorTitlePermissionDenied => '이 작업을 수행할 권한이 없습니다';

  @override
  String get errorTitleProviderAlreadyLinked => '이미 연결된 로그인 방식입니다';

  @override
  String get errorTitleCredentialAlreadyInUse => '이 계정은 이미 다른 사용자가 사용 중입니다';

  @override
  String get errorTitleEmailAlreadyInUse => '이 이메일 주소는 이미 다른 사용자가 사용 중입니다';

  @override
  String purchaseErrorUnknown(String details) {
    return '알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 상세 정보: $details';
  }

  @override
  String purchaseErrorStoreProblem(String storeName) {
    return '$storeName에서 오류가 발생하고 있습니다. 잠시 후 다시 시도해 주세요.';
  }

  @override
  String get purchaseErrorNotAllowed => '이 기기에서는 구매할 수 없습니다.';

  @override
  String get purchaseErrorInvalidPayment =>
      '결제에 실패했습니다. 결제 수단이 유효한지 확인한 후 다시 시도해 주세요.';

  @override
  String get purchaseErrorProductNotAvailable =>
      '선택한 요금제는 현재 구매할 수 없습니다. 앱을 다시 시작한 뒤 다시 시도해 주세요.';

  @override
  String get purchaseErrorAlreadyPurchased =>
      '이미 플랜을 구매하셨습니다. 이 기기에서 구매를 복원하려면 \"이미 구매하셨나요? 탭하세요\"를 사용해 구매 정보를 복원하세요.';

  @override
  String purchaseErrorReceiptAlreadyInUse(String accountName) {
    return '이미 구매했거나 구매 정보가 다른 사용자에게 사용 중입니다. $accountName을 확인해 주세요.';
  }

  @override
  String get purchaseErrorInvalidReceipt => '구매 정보가 올바르지 않습니다. 구매 정보를 확인해 주세요.';

  @override
  String purchaseErrorMissingReceipt(String accountName) {
    return '구매자 정보가 없습니다. $accountName로 기기에 로그인한 후 다시 시도하세요.';
  }

  @override
  String get purchaseErrorNetwork =>
      '네트워크 연결이 불안정합니다. 연결 상태를 확인한 후 다시 시도해 주세요.';

  @override
  String purchaseErrorPurchaseFailed(String details) {
    return '구매에 실패했습니다. 잠시 후 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 상세 정보: $details';
  }

  @override
  String purchaseErrorUnavailable(String details) {
    return '현재 구매할 수 없습니다. 잠시 후 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 상세 정보: $details';
  }

  @override
  String purchaseErrorReceiptInUseByOther(String accountName) {
    return '구매 정보가 다른 사용자가 사용 중입니다. 이 기기에서 로그인한 $accountName을 확인하세요.';
  }

  @override
  String purchaseErrorInvalidAppUserId(String details) {
    return '사용자를 확인할 수 없어요. 앱을 다시 시작한 뒤 다시 시도해 주세요. 자세한 내용: $details';
  }

  @override
  String get purchaseErrorOperationInProgress =>
      '다른 구매가 이미 진행 중입니다. 잠시 후 다시 확인해 주세요.';

  @override
  String purchaseErrorIneligible(String details) {
    return '사용자 계정으로 구매하지 못했습니다. 잠시 후 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 자세한 내용: $details';
  }

  @override
  String purchaseErrorInsufficientPermissions(String accountName) {
    return '$accountName으로는 요금제에 가입할 수 없습니다. 결제 정보를 확인한 후 다시 시도해 주세요.';
  }

  @override
  String purchaseErrorPaymentPending(String accountName, String storeName) {
    return '결제가 보류되었습니다. 현재 로그인한 $accountName으로 $storeName을(를) 확인해 주세요.';
  }

  @override
  String purchaseErrorUserInfoFailed(String details) {
    return '사용자 정보를 가져오지 못했습니다. 잠시 후 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 자세한 내용: $details';
  }

  @override
  String purchaseErrorConfiguration(String details) {
    return '구매 정보를 가져오지 못했습니다. 잠시 후 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 자세한 내용: $details';
  }

  @override
  String purchaseErrorUpdateRequired(String code, String details) {
    return '알 수 없는 오류가 발생했습니다. 최신 버전으로 업데이트한 뒤 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 코드: $code 세부정보: $details';
  }

  @override
  String purchaseErrorEmptySubscriberAttributes(String details) {
    return '알 수 없는 오류가 발생했습니다. 구매 정보를 미리 가져올 수 없습니다. 자세한 내용: $details';
  }

  @override
  String purchaseErrorCustomerInfo(String code, String details) {
    return '고객 정보를 가져오지 못했습니다. 잠시 후 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 자세한 내용: 코드: $code $details';
  }

  @override
  String purchaseErrorSystemInfo(String code, String details) {
    return '기기 설정에 문제가 있습니다. 설정을 확인한 후 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 코드: $code 세부 정보: $details';
  }

  @override
  String purchaseErrorBeginRefundRequest(String code, String details) {
    return '환불 절차가 시작되었습니다. 내용을 확인한 후 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 코드: $code 상세: $details';
  }

  @override
  String purchaseErrorTimeout(String details) {
    return '요청 시간이 초과되었습니다. 네트워크 연결을 확인한 뒤 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 자세한 내용: $details';
  }

  @override
  String purchaseErrorOfflineConnection(String details) {
    return '연결 상태가 좋지 않습니다. 네트워크 연결을 확인한 후 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 상세 정보: $details';
  }

  @override
  String purchaseErrorFeatureNotAvailable(String code, String details) {
    return '현재 설정에서는 이 기능을 사용할 수 없습니다. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 코드: $code 상세: $details';
  }

  @override
  String purchaseErrorSignatureVerification(String code, String details) {
    return '서명 확인에 실패했습니다. 잠시 후 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 코드: $code 상세: $details';
  }

  @override
  String purchaseErrorFeatureNotSupported(String code, String details) {
    return '이 기능은 현재 기기에서 지원되지 않습니다. 최신 버전으로 업데이트한 후 다시 시도해 주세요. 코드: $code 세부정보: $details';
  }

  @override
  String purchaseErrorInvalidWebPurchaseToken(String code, String details) {
    return '구매 토큰이 유효하지 않습니다. 다시 시도해 주세요. 문제가 계속되면 설정 > 문의에서 연락해 주세요. 코드: $code 상세: $details';
  }

  @override
  String purchaseErrorBelongsToOtherUser(String code, String details) {
    return '이 구매는 다른 사용자 계정에 연결되어 있습니다. 계정을 확인해 주세요. 코드: $code 세부정보: $details';
  }

  @override
  String purchaseErrorExpiredWebPurchaseToken(String code, String details) {
    return '구매 토큰이 만료되었습니다. 다시 시도해 주세요. 코드: $code 상세: $details';
  }

  @override
  String purchaseErrorTestStoreSimulated(String code, String details) {
    return '테스트 구매 중 오류가 발생했습니다. 코드: $code 세부정보: $details';
  }
}
