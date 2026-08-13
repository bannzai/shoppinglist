// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '购物清单';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '关闭';

  @override
  String get commonDone => '完成';

  @override
  String get commonOk => '确定';

  @override
  String get commonDelete => '删除';

  @override
  String get commonAdd => '添加';

  @override
  String get commonRetry => '重试';

  @override
  String get commonUndo => '撤销';

  @override
  String get commonUpgrade => '升级';

  @override
  String get commonSettings => '设置';

  @override
  String get commonCategory => '分类';

  @override
  String get commonUncategorized => '未分类';

  @override
  String get commonGroup => '群组';

  @override
  String get commonCamera => '相机';

  @override
  String get commonPhotoLibrary => '照片图库';

  @override
  String get commonErrorOccurred => '发生错误';

  @override
  String get errorUnknownTitle => '发生了未知错误';

  @override
  String get errorUnexpectedTitle => '发生了意外错误';

  @override
  String get errorFaqLink => '查看常见问题';

  @override
  String get authGoogleSignIn => '使用 Google 登录';

  @override
  String get loadingPreparing => '正在准备…';

  @override
  String get accountDeleteButton => '删除账号';

  @override
  String get accountDeleteConfirmTitle => '删除您的账户信息';

  @override
  String get accountDeleteConfirmMessage => '删除你的账号将移除所有用户信息。';

  @override
  String get accountDeleteConfirmButton => '删除';

  @override
  String get accountDeleteReauthTitle => '请重新登录';

  @override
  String get accountDeleteReauthMessage => '要删除您的账户，请重新登录。';

  @override
  String get accountDeleteReauthButton => '请重新登录';

  @override
  String get accountDeleteCompletedTitle => '您的账户已被删除';

  @override
  String get accountDeleteExitAppQuestion => '要退出应用吗？';

  @override
  String get accountDeleteExitAppButton => '退出';

  @override
  String get shoppingListDefaultName => '购物清单';

  @override
  String get shoppingListSettingTooltip => '清单设置';

  @override
  String get shoppingListEmptyTitle => '还没有购物清单';

  @override
  String get shoppingListEmptyMessage => '创建新的购物清单';

  @override
  String get shoppingListEmptyCreateButton => '创建购物清单';

  @override
  String get shoppingListLoadErrorTitle => '列表加载失败';

  @override
  String get shoppingListPickerTitle => '切换清单';

  @override
  String get shoppingListPickerAddList => '添加新清单';

  @override
  String get shoppingListCreateListTooltip => '添加列表';

  @override
  String get shoppingListCreateTodayList => '添加一个带有当前日期的清单';

  @override
  String get shoppingListDuplicateCurrentList => '复制当前清单';

  @override
  String get shoppingListDuplicateUncheckedOnly => '仅复制未勾选的项目';

  @override
  String get shoppingListDuplicated => '已复制清单';

  @override
  String shoppingListDuplicatedFrom(String name) {
    return '复制自 $name';
  }

  @override
  String get shoppingListDeletedListName => '已删除的清单';

  @override
  String get shoppingListDuplicateSourceDeleted => '原始购物清单已删除';

  @override
  String get shoppingListRetentionBannerMessage => '在免费方案中，清单会在创建 30 天后自动清理';

  @override
  String get shoppingListRetentionBannerDetail => '详情';

  @override
  String get shoppingListSpotlightTitle => '你可以在这里添加新的购物清单';

  @override
  String get shoppingListSpotlightMessage => '为每个日期创建一个清单，或复制你现在使用的清单。';

  @override
  String get shoppingListSpotlightDismiss => '轻触关闭';

  @override
  String get shoppingListAiProcessingImage => '正在从照片中提取建议…';

  @override
  String get shoppingListAiProcessingUrl => '正在从网址提取建议…';

  @override
  String get shoppingListAiProcessingCategorize => '正在按类别整理……';

  @override
  String shoppingListAiLimitUpsell(int limit) {
    return '。升级到高级版后，每月可使用 $limit 次';
  }

  @override
  String shoppingListAiCategorizeButton(int count) {
    return '自动分类（$count 项）';
  }

  @override
  String shoppingListAiCategorizeLimitReached(int limit) {
    return '已达到自动分类的月度上限（$limit次）';
  }

  @override
  String shoppingListAiCategorizeRegistered(int count) {
    return '已将 $count 个项目归类';
  }

  @override
  String get shoppingListAiCategorizeSheetTitle => '自动分类';

  @override
  String get shoppingListAiCategorizeSheetSubtitle => '在保存前查看并调整分类';

  @override
  String get shoppingListAiCategorizeSheetEmpty => '没有可分类的项目';

  @override
  String shoppingListAiCategorizeSheetConfirm(int count) {
    return '注册 $count 项';
  }

  @override
  String get shoppingListCategorySelect => '选择分类';

  @override
  String get shoppingListCategoryChange => '更改分类';

  @override
  String get shoppingListNewCategoryHint => '新分类名称';

  @override
  String get shoppingListAddCategoryLabel => '添加类别';

  @override
  String get shoppingListAiReviewTitle => '提取的建议';

  @override
  String get shoppingListAiReviewSubtitle => '选择要添加的商品';

  @override
  String get shoppingListAiReviewEmpty => '未找到任何建议';

  @override
  String shoppingListAiReviewConfirm(int count) {
    return '添加 $count 个项目';
  }

  @override
  String get shoppingListFabAddFromPhoto => '从照片添加';

  @override
  String get shoppingListFabAddFromUrl => '从网址添加';

  @override
  String get shoppingListFabPasteText => '粘贴文本';

  @override
  String shoppingListImageRecognitionLimitReached(int limit) {
    return '已达到照片识别的每月上限（$limit次）';
  }

  @override
  String shoppingListUrlRecognitionLimitReached(int limit) {
    return 'URL 识别的每月次数已达上限（$limit 次）';
  }

  @override
  String get shoppingListUrlDialogTitle => '从网址生成购物清单';

  @override
  String get shoppingListUrlDialogGenerate => '生成';

  @override
  String get shoppingListUrlRequired => '请输入网址';

  @override
  String get shoppingListUrlInvalid => '请输入有效的 HTTPS URL';

  @override
  String get shoppingListStarterRowLabel => '轻点开始输入';

  @override
  String get shoppingListHintExample1 => '例如：牛奶 1升';

  @override
  String get shoppingListHintExample2 => '例如：鸡蛋，1包';

  @override
  String get shoppingListHintExample3 => '例如：面包';

  @override
  String get shoppingListHintExample4 => '例如：洋葱 x2';

  @override
  String get shoppingListHintExample5 => '例如：番茄';

  @override
  String get shoppingListHintCardTitle => '使用方法';

  @override
  String get shoppingListHintTap => '・点按一行即可直接输入';

  @override
  String get shoppingListHintReturn => '・按回车换到下一行';

  @override
  String get shoppingListHintDelete => '・在空行上按删除键即可移除';

  @override
  String get shoppingListHintFabPrefix => '长按右下角的 ';

  @override
  String get shoppingListHintFabSuffix => '右下角可从照片或网址添加';

  @override
  String get shoppingListItemDetailTooltip => '商品详情';

  @override
  String get shoppingListItemDeleteTooltip => '删除项目';

  @override
  String get shoppingListItemDeleteConfirm => '删除此项目？';

  @override
  String get shoppingListItemDeleted => '已删除该商品';

  @override
  String get shoppingListItemMemoHint => '写个备注……';

  @override
  String get shoppingListNotifyGroup => '通知群组';

  @override
  String get shoppingListNotifyGroupSent => '已通知群组';

  @override
  String get shoppingListNotifyGroupGuideLabel => '关于群组通知';

  @override
  String get shoppingListNotifyGroupGuideMessage =>
      '点按此按钮会向群组中的其他成员发送推送通知，告知他们您已更新购物清单。';

  @override
  String get shoppingListNotifyGroupSend => '发送通知';

  @override
  String get commonCopy => '复制';

  @override
  String get commonShare => '分享';

  @override
  String get settingsProfileSection => '个人资料';

  @override
  String get settingsDisplayNameLabel => '你的显示名称';

  @override
  String get settingsDisplayNameHint => '输入显示名称';

  @override
  String get settingsDisplayNameUpdated => '已更新你的显示名称';

  @override
  String get settingsGroupManagement => '管理群组';

  @override
  String get settingsJoinGroupWithInvitationCode => '使用邀请码加入群组';

  @override
  String get settingsAppearanceSection => '外观';

  @override
  String get settingsNotificationSection => '通知';

  @override
  String get settingsAboutSection => '关于此应用';

  @override
  String get settingsTermsOfService => '服务条款';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsCommercialTransactionAct => '基于《指定商业交易法》的说明';

  @override
  String get settingsInquiry => '联系我们';

  @override
  String get settingsOssLicense => '开源许可证';

  @override
  String get settingsDebugSection => '调试';

  @override
  String get settingsDeveloperOptions => '开发者选项';

  @override
  String get settingsPremiumCardTitlePremium => '高级版会员';

  @override
  String get settingsPremiumCardTitleFree => '升级到高级版';

  @override
  String get settingsPremiumCardSubtitlePremium => '您可使用全部功能';

  @override
  String get settingsPremiumCardSubtitleFree => '五种颜色主题，更多照片/网址扫描等功能';

  @override
  String get settingsPremiumCardStartButton => '开始使用';

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get settingsSignOutConfirmBarrierLabel => '退出登录确认';

  @override
  String get settingsSignOutConfirmTitle => '要退出登录吗？';

  @override
  String get settingsSignOutConfirmMessage => '在您再次登录之前，您将无法从此设备访问您的清单。';

  @override
  String get settingsSignOutConfirmMessageGuest =>
      '您当前以访客身份使用此应用，因此如果退出登录，您将无法再次登录同一账户，并且会永久失去对当前列表和群组的访问权限。';

  @override
  String get settingsSignOutCompletedTitle => '已退出登录';

  @override
  String get settingsSignOutExitAppMessage => '应用将立即退出';

  @override
  String get settingsThemeColorTitle => '主题颜色';

  @override
  String get settingsThemeColorDescription => '从五种传统日式颜色中选择，来更改应用中的强调色。';

  @override
  String get settingsThemeColorChanged => '主题颜色已更改';

  @override
  String settingsThemeColorSwatchLabel(String label) {
    return '$label 主题颜色';
  }

  @override
  String get settingsThemeColorPremiumOnly => '更改主题颜色是高级版功能';

  @override
  String get settingsLocationReminderTitle => '位置提醒';

  @override
  String get settingsLocationReminderSubtitle => '当我靠近商店时提醒我购物清单';

  @override
  String get settingsLocationReminderNotificationPermissionRequired =>
      '允许通知后可使用此功能';

  @override
  String get settingsLocationReminderAlwaysPermissionRequired =>
      '将后台定位权限设置为“始终”以使用此功能';

  @override
  String get settingsLocationReminderPremiumOnly => '位置提醒是高级版功能';

  @override
  String get settingsAccountSection => '账户';

  @override
  String get settingsAccountLinked => '已关联你的账户';

  @override
  String get settingsAccountGuestDescription =>
      '您正在以访客身份使用此应用。关联账号后，即使更换设备或在其他设备上，也能使用相同的清单和群组。';

  @override
  String get settingsAccountLinkWithApple => '使用 Apple 关联账号';

  @override
  String get settingsAccountLinkWithGoogle => '将账号与 Google 关联';

  @override
  String settingsAccountSignedInWith(String providerName) {
    return '已通过 $providerName 登录';
  }

  @override
  String get settingsAccountReSignInBarrierLabel => '重新登录确认';

  @override
  String get settingsAccountAlreadyInUseTitle => '此账号已被其他用户使用';

  @override
  String get settingsAccountReSignInMessage =>
      '要再次使用此账号登录吗？\n如果再次登录，当前访客数据（列表和群组）将不会被保留。';

  @override
  String get settingsAccountReSignInButton => '重新登录';

  @override
  String get listSettingTitle => '购物清单设置';

  @override
  String get listSettingNameSection => '清单名称';

  @override
  String get listSettingShoppingLocationSection => '购物地点';

  @override
  String get listSettingLocationUnset => '未设置';

  @override
  String get listSettingLocationChangeDetail => '更改';

  @override
  String get listSettingCategorySubtitle => '管理自动分类关键词';

  @override
  String get listSettingStoragePeriodSection => '保留期限';

  @override
  String get listSettingStoragePeriodPremium => '高级版：无限制';

  @override
  String get listSettingStoragePeriodFree => '创建后30天';

  @override
  String get listSettingStoragePeriodUpsell => '使用高级版，您可以无限期保存清单';

  @override
  String get listSettingShareSection => '共享';

  @override
  String get listSettingSendInvitationCode => '向群组发送邀请码';

  @override
  String get listSettingGroupSetting => '群组设置';

  @override
  String get listSettingGroupNameRequired => '请先设置群组名称，再邀请他人';

  @override
  String get listSettingListActionsSection => '列表操作';

  @override
  String get listSettingDeleteList => '删除此清单';

  @override
  String get listSettingDeleteConfirmBarrierLabel => '购物清单删除确认';

  @override
  String get listSettingDeleteConfirmTitle => '要删除此清单吗？';

  @override
  String listSettingDeleteConfirmMessage(String name, int count) {
    return '“$name”及其中的 $count 个商品将被删除。此操作无法撤销。';
  }

  @override
  String get listSettingInvitationCodeTitle => '邀请码';

  @override
  String get listSettingInvitationExpired => '已过期';

  @override
  String listSettingInvitationRemaining(int days, int hours) {
    return '有效期 7 天 ・ 还剩 $days 天 $hours 小时';
  }

  @override
  String get listSettingInvitationCodeCopied => '已复制邀请码';

  @override
  String listSettingInvitationShareText(String code) {
    return '购物清单邀请码：$code';
  }

  @override
  String get listSettingSelectShoppingLocationTitle => '选择购物地点';

  @override
  String get listSettingLocationNone => '无';

  @override
  String get listSettingLocationSelected => '已选择';

  @override
  String get commonDefault => '默认';

  @override
  String get commonUnnamed => '未命名';

  @override
  String get commonCreating => '创建中…';

  @override
  String get groupNameLabel => '群组名称';

  @override
  String get groupNameHint => '输入群组名称';

  @override
  String get groupCategoryLocationOrderLabel => '按购物地点排序';

  @override
  String get groupCategoryLocationOrderPremiumOnly => '按购物地点重新排序类别是高级版功能';

  @override
  String groupCategoryKeywordCount(int count) {
    return '关键词：$count';
  }

  @override
  String groupCategoryDeleteConfirmTitle(String name) {
    return '要删除“$name”吗？';
  }

  @override
  String get groupCategoryDeleteConfirmMessage => '为此分类设置的关键词也会被删除';

  @override
  String get groupCategoryEmptyTitle => '自动整理你的购物分类';

  @override
  String get groupCategoryEmptyUseCaseAutoGroup =>
      '将番茄和洋葱归入“蔬菜”后，它们会自动分组到清单的蔬菜区';

  @override
  String get groupCategoryEmptyUseCaseLocationOrder =>
      '您可以为每个商店调整分类顺序，这样就能按货架顺序购物。';

  @override
  String get groupCategoryEditTitle => '编辑分类';

  @override
  String get groupCategoryEditNotFound => '未找到分类';

  @override
  String get groupCategoryEditNameLabel => '分类名称';

  @override
  String get groupCategoryEditNameHint => '输入类别名称';

  @override
  String get groupCategoryEditColorLabel => '分类颜色';

  @override
  String get groupCategoryEditIconLabel => '分类图标';

  @override
  String get groupCategoryEditKeywordsLabel => '关键词';

  @override
  String get groupCategoryEditAddKeyword => '添加关键词';

  @override
  String get groupCategoryEditKeywordsEmpty => '还没有关键词';

  @override
  String get groupCategoryEditKeywordHint => '输入关键字';

  @override
  String get groupCategoryEditMatchingLabel => '匹配方式';

  @override
  String get groupCategoryEditMatchingExact => '完全匹配';

  @override
  String get groupCategoryEditMatchingPartial => '部分匹配';

  @override
  String get groupCategoryEditMatchingRegex => '正则表达式';

  @override
  String get groupCreateTitle => '创建群组';

  @override
  String get groupCreateIconLabel => '图标';

  @override
  String get groupCreateSubmit => '创建';

  @override
  String get groupCreateIconHome => '家';

  @override
  String get groupCreateIconCart => '购物车';

  @override
  String get groupCreateIconFork => '食物';

  @override
  String get groupCreateIconCookie => '零食';

  @override
  String get groupCreateIconPets => '宠物';

  @override
  String get groupCreateIconBag => '包';

  @override
  String get groupCreateInvitationDialogTitle => '邀请成员';

  @override
  String get groupCreateInvitationDialogMessage => '将邀请码分享给家人';

  @override
  String get groupInvitationTitle => '使用邀请码加入';

  @override
  String get groupInvitationHeading => '输入邀请码';

  @override
  String get groupInvitationDescription => '输入群组成员分享给您的 8 位验证码';

  @override
  String get groupInvitationJoining => '加入中…';

  @override
  String get groupInvitationJoin => '加入';

  @override
  String get groupInvitationVerifyingTitle => '正在检查邀请码';

  @override
  String get groupInvitationVerifyingMessage => '服务器正在处理你加入群组的请求。';

  @override
  String get groupJoinHeading => '开始吧';

  @override
  String get groupJoinDescription =>
      '你收到家人或伴侣发来的邀请码了吗？\n使用邀请码加入后，你们就可以一起使用同一份购物清单。';

  @override
  String get groupJoinCreateSolo => '创建自己的清单';

  @override
  String get groupListEmpty => '你还不属于任何群组';

  @override
  String groupListMemberCount(int count) {
    return '$count 位成员';
  }

  @override
  String get groupListFreeLimitBanner => '免费版可额外添加一个群组';

  @override
  String get groupListFreeLimitAction => '解锁';

  @override
  String get groupSettingMembersSection => '成员';

  @override
  String get groupSettingMemberOwner => '群主';

  @override
  String get groupSettingMemberSelf => '你';

  @override
  String get groupSettingMemberFallbackName => '成员';

  @override
  String get groupSettingShoppingLocationSubtitle => '添加并编辑商店';

  @override
  String get groupSettingInvitationSection => '群组邀请';

  @override
  String get groupSettingCreatingInvitation => '正在生成邀请码…';

  @override
  String get groupSettingCreateInvitation => '生成邀请码';

  @override
  String groupSettingRemoveMemberConfirmTitle(String name) {
    return '要将$name从群组中移除吗？';
  }

  @override
  String get groupSettingRemoveMemberConfirmMessage => '被移除的成员将无法再访问此群组';

  @override
  String groupSettingMemberRemoved(String name) {
    return '已移除$name';
  }

  @override
  String get groupSettingInvitationCodeMessage => '分享下面的代码';

  @override
  String get groupSettingInvitationExpiry => '有效期 7 天';

  @override
  String get commonSave => '保存';

  @override
  String get authHeroTitle => '家人的购物\n尽在一个清单';

  @override
  String get authHeroDescription => '登录后，你的列表会在各设备间保持同步。无广告，无新闻邮件。';

  @override
  String get authStartWithoutSignIn => '无需登录即可开始';

  @override
  String get authLinkAccountLaterNote => '你可以稍后在设置页面关联账号';

  @override
  String authAgreementNote(String terms, String privacy) {
    return '继续使用即表示你同意$terms和$privacy。';
  }

  @override
  String get inquiryDescription =>
      '我们会阅读您发送的所有内容，并用它来改进应用。如果您希望我们回复，请附上您的电子邮件地址。';

  @override
  String get inquiryEmailLabel => '电子邮箱地址';

  @override
  String get inquiryEmailRequired => '请输入您的电子邮箱地址';

  @override
  String get inquiryEmailInvalid => '电子邮件地址格式不正确';

  @override
  String get inquiryCategoryLabel => '咨询类型';

  @override
  String get inquiryCategoryRequired => '请选择您的咨询类型';

  @override
  String get inquiryContentLabel => '您的留言';

  @override
  String get inquiryContentRequired => '请输入您的留言';

  @override
  String get inquiryContentHint => '告诉我们您遇到了什么问题，或者希望看到什么功能';

  @override
  String get inquirySubmitting => '发送中…';

  @override
  String get inquirySubmit => '发送';

  @override
  String get inquirySubmitted => '您的咨询已发送';

  @override
  String get notificationPermissionBarrierLabel => '推送通知权限';

  @override
  String get notificationPermissionTitle => '开启推送通知';

  @override
  String get notificationPermissionMessage =>
      '当群组中的成员更新购物清单并通知你时，你会立即收到推送通知。请在接下来弹出的确认中允许通知。';

  @override
  String get notificationPermissionLater => '稍后';

  @override
  String get notificationPermissionAllow => '允许通知';

  @override
  String get onboardingSlide1Title => '全家一起创建的\n购物清单';

  @override
  String get onboardingSlide1Body =>
      '有人把在家想到的东西加进来，另一个人在商店把它勾掉。把所有“你能顺手带一下吗？”都放到这张清单上。';

  @override
  String get onboardingSlide2Title => '同时编辑同一个清单';

  @override
  String get onboardingSlide2Body =>
      '使用邀请码邀请你的家人、伴侣或室友，大家都能编辑同一份清单。重要的不是谁添加的，而是不要漏掉任何东西。';

  @override
  String get onboardingSlide3Title => '当您靠近商店时\n温馨提醒';

  @override
  String get onboardingSlide3Body =>
      '当您靠近已登记的商店时，我们会轻轻提醒您查看购物清单。只在您需要时发送通知，绝不打扰。';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingStart => '开始使用';

  @override
  String get onboardingNext => '下一步';

  @override
  String get paywallHeroTitle => '升级到高级版';

  @override
  String get paywallHeroDescription => '解锁所有功能，与全家人一起畅享这款应用。';

  @override
  String get paywallFeatureLocationOrder => '每个商店的分类顺序';

  @override
  String get paywallFeaturePhotoExtraction => '从照片中提取物品（每月 50 次）';

  @override
  String get paywallFeatureUrlExtraction => '从网址中提取项目（每月 50 次）';

  @override
  String get paywallFeatureThemeColors => '五种主题颜色';

  @override
  String get paywallFeatureUnlimitedRetention => '无限期保留清单';

  @override
  String get paywallFeatureReceipt => '将收据保存到清单';

  @override
  String get paywallSubscriptionNote => '可随时取消 ・ 自动续订可在续订前 24 小时内取消';

  @override
  String get paywallPrivacyLink => '隐私';

  @override
  String get paywallRestore => '恢复购买';

  @override
  String get paywallRestored => '已恢复你的购买项目';

  @override
  String get paywallNoPlans => '目前没有可用的套餐';

  @override
  String get paywallRecommendedBadge => '推荐';

  @override
  String get paywallPurchaseCompleted => '感谢您的购买';

  @override
  String get paywallPurchaseButton => '购买';

  @override
  String get receiptAdd => '添加收据';

  @override
  String get receiptEdit => '编辑收据';

  @override
  String get receiptSheetTitle => '收据';

  @override
  String get receiptTakePhoto => '拍照';

  @override
  String get receiptChooseFromLibrary => '从照片图库中选择';

  @override
  String get receiptAmountLabel => '金额';

  @override
  String get receiptMemoLabel => '备注';

  @override
  String get receiptMemoHint => '商店名称或购买内容等备注';

  @override
  String get receiptCaptureOrSelect => '拍摄或选择收据照片';

  @override
  String get forceUpdateTitle => '请更新应用';

  @override
  String forceUpdateMessage(String storeName) {
    return '我们希望您更新此应用。请从 $storeName 更新到最新版本。';
  }

  @override
  String get shoppingLocationTitle => '购物地点';

  @override
  String get shoppingLocationEmpty => '还没有购物地点';

  @override
  String get shoppingLocationGeoConfigured => '已设置位置';

  @override
  String get shoppingLocationAddTitle => '添加位置';

  @override
  String get shoppingLocationEditTitle => '编辑位置';

  @override
  String get shoppingLocationNameHint => '位置名称';

  @override
  String get shoppingLocationNameHintWithExample => '地点名称（例如：超市）';

  @override
  String get shoppingLocationPositionSet => '位置已设置';

  @override
  String get shoppingLocationSetOnMap => '在地图上设置位置';

  @override
  String shoppingLocationDeleteConfirmTitle(String name) {
    return '删除“$name”？';
  }

  @override
  String get shoppingLocationDeleteConfirmMessage => '删除此位置不会影响已设置该位置的购物清单';

  @override
  String get shoppingLocationPickerTitle => '在地图上选择位置';

  @override
  String get shoppingLocationPickerConfirm => '使用此位置';

  @override
  String get settingsThemeColorShu => '朱红';

  @override
  String get settingsThemeColorMatcha => '抹茶';

  @override
  String get settingsThemeColorAi => '靛蓝';

  @override
  String get settingsThemeColorSumi => '墨色';

  @override
  String get settingsThemeColorKuchiba => '朽叶';

  @override
  String get inquiryCategoryBugReport => '问题反馈';

  @override
  String get inquiryCategoryHowToUse => '使用方法';

  @override
  String get inquiryCategoryRequest => '功能建议';

  @override
  String get inquiryCategoryOther => '其他';

  @override
  String shoppingListLimitExceeded(int limit) {
    return '免费方案下，每个群组最多可创建 $limit 个清单。升级到高级版即可无限创建清单。';
  }

  @override
  String get platformGoogleAccountName => 'Google 帐号';

  @override
  String get purchaseNotActivated => '您的购买尚未生效。请稍后再试。';

  @override
  String get errorTitleServerError => '发生服务器错误';

  @override
  String get errorTitleSignInRequired => '需要登录';

  @override
  String get errorTitlePermissionDenied => '你没有权限执行此操作';

  @override
  String get errorTitleProviderAlreadyLinked => '此登录方式已关联';

  @override
  String get errorTitleCredentialAlreadyInUse => '此账号已被其他用户使用';

  @override
  String get errorTitleEmailAlreadyInUse => '此电子邮件地址已被其他用户使用';

  @override
  String purchaseErrorUnknown(String details) {
    return '发生未知错误。请稍后再试。如果问题仍然存在，请通过“设置”>“反馈”联系我们。详情：$details';
  }

  @override
  String purchaseErrorStoreProblem(String storeName) {
    return '$storeName 发生了错误。请稍后再试。';
  }

  @override
  String get purchaseErrorNotAllowed => '此设备不允许购买。';

  @override
  String get purchaseErrorInvalidPayment => '付款失败。请确认您的付款方式有效后重试。';

  @override
  String get purchaseErrorProductNotAvailable => '所选方案当前未在售。请重启应用后再试。';

  @override
  String get purchaseErrorAlreadyPurchased =>
      '您已经购买过方案。要在此设备上恢复购买，请点按“已购买？点此恢复”来恢复您的购买信息。';

  @override
  String purchaseErrorReceiptAlreadyInUse(String accountName) {
    return '已购买，或购买信息已被其他用户使用。请检查你的$accountName。';
  }

  @override
  String get purchaseErrorInvalidReceipt => '购买信息无效。请检查您的购买信息。';

  @override
  String purchaseErrorMissingReceipt(String accountName) {
    return '没有购买者信息。请使用 $accountName 登录设备后重试。';
  }

  @override
  String get purchaseErrorNetwork => '网络连接不稳定。请检查连接后重试。';

  @override
  String purchaseErrorPurchaseFailed(String details) {
    return '购买失败。请稍后再试。如果问题仍然存在，请前往“设置”>“反馈”联系我们。详情：$details';
  }

  @override
  String purchaseErrorUnavailable(String details) {
    return '当前无法购买。请稍后再试。如果问题仍然存在，请前往“设置”>“咨询”联系我们。详情：$details';
  }

  @override
  String purchaseErrorReceiptInUseByOther(String accountName) {
    return '购买信息已被其他用户使用。请检查您在此设备上登录的$accountName。';
  }

  @override
  String purchaseErrorInvalidAppUserId(String details) {
    return '我们无法验证您的用户身份。请重新启动应用后再试。详情：$details';
  }

  @override
  String get purchaseErrorOperationInProgress => '已有另一笔购买正在进行中。请稍等片刻后再试。';

  @override
  String purchaseErrorIneligible(String details) {
    return '您的账号购买失败。请稍后再试。如果问题仍然存在，请在“设置”>“咨询”中联系我们。详情：$details';
  }

  @override
  String purchaseErrorInsufficientPermissions(String accountName) {
    return '你无法使用你的 $accountName 订阅方案。请检查你的付款信息后重试。';
  }

  @override
  String purchaseErrorPaymentPending(String accountName, String storeName) {
    return '支付已中断。请使用当前登录的$accountName检查$storeName。';
  }

  @override
  String purchaseErrorUserInfoFailed(String details) {
    return '获取用户信息失败。请稍后再试。如果问题仍然存在，请前往“设置”>“反馈”联系我们。详情：$details';
  }

  @override
  String purchaseErrorConfiguration(String details) {
    return '获取购买信息失败。请稍等后重试。如果问题仍然存在，请在“设置”>“咨询”中联系我们。详情：$details';
  }

  @override
  String purchaseErrorUpdateRequired(String code, String details) {
    return '发生未知错误。请更新到最新版本后重试。如果问题仍然存在，请通过“设置”>“联系我们”与我们联系。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorEmptySubscriberAttributes(String details) {
    return '发生未知错误。无法提前获取购买信息。详情：$details';
  }

  @override
  String purchaseErrorCustomerInfo(String code, String details) {
    return '获取客户信息失败。请稍后再试。如果问题仍然存在，请在“设置”>“咨询”中联系我们。详情：代码：$code $details';
  }

  @override
  String purchaseErrorSystemInfo(String code, String details) {
    return '您的设备设置有问题。请检查后重试。如果问题仍然存在，请通过“设置”>“咨询”联系我们。代码：$code 详细信息：$details';
  }

  @override
  String purchaseErrorBeginRefundRequest(String code, String details) {
    return '退款流程已开始。请先确认后重试。如果问题仍然存在，请前往“设置”>“咨询”联系我们。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorTimeout(String details) {
    return '请求超时。请检查网络连接后重试。如果问题仍然存在，请通过“设置”>“咨询”联系我们。详情：$details';
  }

  @override
  String purchaseErrorOfflineConnection(String details) {
    return '网络连接不稳定。请检查您的网络连接后重试。如果问题仍然存在，请在“设置”>“咨询”中联系我们。详情：$details';
  }

  @override
  String purchaseErrorFeatureNotAvailable(String code, String details) {
    return '当前配置下无法使用此功能。如果问题仍然存在，请在“设置”>“反馈”中联系我们。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorSignatureVerification(String code, String details) {
    return '签名验证失败。请稍等片刻后重试。如果问题仍然存在，请前往“设置”>“咨询”联系我们。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorFeatureNotSupported(String code, String details) {
    return '此功能不支持您的设备。请更新到最新版本后再试。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorInvalidWebPurchaseToken(String code, String details) {
    return '购买令牌无效。请重试。如果问题仍然存在，请通过“设置”>“咨询”联系我们。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorBelongsToOtherUser(String code, String details) {
    return '此购买属于其他用户。请检查你的账号。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorExpiredWebPurchaseToken(String code, String details) {
    return '购买令牌已过期。请重试。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorTestStoreSimulated(String code, String details) {
    return '测试购买时发生错误。代码：$code 详细信息：$details';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => '购物清单';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '关闭';

  @override
  String get commonDone => '完成';

  @override
  String get commonOk => '确定';

  @override
  String get commonDelete => '删除';

  @override
  String get commonAdd => '添加';

  @override
  String get commonRetry => '重试';

  @override
  String get commonUndo => '撤销';

  @override
  String get commonUpgrade => '升级';

  @override
  String get commonSettings => '设置';

  @override
  String get commonCategory => '分类';

  @override
  String get commonUncategorized => '未分类';

  @override
  String get commonGroup => '群组';

  @override
  String get commonCamera => '相机';

  @override
  String get commonPhotoLibrary => '照片图库';

  @override
  String get commonErrorOccurred => '发生错误';

  @override
  String get errorUnknownTitle => '发生了未知错误';

  @override
  String get errorUnexpectedTitle => '发生了意外错误';

  @override
  String get errorFaqLink => '查看常见问题';

  @override
  String get authGoogleSignIn => '使用 Google 登录';

  @override
  String get loadingPreparing => '正在准备…';

  @override
  String get accountDeleteButton => '删除账号';

  @override
  String get accountDeleteConfirmTitle => '删除您的账户信息';

  @override
  String get accountDeleteConfirmMessage => '删除你的账号将移除所有用户信息。';

  @override
  String get accountDeleteConfirmButton => '删除';

  @override
  String get accountDeleteReauthTitle => '请重新登录';

  @override
  String get accountDeleteReauthMessage => '要删除您的账户，请重新登录。';

  @override
  String get accountDeleteReauthButton => '请重新登录';

  @override
  String get accountDeleteCompletedTitle => '您的账户已被删除';

  @override
  String get accountDeleteExitAppQuestion => '要退出应用吗？';

  @override
  String get accountDeleteExitAppButton => '退出';

  @override
  String get shoppingListDefaultName => '购物清单';

  @override
  String get shoppingListSettingTooltip => '清单设置';

  @override
  String get shoppingListEmptyTitle => '还没有购物清单';

  @override
  String get shoppingListEmptyMessage => '创建新的购物清单';

  @override
  String get shoppingListEmptyCreateButton => '创建购物清单';

  @override
  String get shoppingListLoadErrorTitle => '列表加载失败';

  @override
  String get shoppingListPickerTitle => '切换清单';

  @override
  String get shoppingListPickerAddList => '添加新清单';

  @override
  String get shoppingListCreateListTooltip => '添加列表';

  @override
  String get shoppingListCreateTodayList => '添加一个带有当前日期的清单';

  @override
  String get shoppingListDuplicateCurrentList => '复制当前清单';

  @override
  String get shoppingListDuplicateUncheckedOnly => '仅复制未勾选的项目';

  @override
  String get shoppingListDuplicated => '已复制清单';

  @override
  String shoppingListDuplicatedFrom(String name) {
    return '复制自 $name';
  }

  @override
  String get shoppingListDeletedListName => '已删除的清单';

  @override
  String get shoppingListDuplicateSourceDeleted => '原始购物清单已删除';

  @override
  String get shoppingListRetentionBannerMessage => '在免费方案中，清单会在创建 30 天后自动清理';

  @override
  String get shoppingListRetentionBannerDetail => '详情';

  @override
  String get shoppingListSpotlightTitle => '你可以在这里添加新的购物清单';

  @override
  String get shoppingListSpotlightMessage => '为每个日期创建一个清单，或复制你现在使用的清单。';

  @override
  String get shoppingListSpotlightDismiss => '轻触关闭';

  @override
  String get shoppingListAiProcessingImage => '正在从照片中提取建议…';

  @override
  String get shoppingListAiProcessingUrl => '正在从网址提取建议…';

  @override
  String get shoppingListAiProcessingCategorize => '正在按类别整理……';

  @override
  String shoppingListAiLimitUpsell(int limit) {
    return '。升级到高级版后，每月可使用 $limit 次';
  }

  @override
  String shoppingListAiCategorizeButton(int count) {
    return '自动分类（$count 项）';
  }

  @override
  String shoppingListAiCategorizeLimitReached(int limit) {
    return '已达到自动分类的月度上限（$limit次）';
  }

  @override
  String shoppingListAiCategorizeRegistered(int count) {
    return '已将 $count 个项目归类';
  }

  @override
  String get shoppingListAiCategorizeSheetTitle => '自动分类';

  @override
  String get shoppingListAiCategorizeSheetSubtitle => '在保存前查看并调整分类';

  @override
  String get shoppingListAiCategorizeSheetEmpty => '没有可分类的项目';

  @override
  String shoppingListAiCategorizeSheetConfirm(int count) {
    return '注册 $count 项';
  }

  @override
  String get shoppingListCategorySelect => '选择分类';

  @override
  String get shoppingListCategoryChange => '更改分类';

  @override
  String get shoppingListNewCategoryHint => '新分类名称';

  @override
  String get shoppingListAddCategoryLabel => '添加类别';

  @override
  String get shoppingListAiReviewTitle => '提取的建议';

  @override
  String get shoppingListAiReviewSubtitle => '选择要添加的商品';

  @override
  String get shoppingListAiReviewEmpty => '未找到任何建议';

  @override
  String shoppingListAiReviewConfirm(int count) {
    return '添加 $count 个项目';
  }

  @override
  String get shoppingListFabAddFromPhoto => '从照片添加';

  @override
  String get shoppingListFabAddFromUrl => '从网址添加';

  @override
  String get shoppingListFabPasteText => '粘贴文本';

  @override
  String shoppingListImageRecognitionLimitReached(int limit) {
    return '已达到照片识别的每月上限（$limit次）';
  }

  @override
  String shoppingListUrlRecognitionLimitReached(int limit) {
    return 'URL 识别的每月次数已达上限（$limit 次）';
  }

  @override
  String get shoppingListUrlDialogTitle => '从网址生成购物清单';

  @override
  String get shoppingListUrlDialogGenerate => '生成';

  @override
  String get shoppingListUrlRequired => '请输入网址';

  @override
  String get shoppingListUrlInvalid => '请输入有效的 HTTPS URL';

  @override
  String get shoppingListStarterRowLabel => '轻点开始输入';

  @override
  String get shoppingListHintExample1 => '例如：牛奶 1升';

  @override
  String get shoppingListHintExample2 => '例如：鸡蛋，1包';

  @override
  String get shoppingListHintExample3 => '例如：面包';

  @override
  String get shoppingListHintExample4 => '例如：洋葱 x2';

  @override
  String get shoppingListHintExample5 => '例如：番茄';

  @override
  String get shoppingListHintCardTitle => '使用方法';

  @override
  String get shoppingListHintTap => '・点按一行即可直接输入';

  @override
  String get shoppingListHintReturn => '・按回车换到下一行';

  @override
  String get shoppingListHintDelete => '・在空行上按删除键即可移除';

  @override
  String get shoppingListHintFabPrefix => '长按右下角的 ';

  @override
  String get shoppingListHintFabSuffix => '右下角可从照片或网址添加';

  @override
  String get shoppingListItemDetailTooltip => '商品详情';

  @override
  String get shoppingListItemDeleteTooltip => '删除项目';

  @override
  String get shoppingListItemDeleteConfirm => '删除此项目？';

  @override
  String get shoppingListItemDeleted => '已删除该商品';

  @override
  String get shoppingListItemMemoHint => '写个备注……';

  @override
  String get shoppingListNotifyGroup => '通知群组';

  @override
  String get shoppingListNotifyGroupSent => '已通知群组';

  @override
  String get shoppingListNotifyGroupGuideLabel => '关于群组通知';

  @override
  String get shoppingListNotifyGroupGuideMessage =>
      '点按此按钮会向群组中的其他成员发送推送通知，告知他们您已更新购物清单。';

  @override
  String get shoppingListNotifyGroupSend => '发送通知';

  @override
  String get commonCopy => '复制';

  @override
  String get commonShare => '分享';

  @override
  String get settingsProfileSection => '个人资料';

  @override
  String get settingsDisplayNameLabel => '你的显示名称';

  @override
  String get settingsDisplayNameHint => '输入显示名称';

  @override
  String get settingsDisplayNameUpdated => '已更新你的显示名称';

  @override
  String get settingsGroupManagement => '管理群组';

  @override
  String get settingsJoinGroupWithInvitationCode => '使用邀请码加入群组';

  @override
  String get settingsAppearanceSection => '外观';

  @override
  String get settingsNotificationSection => '通知';

  @override
  String get settingsAboutSection => '关于此应用';

  @override
  String get settingsTermsOfService => '服务条款';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsCommercialTransactionAct => '基于《指定商业交易法》的说明';

  @override
  String get settingsInquiry => '联系我们';

  @override
  String get settingsOssLicense => '开源许可证';

  @override
  String get settingsDebugSection => '调试';

  @override
  String get settingsDeveloperOptions => '开发者选项';

  @override
  String get settingsPremiumCardTitlePremium => '高级版会员';

  @override
  String get settingsPremiumCardTitleFree => '升级到高级版';

  @override
  String get settingsPremiumCardSubtitlePremium => '您可使用全部功能';

  @override
  String get settingsPremiumCardSubtitleFree => '五种颜色主题，更多照片/网址扫描等功能';

  @override
  String get settingsPremiumCardStartButton => '开始使用';

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get settingsSignOutConfirmBarrierLabel => '退出登录确认';

  @override
  String get settingsSignOutConfirmTitle => '要退出登录吗？';

  @override
  String get settingsSignOutConfirmMessage => '在您再次登录之前，您将无法从此设备访问您的清单。';

  @override
  String get settingsSignOutConfirmMessageGuest =>
      '您当前以访客身份使用此应用，因此如果退出登录，您将无法再次登录同一账户，并且会永久失去对当前列表和群组的访问权限。';

  @override
  String get settingsSignOutCompletedTitle => '已退出登录';

  @override
  String get settingsSignOutExitAppMessage => '应用将立即退出';

  @override
  String get settingsThemeColorTitle => '主题颜色';

  @override
  String get settingsThemeColorDescription => '从五种传统日式颜色中选择，来更改应用中的强调色。';

  @override
  String get settingsThemeColorChanged => '主题颜色已更改';

  @override
  String settingsThemeColorSwatchLabel(String label) {
    return '$label 主题颜色';
  }

  @override
  String get settingsThemeColorPremiumOnly => '更改主题颜色是高级版功能';

  @override
  String get settingsLocationReminderTitle => '位置提醒';

  @override
  String get settingsLocationReminderSubtitle => '当我靠近商店时提醒我购物清单';

  @override
  String get settingsLocationReminderNotificationPermissionRequired =>
      '允许通知后可使用此功能';

  @override
  String get settingsLocationReminderAlwaysPermissionRequired =>
      '将后台定位权限设置为“始终”以使用此功能';

  @override
  String get settingsLocationReminderPremiumOnly => '位置提醒是高级版功能';

  @override
  String get settingsAccountSection => '账户';

  @override
  String get settingsAccountLinked => '已关联你的账户';

  @override
  String get settingsAccountGuestDescription =>
      '您正在以访客身份使用此应用。关联账号后，即使更换设备或在其他设备上，也能使用相同的清单和群组。';

  @override
  String get settingsAccountLinkWithApple => '使用 Apple 关联账号';

  @override
  String get settingsAccountLinkWithGoogle => '将账号与 Google 关联';

  @override
  String settingsAccountSignedInWith(String providerName) {
    return '已通过 $providerName 登录';
  }

  @override
  String get settingsAccountReSignInBarrierLabel => '重新登录确认';

  @override
  String get settingsAccountAlreadyInUseTitle => '此账号已被其他用户使用';

  @override
  String get settingsAccountReSignInMessage =>
      '要再次使用此账号登录吗？\n如果再次登录，当前访客数据（列表和群组）将不会被保留。';

  @override
  String get settingsAccountReSignInButton => '重新登录';

  @override
  String get listSettingTitle => '购物清单设置';

  @override
  String get listSettingNameSection => '清单名称';

  @override
  String get listSettingShoppingLocationSection => '购物地点';

  @override
  String get listSettingLocationUnset => '未设置';

  @override
  String get listSettingLocationChangeDetail => '更改';

  @override
  String get listSettingCategorySubtitle => '管理自动分类关键词';

  @override
  String get listSettingStoragePeriodSection => '保留期限';

  @override
  String get listSettingStoragePeriodPremium => '高级版：无限制';

  @override
  String get listSettingStoragePeriodFree => '创建后30天';

  @override
  String get listSettingStoragePeriodUpsell => '使用高级版，您可以无限期保存清单';

  @override
  String get listSettingShareSection => '共享';

  @override
  String get listSettingSendInvitationCode => '向群组发送邀请码';

  @override
  String get listSettingGroupSetting => '群组设置';

  @override
  String get listSettingGroupNameRequired => '请先设置群组名称，再邀请他人';

  @override
  String get listSettingListActionsSection => '列表操作';

  @override
  String get listSettingDeleteList => '删除此清单';

  @override
  String get listSettingDeleteConfirmBarrierLabel => '购物清单删除确认';

  @override
  String get listSettingDeleteConfirmTitle => '要删除此清单吗？';

  @override
  String listSettingDeleteConfirmMessage(String name, int count) {
    return '“$name”及其中的 $count 个商品将被删除。此操作无法撤销。';
  }

  @override
  String get listSettingInvitationCodeTitle => '邀请码';

  @override
  String get listSettingInvitationExpired => '已过期';

  @override
  String listSettingInvitationRemaining(int days, int hours) {
    return '有效期 7 天 ・ 还剩 $days 天 $hours 小时';
  }

  @override
  String get listSettingInvitationCodeCopied => '已复制邀请码';

  @override
  String listSettingInvitationShareText(String code) {
    return '购物清单邀请码：$code';
  }

  @override
  String get listSettingSelectShoppingLocationTitle => '选择购物地点';

  @override
  String get listSettingLocationNone => '无';

  @override
  String get listSettingLocationSelected => '已选择';

  @override
  String get commonDefault => '默认';

  @override
  String get commonUnnamed => '未命名';

  @override
  String get commonCreating => '创建中…';

  @override
  String get groupNameLabel => '群组名称';

  @override
  String get groupNameHint => '输入群组名称';

  @override
  String get groupCategoryLocationOrderLabel => '按购物地点排序';

  @override
  String get groupCategoryLocationOrderPremiumOnly => '按购物地点重新排序类别是高级版功能';

  @override
  String groupCategoryKeywordCount(int count) {
    return '关键词：$count';
  }

  @override
  String groupCategoryDeleteConfirmTitle(String name) {
    return '要删除“$name”吗？';
  }

  @override
  String get groupCategoryDeleteConfirmMessage => '为此分类设置的关键词也会被删除';

  @override
  String get groupCategoryEmptyTitle => '自动整理你的购物分类';

  @override
  String get groupCategoryEmptyUseCaseAutoGroup =>
      '将番茄和洋葱归入“蔬菜”后，它们会自动分组到清单的蔬菜区';

  @override
  String get groupCategoryEmptyUseCaseLocationOrder =>
      '您可以为每个商店调整分类顺序，这样就能按货架顺序购物。';

  @override
  String get groupCategoryEditTitle => '编辑分类';

  @override
  String get groupCategoryEditNotFound => '未找到分类';

  @override
  String get groupCategoryEditNameLabel => '分类名称';

  @override
  String get groupCategoryEditNameHint => '输入类别名称';

  @override
  String get groupCategoryEditColorLabel => '分类颜色';

  @override
  String get groupCategoryEditIconLabel => '分类图标';

  @override
  String get groupCategoryEditKeywordsLabel => '关键词';

  @override
  String get groupCategoryEditAddKeyword => '添加关键词';

  @override
  String get groupCategoryEditKeywordsEmpty => '还没有关键词';

  @override
  String get groupCategoryEditKeywordHint => '输入关键字';

  @override
  String get groupCategoryEditMatchingLabel => '匹配方式';

  @override
  String get groupCategoryEditMatchingExact => '完全匹配';

  @override
  String get groupCategoryEditMatchingPartial => '部分匹配';

  @override
  String get groupCategoryEditMatchingRegex => '正则表达式';

  @override
  String get groupCreateTitle => '创建群组';

  @override
  String get groupCreateIconLabel => '图标';

  @override
  String get groupCreateSubmit => '创建';

  @override
  String get groupCreateIconHome => '家';

  @override
  String get groupCreateIconCart => '购物车';

  @override
  String get groupCreateIconFork => '食物';

  @override
  String get groupCreateIconCookie => '零食';

  @override
  String get groupCreateIconPets => '宠物';

  @override
  String get groupCreateIconBag => '包';

  @override
  String get groupCreateInvitationDialogTitle => '邀请成员';

  @override
  String get groupCreateInvitationDialogMessage => '将邀请码分享给家人';

  @override
  String get groupInvitationTitle => '使用邀请码加入';

  @override
  String get groupInvitationHeading => '输入邀请码';

  @override
  String get groupInvitationDescription => '输入群组成员分享给您的 8 位验证码';

  @override
  String get groupInvitationJoining => '加入中…';

  @override
  String get groupInvitationJoin => '加入';

  @override
  String get groupInvitationVerifyingTitle => '正在检查邀请码';

  @override
  String get groupInvitationVerifyingMessage => '服务器正在处理你加入群组的请求。';

  @override
  String get groupJoinHeading => '开始吧';

  @override
  String get groupJoinDescription =>
      '你收到家人或伴侣发来的邀请码了吗？\n使用邀请码加入后，你们就可以一起使用同一份购物清单。';

  @override
  String get groupJoinCreateSolo => '创建自己的清单';

  @override
  String get groupListEmpty => '你还不属于任何群组';

  @override
  String groupListMemberCount(int count) {
    return '$count 位成员';
  }

  @override
  String get groupListFreeLimitBanner => '免费版可额外添加一个群组';

  @override
  String get groupListFreeLimitAction => '解锁';

  @override
  String get groupSettingMembersSection => '成员';

  @override
  String get groupSettingMemberOwner => '群主';

  @override
  String get groupSettingMemberSelf => '你';

  @override
  String get groupSettingMemberFallbackName => '成员';

  @override
  String get groupSettingShoppingLocationSubtitle => '添加并编辑商店';

  @override
  String get groupSettingInvitationSection => '群组邀请';

  @override
  String get groupSettingCreatingInvitation => '正在生成邀请码…';

  @override
  String get groupSettingCreateInvitation => '生成邀请码';

  @override
  String groupSettingRemoveMemberConfirmTitle(String name) {
    return '要将$name从群组中移除吗？';
  }

  @override
  String get groupSettingRemoveMemberConfirmMessage => '被移除的成员将无法再访问此群组';

  @override
  String groupSettingMemberRemoved(String name) {
    return '已移除$name';
  }

  @override
  String get groupSettingInvitationCodeMessage => '分享下面的代码';

  @override
  String get groupSettingInvitationExpiry => '有效期 7 天';

  @override
  String get commonSave => '保存';

  @override
  String get authHeroTitle => '家人的购物\n尽在一个清单';

  @override
  String get authHeroDescription => '登录后，你的列表会在各设备间保持同步。无广告，无新闻邮件。';

  @override
  String get authStartWithoutSignIn => '无需登录即可开始';

  @override
  String get authLinkAccountLaterNote => '你可以稍后在设置页面关联账号';

  @override
  String authAgreementNote(String terms, String privacy) {
    return '继续使用即表示你同意$terms和$privacy。';
  }

  @override
  String get inquiryDescription =>
      '我们会阅读您发送的所有内容，并用它来改进应用。如果您希望我们回复，请附上您的电子邮件地址。';

  @override
  String get inquiryEmailLabel => '电子邮箱地址';

  @override
  String get inquiryEmailRequired => '请输入您的电子邮箱地址';

  @override
  String get inquiryEmailInvalid => '电子邮件地址格式不正确';

  @override
  String get inquiryCategoryLabel => '咨询类型';

  @override
  String get inquiryCategoryRequired => '请选择您的咨询类型';

  @override
  String get inquiryContentLabel => '您的留言';

  @override
  String get inquiryContentRequired => '请输入您的留言';

  @override
  String get inquiryContentHint => '告诉我们您遇到了什么问题，或者希望看到什么功能';

  @override
  String get inquirySubmitting => '发送中…';

  @override
  String get inquirySubmit => '发送';

  @override
  String get inquirySubmitted => '您的咨询已发送';

  @override
  String get notificationPermissionBarrierLabel => '推送通知权限';

  @override
  String get notificationPermissionTitle => '开启推送通知';

  @override
  String get notificationPermissionMessage =>
      '当群组中的成员更新购物清单并通知你时，你会立即收到推送通知。请在接下来弹出的确认中允许通知。';

  @override
  String get notificationPermissionLater => '稍后';

  @override
  String get notificationPermissionAllow => '允许通知';

  @override
  String get onboardingSlide1Title => '全家一起创建的\n购物清单';

  @override
  String get onboardingSlide1Body =>
      '有人把在家想到的东西加进来，另一个人在商店把它勾掉。把所有“你能顺手带一下吗？”都放到这张清单上。';

  @override
  String get onboardingSlide2Title => '同时编辑同一个清单';

  @override
  String get onboardingSlide2Body =>
      '使用邀请码邀请你的家人、伴侣或室友，大家都能编辑同一份清单。重要的不是谁添加的，而是不要漏掉任何东西。';

  @override
  String get onboardingSlide3Title => '当您靠近商店时\n温馨提醒';

  @override
  String get onboardingSlide3Body =>
      '当您靠近已登记的商店时，我们会轻轻提醒您查看购物清单。只在您需要时发送通知，绝不打扰。';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingStart => '开始使用';

  @override
  String get onboardingNext => '下一步';

  @override
  String get paywallHeroTitle => '升级到高级版';

  @override
  String get paywallHeroDescription => '解锁所有功能，与全家人一起畅享这款应用。';

  @override
  String get paywallFeatureLocationOrder => '每个商店的分类顺序';

  @override
  String get paywallFeaturePhotoExtraction => '从照片中提取物品（每月 50 次）';

  @override
  String get paywallFeatureUrlExtraction => '从网址中提取项目（每月 50 次）';

  @override
  String get paywallFeatureThemeColors => '五种主题颜色';

  @override
  String get paywallFeatureUnlimitedRetention => '无限期保留清单';

  @override
  String get paywallFeatureReceipt => '将收据保存到清单';

  @override
  String get paywallSubscriptionNote => '可随时取消 ・ 自动续订可在续订前 24 小时内取消';

  @override
  String get paywallPrivacyLink => '隐私';

  @override
  String get paywallRestore => '恢复购买';

  @override
  String get paywallRestored => '已恢复你的购买项目';

  @override
  String get paywallNoPlans => '目前没有可用的套餐';

  @override
  String get paywallRecommendedBadge => '推荐';

  @override
  String get paywallPurchaseCompleted => '感谢您的购买';

  @override
  String get paywallPurchaseButton => '购买';

  @override
  String get receiptAdd => '添加收据';

  @override
  String get receiptEdit => '编辑收据';

  @override
  String get receiptSheetTitle => '收据';

  @override
  String get receiptTakePhoto => '拍照';

  @override
  String get receiptChooseFromLibrary => '从照片图库中选择';

  @override
  String get receiptAmountLabel => '金额';

  @override
  String get receiptMemoLabel => '备注';

  @override
  String get receiptMemoHint => '商店名称或购买内容等备注';

  @override
  String get receiptCaptureOrSelect => '拍摄或选择收据照片';

  @override
  String get forceUpdateTitle => '请更新应用';

  @override
  String forceUpdateMessage(String storeName) {
    return '我们希望您更新此应用。请从 $storeName 更新到最新版本。';
  }

  @override
  String get shoppingLocationTitle => '购物地点';

  @override
  String get shoppingLocationEmpty => '还没有购物地点';

  @override
  String get shoppingLocationGeoConfigured => '已设置位置';

  @override
  String get shoppingLocationAddTitle => '添加位置';

  @override
  String get shoppingLocationEditTitle => '编辑位置';

  @override
  String get shoppingLocationNameHint => '位置名称';

  @override
  String get shoppingLocationNameHintWithExample => '地点名称（例如：超市）';

  @override
  String get shoppingLocationPositionSet => '位置已设置';

  @override
  String get shoppingLocationSetOnMap => '在地图上设置位置';

  @override
  String shoppingLocationDeleteConfirmTitle(String name) {
    return '删除“$name”？';
  }

  @override
  String get shoppingLocationDeleteConfirmMessage => '删除此位置不会影响已设置该位置的购物清单';

  @override
  String get shoppingLocationPickerTitle => '在地图上选择位置';

  @override
  String get shoppingLocationPickerConfirm => '使用此位置';

  @override
  String get settingsThemeColorShu => '朱红';

  @override
  String get settingsThemeColorMatcha => '抹茶';

  @override
  String get settingsThemeColorAi => '靛蓝';

  @override
  String get settingsThemeColorSumi => '墨色';

  @override
  String get settingsThemeColorKuchiba => '朽叶';

  @override
  String get inquiryCategoryBugReport => '问题反馈';

  @override
  String get inquiryCategoryHowToUse => '使用方法';

  @override
  String get inquiryCategoryRequest => '功能建议';

  @override
  String get inquiryCategoryOther => '其他';

  @override
  String shoppingListLimitExceeded(int limit) {
    return '免费方案下，每个群组最多可创建 $limit 个清单。升级到高级版即可无限创建清单。';
  }

  @override
  String get platformGoogleAccountName => 'Google 帐号';

  @override
  String get purchaseNotActivated => '您的购买尚未生效。请稍后再试。';

  @override
  String get errorTitleServerError => '发生服务器错误';

  @override
  String get errorTitleSignInRequired => '需要登录';

  @override
  String get errorTitlePermissionDenied => '你没有权限执行此操作';

  @override
  String get errorTitleProviderAlreadyLinked => '此登录方式已关联';

  @override
  String get errorTitleCredentialAlreadyInUse => '此账号已被其他用户使用';

  @override
  String get errorTitleEmailAlreadyInUse => '此电子邮件地址已被其他用户使用';

  @override
  String purchaseErrorUnknown(String details) {
    return '发生未知错误。请稍后再试。如果问题仍然存在，请通过“设置”>“反馈”联系我们。详情：$details';
  }

  @override
  String purchaseErrorStoreProblem(String storeName) {
    return '$storeName 发生了错误。请稍后再试。';
  }

  @override
  String get purchaseErrorNotAllowed => '此设备不允许购买。';

  @override
  String get purchaseErrorInvalidPayment => '付款失败。请确认您的付款方式有效后重试。';

  @override
  String get purchaseErrorProductNotAvailable => '所选方案当前未在售。请重启应用后再试。';

  @override
  String get purchaseErrorAlreadyPurchased =>
      '您已经购买过方案。要在此设备上恢复购买，请点按“已购买？点此恢复”来恢复您的购买信息。';

  @override
  String purchaseErrorReceiptAlreadyInUse(String accountName) {
    return '已购买，或购买信息已被其他用户使用。请检查你的$accountName。';
  }

  @override
  String get purchaseErrorInvalidReceipt => '购买信息无效。请检查您的购买信息。';

  @override
  String purchaseErrorMissingReceipt(String accountName) {
    return '没有购买者信息。请使用 $accountName 登录设备后重试。';
  }

  @override
  String get purchaseErrorNetwork => '网络连接不稳定。请检查连接后重试。';

  @override
  String purchaseErrorPurchaseFailed(String details) {
    return '购买失败。请稍后再试。如果问题仍然存在，请前往“设置”>“反馈”联系我们。详情：$details';
  }

  @override
  String purchaseErrorUnavailable(String details) {
    return '当前无法购买。请稍后再试。如果问题仍然存在，请前往“设置”>“咨询”联系我们。详情：$details';
  }

  @override
  String purchaseErrorReceiptInUseByOther(String accountName) {
    return '购买信息已被其他用户使用。请检查您在此设备上登录的$accountName。';
  }

  @override
  String purchaseErrorInvalidAppUserId(String details) {
    return '我们无法验证您的用户身份。请重新启动应用后再试。详情：$details';
  }

  @override
  String get purchaseErrorOperationInProgress => '已有另一笔购买正在进行中。请稍等片刻后再试。';

  @override
  String purchaseErrorIneligible(String details) {
    return '您的账号购买失败。请稍后再试。如果问题仍然存在，请在“设置”>“咨询”中联系我们。详情：$details';
  }

  @override
  String purchaseErrorInsufficientPermissions(String accountName) {
    return '你无法使用你的 $accountName 订阅方案。请检查你的付款信息后重试。';
  }

  @override
  String purchaseErrorPaymentPending(String accountName, String storeName) {
    return '支付已中断。请使用当前登录的$accountName检查$storeName。';
  }

  @override
  String purchaseErrorUserInfoFailed(String details) {
    return '获取用户信息失败。请稍后再试。如果问题仍然存在，请前往“设置”>“反馈”联系我们。详情：$details';
  }

  @override
  String purchaseErrorConfiguration(String details) {
    return '获取购买信息失败。请稍等后重试。如果问题仍然存在，请在“设置”>“咨询”中联系我们。详情：$details';
  }

  @override
  String purchaseErrorUpdateRequired(String code, String details) {
    return '发生未知错误。请更新到最新版本后重试。如果问题仍然存在，请通过“设置”>“联系我们”与我们联系。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorEmptySubscriberAttributes(String details) {
    return '发生未知错误。无法提前获取购买信息。详情：$details';
  }

  @override
  String purchaseErrorCustomerInfo(String code, String details) {
    return '获取客户信息失败。请稍后再试。如果问题仍然存在，请在“设置”>“咨询”中联系我们。详情：代码：$code $details';
  }

  @override
  String purchaseErrorSystemInfo(String code, String details) {
    return '您的设备设置有问题。请检查后重试。如果问题仍然存在，请通过“设置”>“咨询”联系我们。代码：$code 详细信息：$details';
  }

  @override
  String purchaseErrorBeginRefundRequest(String code, String details) {
    return '退款流程已开始。请先确认后重试。如果问题仍然存在，请前往“设置”>“咨询”联系我们。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorTimeout(String details) {
    return '请求超时。请检查网络连接后重试。如果问题仍然存在，请通过“设置”>“咨询”联系我们。详情：$details';
  }

  @override
  String purchaseErrorOfflineConnection(String details) {
    return '网络连接不稳定。请检查您的网络连接后重试。如果问题仍然存在，请在“设置”>“咨询”中联系我们。详情：$details';
  }

  @override
  String purchaseErrorFeatureNotAvailable(String code, String details) {
    return '当前配置下无法使用此功能。如果问题仍然存在，请在“设置”>“反馈”中联系我们。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorSignatureVerification(String code, String details) {
    return '签名验证失败。请稍等片刻后重试。如果问题仍然存在，请前往“设置”>“咨询”联系我们。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorFeatureNotSupported(String code, String details) {
    return '此功能不支持您的设备。请更新到最新版本后再试。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorInvalidWebPurchaseToken(String code, String details) {
    return '购买令牌无效。请重试。如果问题仍然存在，请通过“设置”>“咨询”联系我们。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorBelongsToOtherUser(String code, String details) {
    return '此购买属于其他用户。请检查你的账号。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorExpiredWebPurchaseToken(String code, String details) {
    return '购买令牌已过期。请重试。代码：$code 详情：$details';
  }

  @override
  String purchaseErrorTestStoreSimulated(String code, String details) {
    return '测试购买时发生错误。代码：$code 详细信息：$details';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '買物清單';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '關閉';

  @override
  String get commonDone => '完成';

  @override
  String get commonOk => '確定';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonAdd => '新增';

  @override
  String get commonRetry => '重試';

  @override
  String get commonUndo => '復原';

  @override
  String get commonUpgrade => '升級';

  @override
  String get commonSettings => '設定';

  @override
  String get commonCategory => '分類';

  @override
  String get commonUncategorized => '未分類';

  @override
  String get commonGroup => '群組';

  @override
  String get commonCamera => '相機';

  @override
  String get commonPhotoLibrary => '照片圖庫';

  @override
  String get commonErrorOccurred => '發生錯誤';

  @override
  String get errorUnknownTitle => '發生未知錯誤';

  @override
  String get errorUnexpectedTitle => '發生了未預期的錯誤';

  @override
  String get errorFaqLink => '查看常見問題';

  @override
  String get authGoogleSignIn => '使用 Google 登入';

  @override
  String get loadingPreparing => '正在準備…';

  @override
  String get accountDeleteButton => '刪除帳號';

  @override
  String get accountDeleteConfirmTitle => '刪除您的帳戶資訊';

  @override
  String get accountDeleteConfirmMessage => '刪除你的帳號將移除所有使用者資訊。';

  @override
  String get accountDeleteConfirmButton => '刪除';

  @override
  String get accountDeleteReauthTitle => '請重新登入';

  @override
  String get accountDeleteReauthMessage => '要刪除您的帳戶，請重新登入。';

  @override
  String get accountDeleteReauthButton => '請重新登入';

  @override
  String get accountDeleteCompletedTitle => '您的帳戶已刪除';

  @override
  String get accountDeleteExitAppQuestion => '要結束應用程式嗎？';

  @override
  String get accountDeleteExitAppButton => '退出';

  @override
  String get shoppingListDefaultName => '購物清單';

  @override
  String get shoppingListSettingTooltip => '清單設定';

  @override
  String get shoppingListEmptyTitle => '還沒有購物清單';

  @override
  String get shoppingListEmptyMessage => '建立新的購物清單';

  @override
  String get shoppingListEmptyCreateButton => '建立購物清單';

  @override
  String get shoppingListLoadErrorTitle => '列表載入失敗';

  @override
  String get shoppingListPickerTitle => '切換清單';

  @override
  String get shoppingListPickerAddList => '新增清單';

  @override
  String get shoppingListCreateListTooltip => '新增清單';

  @override
  String get shoppingListCreateTodayList => '新增含目前日期的清單';

  @override
  String get shoppingListDuplicateCurrentList => '複製目前清單';

  @override
  String get shoppingListDuplicateUncheckedOnly => '僅複製未勾選的項目';

  @override
  String get shoppingListDuplicated => '已複製清單';

  @override
  String shoppingListDuplicatedFrom(String name) {
    return '複製自 $name';
  }

  @override
  String get shoppingListDeletedListName => '已刪除的清單';

  @override
  String get shoppingListDuplicateSourceDeleted => '原始購物清單已刪除';

  @override
  String get shoppingListRetentionBannerMessage => '在免費方案中，清單會在建立 30 天後自動清理';

  @override
  String get shoppingListRetentionBannerDetail => '詳細資料';

  @override
  String get shoppingListSpotlightTitle => '你可以在這裡新增購物清單';

  @override
  String get shoppingListSpotlightMessage => '為每個日期建立一份清單，或複製你現在使用的清單。';

  @override
  String get shoppingListSpotlightDismiss => '輕觸關閉';

  @override
  String get shoppingListAiProcessingImage => '正在從照片中提取建議…';

  @override
  String get shoppingListAiProcessingUrl => '正在從網址擷取建議…';

  @override
  String get shoppingListAiProcessingCategorize => '正在依類別整理……';

  @override
  String shoppingListAiLimitUpsell(int limit) {
    return '。升級到進階版後，每月可使用 $limit 次';
  }

  @override
  String shoppingListAiCategorizeButton(int count) {
    return '自動分類（$count 項）';
  }

  @override
  String shoppingListAiCategorizeLimitReached(int limit) {
    return '已達到自動分類的每月上限（$limit次）';
  }

  @override
  String shoppingListAiCategorizeRegistered(int count) {
    return '已將 $count 個項目分類';
  }

  @override
  String get shoppingListAiCategorizeSheetTitle => '自動分類';

  @override
  String get shoppingListAiCategorizeSheetSubtitle => '在儲存前查看並調整分類';

  @override
  String get shoppingListAiCategorizeSheetEmpty => '沒有可分類的項目';

  @override
  String shoppingListAiCategorizeSheetConfirm(int count) {
    return '註冊 $count 項';
  }

  @override
  String get shoppingListCategorySelect => '選擇分類';

  @override
  String get shoppingListCategoryChange => '更改分類';

  @override
  String get shoppingListNewCategoryHint => '新分類名稱';

  @override
  String get shoppingListAddCategoryLabel => '新增類別';

  @override
  String get shoppingListAiReviewTitle => '擷取的建議';

  @override
  String get shoppingListAiReviewSubtitle => '選擇要加入的商品';

  @override
  String get shoppingListAiReviewEmpty => '找不到任何建議';

  @override
  String shoppingListAiReviewConfirm(int count) {
    return '新增 $count 個項目';
  }

  @override
  String get shoppingListFabAddFromPhoto => '從照片新增';

  @override
  String get shoppingListFabAddFromUrl => '從網址加入';

  @override
  String get shoppingListFabPasteText => '貼上文字';

  @override
  String shoppingListImageRecognitionLimitReached(int limit) {
    return '已達到照片辨識的每月上限（$limit次）';
  }

  @override
  String shoppingListUrlRecognitionLimitReached(int limit) {
    return 'URL 辨識的每月次數已達上限（$limit 次）';
  }

  @override
  String get shoppingListUrlDialogTitle => '從網址產生購物清單';

  @override
  String get shoppingListUrlDialogGenerate => '產生';

  @override
  String get shoppingListUrlRequired => '請輸入網址';

  @override
  String get shoppingListUrlInvalid => '請輸入有效的 HTTPS URL';

  @override
  String get shoppingListStarterRowLabel => '點一下開始輸入';

  @override
  String get shoppingListHintExample1 => '例如：牛奶 1公升';

  @override
  String get shoppingListHintExample2 => '例如：雞蛋，1包';

  @override
  String get shoppingListHintExample3 => '例如：麵包';

  @override
  String get shoppingListHintExample4 => '例如：洋蔥 x2';

  @override
  String get shoppingListHintExample5 => '例如：番茄';

  @override
  String get shoppingListHintCardTitle => '使用方法';

  @override
  String get shoppingListHintTap => '・點按一行即可直接輸入';

  @override
  String get shoppingListHintReturn => '・按 Return 鍵移到下一行';

  @override
  String get shoppingListHintDelete => '・在空白行按刪除鍵即可移除';

  @override
  String get shoppingListHintFabPrefix => '長按右下角的 ';

  @override
  String get shoppingListHintFabSuffix => '右下角可從照片或網址新增';

  @override
  String get shoppingListItemDetailTooltip => '項目詳情';

  @override
  String get shoppingListItemDeleteTooltip => '刪除項目';

  @override
  String get shoppingListItemDeleteConfirm => '刪除此項目？';

  @override
  String get shoppingListItemDeleted => '已刪除該項目';

  @override
  String get shoppingListItemMemoHint => '寫個備註……';

  @override
  String get shoppingListNotifyGroup => '通知群組';

  @override
  String get shoppingListNotifyGroupSent => '已通知群組';

  @override
  String get shoppingListNotifyGroupGuideLabel => '關於群組通知';

  @override
  String get shoppingListNotifyGroupGuideMessage =>
      '點按此按鈕會向群組中的其他成員傳送推播通知，告知他們您已更新購物清單。';

  @override
  String get shoppingListNotifyGroupSend => '傳送通知';

  @override
  String get commonCopy => '複製';

  @override
  String get commonShare => '分享';

  @override
  String get settingsProfileSection => '個人資料';

  @override
  String get settingsDisplayNameLabel => '您的顯示名稱';

  @override
  String get settingsDisplayNameHint => '輸入顯示名稱';

  @override
  String get settingsDisplayNameUpdated => '已更新您的顯示名稱';

  @override
  String get settingsGroupManagement => '管理群組';

  @override
  String get settingsJoinGroupWithInvitationCode => '使用邀請碼加入群組';

  @override
  String get settingsAppearanceSection => '外觀';

  @override
  String get settingsNotificationSection => '通知';

  @override
  String get settingsAboutSection => '關於此應用程式';

  @override
  String get settingsTermsOfService => '服務條款';

  @override
  String get settingsPrivacyPolicy => '隱私政策';

  @override
  String get settingsCommercialTransactionAct => '根據《特定商業交易法》的說明';

  @override
  String get settingsInquiry => '聯絡我們';

  @override
  String get settingsOssLicense => '開源授權';

  @override
  String get settingsDebugSection => '除錯';

  @override
  String get settingsDeveloperOptions => '開發者選項';

  @override
  String get settingsPremiumCardTitlePremium => '進階版會員';

  @override
  String get settingsPremiumCardTitleFree => '升級到進階版';

  @override
  String get settingsPremiumCardSubtitlePremium => '您可使用所有功能';

  @override
  String get settingsPremiumCardSubtitleFree => '五種顏色主題、更多照片／網址掃描等功能';

  @override
  String get settingsPremiumCardStartButton => '開始使用';

  @override
  String get settingsSignOut => '登出';

  @override
  String get settingsSignOutConfirmBarrierLabel => '登出確認';

  @override
  String get settingsSignOutConfirmTitle => '要登出嗎？';

  @override
  String get settingsSignOutConfirmMessage => '在您再次登入之前，您將無法從此裝置存取您的清單。';

  @override
  String get settingsSignOutConfirmMessageGuest =>
      '您目前以訪客身分使用此應用，因此如果登出，將無法再次登入同一帳號，且會永久失去對目前清單和群組的存取權限。';

  @override
  String get settingsSignOutCompletedTitle => '已登出';

  @override
  String get settingsSignOutExitAppMessage => '應用程式將立即退出';

  @override
  String get settingsThemeColorTitle => '主題顏色';

  @override
  String get settingsThemeColorDescription => '從五種傳統日式顏色中選擇，以變更應用程式中使用的強調色。';

  @override
  String get settingsThemeColorChanged => '主題顏色已變更';

  @override
  String settingsThemeColorSwatchLabel(String label) {
    return '$label 主題顏色';
  }

  @override
  String get settingsThemeColorPremiumOnly => '變更主題顏色是進階版功能';

  @override
  String get settingsLocationReminderTitle => '位置提醒';

  @override
  String get settingsLocationReminderSubtitle => '當我靠近商店時提醒我購物清單';

  @override
  String get settingsLocationReminderNotificationPermissionRequired =>
      '允許通知後可使用此功能';

  @override
  String get settingsLocationReminderAlwaysPermissionRequired =>
      '將背景位置存取設為「永遠」以使用此功能';

  @override
  String get settingsLocationReminderPremiumOnly => '位置提醒是進階版功能';

  @override
  String get settingsAccountSection => '帳戶';

  @override
  String get settingsAccountLinked => '已連結你的帳戶';

  @override
  String get settingsAccountGuestDescription =>
      '您目前以訪客身分使用此應用程式。若連結帳號，您在更換裝置或於其他裝置上也能使用相同的清單和群組。';

  @override
  String get settingsAccountLinkWithApple => '使用 Apple 連結帳號';

  @override
  String get settingsAccountLinkWithGoogle => '將帳號與 Google 連結';

  @override
  String settingsAccountSignedInWith(String providerName) {
    return '已使用 $providerName 登入';
  }

  @override
  String get settingsAccountReSignInBarrierLabel => '重新登入確認';

  @override
  String get settingsAccountAlreadyInUseTitle => '此帳號已被其他使用者使用';

  @override
  String get settingsAccountReSignInMessage =>
      '要再次使用此帳號登入嗎？\n如果再次登入，目前的訪客資料（清單和群組）將不會被保留。';

  @override
  String get settingsAccountReSignInButton => '重新登入';

  @override
  String get listSettingTitle => '購物清單設定';

  @override
  String get listSettingNameSection => '清單名稱';

  @override
  String get listSettingShoppingLocationSection => '購物地點';

  @override
  String get listSettingLocationUnset => '未設定';

  @override
  String get listSettingLocationChangeDetail => '變更';

  @override
  String get listSettingCategorySubtitle => '管理自動分類關鍵字';

  @override
  String get listSettingStoragePeriodSection => '保留期限';

  @override
  String get listSettingStoragePeriodPremium => '進階版：無限制';

  @override
  String get listSettingStoragePeriodFree => '建立後 30 天';

  @override
  String get listSettingStoragePeriodUpsell => '使用進階版，您可以無限期保存清單';

  @override
  String get listSettingShareSection => '共享';

  @override
  String get listSettingSendInvitationCode => '向群組傳送邀請碼';

  @override
  String get listSettingGroupSetting => '群組設定';

  @override
  String get listSettingGroupNameRequired => '請先設定群組名稱，再邀請他人';

  @override
  String get listSettingListActionsSection => '清單操作';

  @override
  String get listSettingDeleteList => '刪除此清單';

  @override
  String get listSettingDeleteConfirmBarrierLabel => '購物清單刪除確認';

  @override
  String get listSettingDeleteConfirmTitle => '要刪除這份清單嗎？';

  @override
  String listSettingDeleteConfirmMessage(String name, int count) {
    return '「$name」和其中的 $count 個商品將被刪除。此操作無法復原。';
  }

  @override
  String get listSettingInvitationCodeTitle => '邀請碼';

  @override
  String get listSettingInvitationExpired => '已過期';

  @override
  String listSettingInvitationRemaining(int days, int hours) {
    return '有效期 7 天 ・ 剩餘 $days 天 $hours 小時';
  }

  @override
  String get listSettingInvitationCodeCopied => '已複製邀請碼';

  @override
  String listSettingInvitationShareText(String code) {
    return '購物清單邀請碼：$code';
  }

  @override
  String get listSettingSelectShoppingLocationTitle => '選擇購物地點';

  @override
  String get listSettingLocationNone => '無';

  @override
  String get listSettingLocationSelected => '已選取';

  @override
  String get commonDefault => '預設';

  @override
  String get commonUnnamed => '未命名';

  @override
  String get commonCreating => '建立中…';

  @override
  String get groupNameLabel => '群組名稱';

  @override
  String get groupNameHint => '輸入群組名稱';

  @override
  String get groupCategoryLocationOrderLabel => '依購物地點排序';

  @override
  String get groupCategoryLocationOrderPremiumOnly => '依購物地點重新排序分類是進階版功能';

  @override
  String groupCategoryKeywordCount(int count) {
    return '關鍵字：$count';
  }

  @override
  String groupCategoryDeleteConfirmTitle(String name) {
    return '要刪除「$name」嗎？';
  }

  @override
  String get groupCategoryDeleteConfirmMessage => '為此分類設定的關鍵字也會被刪除';

  @override
  String get groupCategoryEmptyTitle => '自動整理你的購物分類';

  @override
  String get groupCategoryEmptyUseCaseAutoGroup =>
      '將番茄和洋蔥歸入「蔬菜」後，它們會自動分組到清單的蔬菜區';

  @override
  String get groupCategoryEmptyUseCaseLocationOrder =>
      '您可以為每間商店調整分類順序，這樣就能依照走道順序購物。';

  @override
  String get groupCategoryEditTitle => '編輯分類';

  @override
  String get groupCategoryEditNotFound => '找不到分類';

  @override
  String get groupCategoryEditNameLabel => '分類名稱';

  @override
  String get groupCategoryEditNameHint => '輸入分類名稱';

  @override
  String get groupCategoryEditColorLabel => '分類顏色';

  @override
  String get groupCategoryEditIconLabel => '分類圖示';

  @override
  String get groupCategoryEditKeywordsLabel => '關鍵字';

  @override
  String get groupCategoryEditAddKeyword => '新增關鍵字';

  @override
  String get groupCategoryEditKeywordsEmpty => '還沒有關鍵字';

  @override
  String get groupCategoryEditKeywordHint => '輸入關鍵字';

  @override
  String get groupCategoryEditMatchingLabel => '比對方式';

  @override
  String get groupCategoryEditMatchingExact => '完全符合';

  @override
  String get groupCategoryEditMatchingPartial => '部分符合';

  @override
  String get groupCategoryEditMatchingRegex => '正則表達式';

  @override
  String get groupCreateTitle => '建立群組';

  @override
  String get groupCreateIconLabel => '圖示';

  @override
  String get groupCreateSubmit => '建立';

  @override
  String get groupCreateIconHome => '家';

  @override
  String get groupCreateIconCart => '購物車';

  @override
  String get groupCreateIconFork => '食物';

  @override
  String get groupCreateIconCookie => '零食';

  @override
  String get groupCreateIconPets => '寵物';

  @override
  String get groupCreateIconBag => '包';

  @override
  String get groupCreateInvitationDialogTitle => '邀請成員';

  @override
  String get groupCreateInvitationDialogMessage => '將邀請碼分享給家人';

  @override
  String get groupInvitationTitle => '使用邀請碼加入';

  @override
  String get groupInvitationHeading => '輸入邀請碼';

  @override
  String get groupInvitationDescription => '輸入群組成員分享給您的 8 位驗證碼';

  @override
  String get groupInvitationJoining => '加入中…';

  @override
  String get groupInvitationJoin => '加入';

  @override
  String get groupInvitationVerifyingTitle => '正在檢查邀請碼';

  @override
  String get groupInvitationVerifyingMessage => '伺服器正在處理你加入群組的請求。';

  @override
  String get groupJoinHeading => '開始吧';

  @override
  String get groupJoinDescription =>
      '你有收到家人或伴侶提供的邀請碼嗎？\n使用邀請碼加入後，你們就能一起共用同一份購物清單。';

  @override
  String get groupJoinCreateSolo => '建立自己的清單';

  @override
  String get groupListEmpty => '你尚未加入任何群組';

  @override
  String groupListMemberCount(int count) {
    return '$count 位成員';
  }

  @override
  String get groupListFreeLimitBanner => '免費方案可額外新增一個群組';

  @override
  String get groupListFreeLimitAction => '解鎖';

  @override
  String get groupSettingMembersSection => '成員';

  @override
  String get groupSettingMemberOwner => '群組擁有者';

  @override
  String get groupSettingMemberSelf => '你';

  @override
  String get groupSettingMemberFallbackName => '成員';

  @override
  String get groupSettingShoppingLocationSubtitle => '新增和編輯商店';

  @override
  String get groupSettingInvitationSection => '群組邀請';

  @override
  String get groupSettingCreatingInvitation => '正在產生邀請碼…';

  @override
  String get groupSettingCreateInvitation => '產生邀請碼';

  @override
  String groupSettingRemoveMemberConfirmTitle(String name) {
    return '要將$name從群組中移除嗎？';
  }

  @override
  String get groupSettingRemoveMemberConfirmMessage => '被移除的成員將無法再存取這個群組';

  @override
  String groupSettingMemberRemoved(String name) {
    return '已移除$name';
  }

  @override
  String get groupSettingInvitationCodeMessage => '分享下面的代碼';

  @override
  String get groupSettingInvitationExpiry => '有效期限 7 天';

  @override
  String get commonSave => '儲存';

  @override
  String get authHeroTitle => '家人的購物\n盡在一個清單';

  @override
  String get authHeroDescription => '登入後，你的清單會在各裝置間保持同步。無廣告，無電子報。';

  @override
  String get authStartWithoutSignIn => '無需登入即可開始';

  @override
  String get authLinkAccountLaterNote => '你可以稍後在設定畫面連結帳號';

  @override
  String authAgreementNote(String terms, String privacy) {
    return '繼續使用即表示你同意$terms和$privacy。';
  }

  @override
  String get inquiryDescription =>
      '我們會閱讀您傳送的所有內容，並用來改善應用程式。如果您希望收到回覆，請附上您的電子郵件地址。';

  @override
  String get inquiryEmailLabel => '電子郵件地址';

  @override
  String get inquiryEmailRequired => '請輸入您的電子郵件地址';

  @override
  String get inquiryEmailInvalid => '電子郵件地址格式不正確';

  @override
  String get inquiryCategoryLabel => '詢問類型';

  @override
  String get inquiryCategoryRequired => '請選擇您的詢問類型';

  @override
  String get inquiryContentLabel => '您的訊息';

  @override
  String get inquiryContentRequired => '請輸入您的訊息';

  @override
  String get inquiryContentHint => '告訴我們您遇到了什麼問題，或是希望看到什麼功能';

  @override
  String get inquirySubmitting => '傳送中…';

  @override
  String get inquirySubmit => '送出';

  @override
  String get inquirySubmitted => '您的詢問已送出';

  @override
  String get notificationPermissionBarrierLabel => '推播通知權限';

  @override
  String get notificationPermissionTitle => '開啟推播通知';

  @override
  String get notificationPermissionMessage =>
      '當群組中的成員更新購物清單並通知你時，你會立即收到推播通知。請在接下來出現的確認畫面中允許通知。';

  @override
  String get notificationPermissionLater => '稍後';

  @override
  String get notificationPermissionAllow => '允許通知';

  @override
  String get onboardingSlide1Title => '全家一起建立的\n購物清單';

  @override
  String get onboardingSlide1Body =>
      '有人把在家想到的東西加進來，另一個人在商店把它勾掉。把所有「你能順手帶一下嗎？」都放到這張清單上。';

  @override
  String get onboardingSlide2Title => '同時編輯同一個清單';

  @override
  String get onboardingSlide2Body =>
      '使用邀請碼邀請你的家人、伴侶或室友，大家都能編輯同一份清單。重要的不是誰加的，而是不要漏掉任何東西。';

  @override
  String get onboardingSlide3Title => '當您靠近商店時\n溫馨提醒';

  @override
  String get onboardingSlide3Body =>
      '當您靠近已登記的商店時，我們會輕輕提醒您查看購物清單。只在您需要時發送通知，絕不打擾。';

  @override
  String get onboardingSkip => '略過';

  @override
  String get onboardingStart => '開始使用';

  @override
  String get onboardingNext => '下一步';

  @override
  String get paywallHeroTitle => '升級到進階版';

  @override
  String get paywallHeroDescription => '解鎖所有功能，和全家人一起盡情使用這個 App。';

  @override
  String get paywallFeatureLocationOrder => '每個商店的分類順序';

  @override
  String get paywallFeaturePhotoExtraction => '從照片中提取物品（每月 50 次）';

  @override
  String get paywallFeatureUrlExtraction => '從網址中提取項目（每月 50 次）';

  @override
  String get paywallFeatureThemeColors => '五種主題顏色';

  @override
  String get paywallFeatureUnlimitedRetention => '清單無限期保留';

  @override
  String get paywallFeatureReceipt => '將收據儲存到清單';

  @override
  String get paywallSubscriptionNote => '可隨時取消・自動續訂可在續訂前 24 小時前取消';

  @override
  String get paywallPrivacyLink => '隱私';

  @override
  String get paywallRestore => '恢復購買';

  @override
  String get paywallRestored => '已恢復你的購買項目';

  @override
  String get paywallNoPlans => '目前沒有可用的方案';

  @override
  String get paywallRecommendedBadge => '推薦';

  @override
  String get paywallPurchaseCompleted => '感謝您的購買';

  @override
  String get paywallPurchaseButton => '購買';

  @override
  String get receiptAdd => '新增收據';

  @override
  String get receiptEdit => '編輯收據';

  @override
  String get receiptSheetTitle => '收據';

  @override
  String get receiptTakePhoto => '拍照';

  @override
  String get receiptChooseFromLibrary => '從照片圖庫選擇';

  @override
  String get receiptAmountLabel => '金額';

  @override
  String get receiptMemoLabel => '備註';

  @override
  String get receiptMemoHint => '商店名稱或購買內容等備註';

  @override
  String get receiptCaptureOrSelect => '拍攝或選擇收據照片';

  @override
  String get forceUpdateTitle => '請更新應用程式';

  @override
  String forceUpdateMessage(String storeName) {
    return '我們希望您更新此應用程式。請從 $storeName 更新至最新版本。';
  }

  @override
  String get shoppingLocationTitle => '購物地點';

  @override
  String get shoppingLocationEmpty => '還沒有購物地點';

  @override
  String get shoppingLocationGeoConfigured => '已設定位置';

  @override
  String get shoppingLocationAddTitle => '新增位置';

  @override
  String get shoppingLocationEditTitle => '編輯位置';

  @override
  String get shoppingLocationNameHint => '位置名稱';

  @override
  String get shoppingLocationNameHintWithExample => '地點名稱（例如：超市）';

  @override
  String get shoppingLocationPositionSet => '位置已設定';

  @override
  String get shoppingLocationSetOnMap => '在地圖上設定位置';

  @override
  String shoppingLocationDeleteConfirmTitle(String name) {
    return '刪除「$name」？';
  }

  @override
  String get shoppingLocationDeleteConfirmMessage => '刪除這個位置不會影響已設定此位置的購物清單';

  @override
  String get shoppingLocationPickerTitle => '在地圖上選擇位置';

  @override
  String get shoppingLocationPickerConfirm => '使用此位置';

  @override
  String get settingsThemeColorShu => '朱紅';

  @override
  String get settingsThemeColorMatcha => '抹茶';

  @override
  String get settingsThemeColorAi => '靛藍';

  @override
  String get settingsThemeColorSumi => '墨色';

  @override
  String get settingsThemeColorKuchiba => '朽葉';

  @override
  String get inquiryCategoryBugReport => '問題回報';

  @override
  String get inquiryCategoryHowToUse => '使用方法';

  @override
  String get inquiryCategoryRequest => '功能建議';

  @override
  String get inquiryCategoryOther => '其他';

  @override
  String shoppingListLimitExceeded(int limit) {
    return '免費方案下，每個群組最多可建立 $limit 個清單。升級到進階版即可無限建立清單。';
  }

  @override
  String get platformGoogleAccountName => 'Google 帳戶';

  @override
  String get purchaseNotActivated => '您的購買尚未生效。請稍後再試。';

  @override
  String get errorTitleServerError => '發生伺服器錯誤';

  @override
  String get errorTitleSignInRequired => '需要登入';

  @override
  String get errorTitlePermissionDenied => '你沒有權限執行此操作';

  @override
  String get errorTitleProviderAlreadyLinked => '此登入方式已連結';

  @override
  String get errorTitleCredentialAlreadyInUse => '此帳號已被其他使用者使用';

  @override
  String get errorTitleEmailAlreadyInUse => '此電子郵件地址已被其他使用者使用';

  @override
  String purchaseErrorUnknown(String details) {
    return '發生未知錯誤。請稍後再試。如果問題仍然存在，請從「設定」>「詢問」聯絡我們。詳細資料：$details';
  }

  @override
  String purchaseErrorStoreProblem(String storeName) {
    return '$storeName 發生錯誤。請稍後再試。';
  }

  @override
  String get purchaseErrorNotAllowed => '此裝置不允許購買。';

  @override
  String get purchaseErrorInvalidPayment => '付款失敗。請確認您的付款方式有效後再試一次。';

  @override
  String get purchaseErrorProductNotAvailable => '所選方案目前未在販售。請重新啟動應用程式後再試一次。';

  @override
  String get purchaseErrorAlreadyPurchased =>
      '您已經購買過方案。要在此裝置上還原購買，請點選「已購買？點這裡」來還原您的購買資訊。';

  @override
  String purchaseErrorReceiptAlreadyInUse(String accountName) {
    return '已購買，或購買資訊已被其他使用者使用。請檢查你的$accountName。';
  }

  @override
  String get purchaseErrorInvalidReceipt => '購買資訊無效。請檢查您的購買資訊。';

  @override
  String purchaseErrorMissingReceipt(String accountName) {
    return '沒有購買者資訊。請使用 $accountName 登入您的裝置後再試一次。';
  }

  @override
  String get purchaseErrorNetwork => '網路連線不穩定。請檢查連線後再試一次。';

  @override
  String purchaseErrorPurchaseFailed(String details) {
    return '購買失敗。請稍後再試。如果問題仍然存在，請前往「設定」>「詢問」聯絡我們。詳細資訊：$details';
  }

  @override
  String purchaseErrorUnavailable(String details) {
    return '目前無法購買。請稍後再試。如果問題仍然存在，請從「設定」>「諮詢」聯絡我們。詳情：$details';
  }

  @override
  String purchaseErrorReceiptInUseByOther(String accountName) {
    return '購買資訊已被其他使用者使用。請確認您在此裝置上登入的$accountName。';
  }

  @override
  String purchaseErrorInvalidAppUserId(String details) {
    return '我們無法驗證您的使用者身分。請重新啟動 App 後再試一次。詳細資訊：$details';
  }

  @override
  String get purchaseErrorOperationInProgress => '已有另一筆購買正在進行中。請稍等片刻後再試。';

  @override
  String purchaseErrorIneligible(String details) {
    return '您的帳號購買失敗。請稍後再試。如果問題仍然存在，請從「設定」>「諮詢」與我們聯絡。詳細資訊：$details';
  }

  @override
  String purchaseErrorInsufficientPermissions(String accountName) {
    return '你無法使用你的 $accountName 訂閱方案。請檢查你的付款資訊後再試一次。';
  }

  @override
  String purchaseErrorPaymentPending(String accountName, String storeName) {
    return '付款已中斷。請使用目前登入的$accountName確認$storeName。';
  }

  @override
  String purchaseErrorUserInfoFailed(String details) {
    return '取得使用者資訊失敗。請稍候再試。如果問題仍然存在，請從「設定」>「詢問」與我們聯絡。詳細資料：$details';
  }

  @override
  String purchaseErrorConfiguration(String details) {
    return '取得購買資訊失敗。請稍候再試。如果問題仍然存在，請從「設定」>「聯絡我們」與我們聯絡。詳細資訊：$details';
  }

  @override
  String purchaseErrorUpdateRequired(String code, String details) {
    return '發生未知錯誤。請更新至最新版本後再試一次。如果問題仍然持續，請從「設定」>「詢問」與我們聯絡。代碼：$code 詳情：$details';
  }

  @override
  String purchaseErrorEmptySubscriberAttributes(String details) {
    return '發生未知錯誤。無法提前取得購買資訊。詳情：$details';
  }

  @override
  String purchaseErrorCustomerInfo(String code, String details) {
    return '取得客戶資訊失敗。請稍後再試。如果問題仍然存在，請從「設定」>「聯絡我們」與我們聯絡。詳細資訊：代碼：$code $details';
  }

  @override
  String purchaseErrorSystemInfo(String code, String details) {
    return '您的裝置設定有問題。請檢查後再試一次。如果問題仍然存在，請從「設定」>「詢問」與我們聯絡。代碼：$code 詳細資訊：$details';
  }

  @override
  String purchaseErrorBeginRefundRequest(String code, String details) {
    return '退款流程已開始。請先確認後再試一次。如果問題仍然存在，請從「設定」>「詢問」聯絡我們。代碼：$code 詳細資訊：$details';
  }

  @override
  String purchaseErrorTimeout(String details) {
    return '請求逾時。請檢查網路連線後再試一次。如果問題仍然存在，請從「設定」>「聯絡我們」與我們聯繫。詳細資料：$details';
  }

  @override
  String purchaseErrorOfflineConnection(String details) {
    return '網路連線不佳。請檢查您的網路連線後再試一次。如果問題仍然存在，請從「設定」>「詢問」聯絡我們。詳細資訊：$details';
  }

  @override
  String purchaseErrorFeatureNotAvailable(String code, String details) {
    return '目前設定下無法使用此功能。如果問題持續發生，請從「設定」>「聯絡我們」與我們聯絡。代碼：$code 詳細資訊：$details';
  }

  @override
  String purchaseErrorSignatureVerification(String code, String details) {
    return '簽章驗證失敗。請稍等片刻後再試一次。如果問題仍然存在，請從「設定」>「詢問」與我們聯絡。代碼：$code 詳情：$details';
  }

  @override
  String purchaseErrorFeatureNotSupported(String code, String details) {
    return '此功能不支援您的裝置。請更新到最新版本後再試。代碼：$code 詳細：$details';
  }

  @override
  String purchaseErrorInvalidWebPurchaseToken(String code, String details) {
    return '購買憑證無效。請再試一次。如果問題持續發生，請從「設定」>「詢問」聯絡我們。代碼：$code 詳細：$details';
  }

  @override
  String purchaseErrorBelongsToOtherUser(String code, String details) {
    return '此購買屬於其他使用者。請檢查您的帳號。代碼：$code 詳情：$details';
  }

  @override
  String purchaseErrorExpiredWebPurchaseToken(String code, String details) {
    return '購買憑證已過期。請再試一次。代碼：$code 詳情：$details';
  }

  @override
  String purchaseErrorTestStoreSimulated(String code, String details) {
    return '測試購買時發生錯誤。代碼：$code 詳細資料：$details';
  }
}
