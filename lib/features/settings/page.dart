import 'package:flutter/material.dart';
import 'package:shoppinglist/components/button/inquiry.dart';
import 'package:shoppinglist/features/settings/components/section.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/utils/logger/analytics.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SettingSectionTitle(text: 'アプリについて', children: [
              ListTile(
                  title: const Text(
                    '利用規約',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    analytics.logEvent(name: 'did_select_terms_of_service', parameters: {});
                    launchUrl(Uri.parse('https://bannzai.github.io/shoppinglist/TermsOfService'), mode: LaunchMode.externalApplication);
                  }),
              const _Divider(),
              ListTile(
                title: const Text(
                  'プライバシーポリシー',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  analytics.logEvent(name: 'did_select_privacy_policy', parameters: {});
                  launchUrl(Uri.parse('https://bannzai.github.io/shoppinglist/PrivacyPolicy'), mode: LaunchMode.externalApplication);
                },
              ),
              const _Divider(),
              ListTile(
                  title: const Text(
                    '特定商法取引法に基づく表記',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    analytics.logEvent(name: 'did_select_specified_commercial_transaction_act', parameters: {});
                    launchUrl(Uri.parse('https://bannzai.github.io/shoppinglist/SpecifiedCommercialTransactionAct'),
                        mode: LaunchMode.externalApplication);
                  }),
              const _Divider(),
              ListTile(
                title: const Text('お問い合わせ'),
                onTap: () {
                  inquiry();
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Container(
        height: 1,
        color: AppColors.border,
      ),
    );
  }
}
