#!/usr/bin/env ruby
# frozen_string_literal: true

# CI 専用: Release ビルド構成を手動署名 (Manual) に切り替える。
#
# ローカルの project.pbxproj は Automatic のまま据え置く設計。CI でチェックアウトした
# 作業コピーに対してのみ本スクリプトを適用することで、ローカル開発の署名設定を壊さない。
#
# 対象は Release 構成かつ配布対象の 2 ターゲットのみ（bundle id で判定）:
#   - com.bannzai.shoppinglist                  (Runner)
#   - com.bannzai.shoppinglist.ShoppingListWidget (Widget Extension)
# RunnerTests 等はマップに無いためスキップされる。
#
# provisioning profile 名は環境変数で受け取る。ExportOptions.plist と同じ値を使い、
# SSOT を workflow の env（IOS_RUNNER_PROFILE_NAME / IOS_WIDGET_PROFILE_NAME）に置く。
require 'xcodeproj'

project_path = File.expand_path('../../Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

team_id = ENV.fetch('IOS_DEVELOPMENT_TEAM')

# bundle id -> provisioning profile 名
profiles = {
  'com.bannzai.shoppinglist' => ENV.fetch('IOS_RUNNER_PROFILE_NAME'),
  'com.bannzai.shoppinglist.ShoppingListWidget' => ENV.fetch('IOS_WIDGET_PROFILE_NAME'),
}

configured = 0
project.targets.each do |target|
  target.build_configurations.each do |config|
    next unless config.name == 'Release'

    bundle_id = config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
    profile = profiles[bundle_id]
    next if profile.nil?

    config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
    config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Distribution'
    config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = 'Apple Distribution'
    config.build_settings['DEVELOPMENT_TEAM'] = team_id
    config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = profile
    puts "Configured manual signing: #{target.name} (#{bundle_id}) -> #{profile}"
    configured += 1
  end
end

raise 'No Release configuration matched the expected bundle ids' if configured.zero?

project.save
