import 'package:flutter/material.dart';
import 'package:shoppinglist/components/primitives/app_cell.dart';
import 'package:shoppinglist/l10n/l10n.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';

/// 「アプリについて」セクションに置く OSS ライセンス一覧への導線。
///
/// 一覧の中身は Flutter 標準の `LicenseRegistry` が各パッケージの LICENSE から
/// 収集したものを [showLicensePage] が表示する。依存関係の追加・更新に自動で
/// 追従させるため、アプリ側では固定の一覧やその生成ツールを持たない。
class OssLicenseCell extends StatelessWidget {
  const OssLicenseCell({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCell(
      icon: Icons.copyright_outlined,
      title: context.l10n.settingsOssLicense,
      onTap: () {
        analytics.logEvent(name: 'did_select_oss_licenses', parameters: {});
        // applicationName は指定しない。未指定時は MaterialApp の title
        // （「買い物リスト」）が使われるため、アプリ名の定義箇所を増やさない。
        showLicensePage(context: context);
      },
      detail: null,
      onSwitch: null,
      subtitle: null,
      switchValue: null,
    );
  }
}
