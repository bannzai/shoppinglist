---
status: launched          # evaluating | building | launched | pivoting | retiring | retired
decision_date: 2026-10-13 # 次の判定日 (YYYY-MM-DD)。判定のたびに cycle_days 後へ進める
cycle_days: 14            # 判定の周期 (7 または 14)
veto_wait_hours: 12       # 公開後の無人ループの拒否権の待ち時間 (既定 12)
daily_issue_cap: 3        # 1 日に生成してよい改善 issue の上限 (意味の門。既定 3)
launched_at: 2026-08-20   # 公開日 (YYYY-MM-DD)。App Store の初回公開日
---

# 方向性: shoppinglist (買い物リスト - 家族と共有)

## 仮説

家族やルームメイトと買い物を分担している人・複数の店舗を使い分けている人が、「何を買うか」を LINE で聞いたりメモを写真で送ったりする共有の手間と買い忘れに困っている。グループで共有できる買い物リストと、店内の動線に合わせたカテゴリ順のソートでそれを解消する。最初は自動で作られる個人用グループでメモのように使い、必要になったら共有する 2 段階で広げ、プレミアム (RevenueCat) で収益化する (出典: `documents/PROJECT.md` 7〜21 行、`ios/fastlane/metadata/ja/description.txt`)。

## 判定基準

| 指標 | 計測元 (skill / コマンド) | 継続のしきい値 | 打ち切り条件 | 転換の条件 |
| --- | --- | --- | --- | --- |
| 直近14日の★1〜2レビュー数 | appstore-research skill: `bash ~/.agents/skills/appstore-research/scripts/fetch-reviews.sh 6739724511 --country jp --pages 1` の出力で `date` が直近 14 日かつ `rating` が 2 以下の行数 | <= 1 | >= 3 x2 | 低評価の内容が共有 (招待・同期) に集中していたら、共有の導線の作り直しを最優先の改善 issue にする |
| 直近14日のFATALクラッシュissue数 | firebase-crashlytics-triage skill: `bash ~/.agents/skills/firebase-crashlytics-triage/scripts/crashlytics.sh top-issues --app-id 1:323773689605:ios:a8663a6921f6488b15516c --days 14 --error-types FATAL` の topIssues の行数 (prod の plist はリポジトリに無いため Firebase project `shoppinglist-prod-857bb` の iOS app ID を直接渡す) | <= 5 | > 30 x2 | 上位 issue のイベント数が 1 件で 100 を超えていたら、機能追加より先にその修正 issue を出す |

平均評価は 2026-09-29 時点で 0 件のため判定基準に入れない。10 件を超えたら agent が `>= 4.0` / `< 3.5 x2` の行を足す。

## 必要な機能

- [x] 買い物リストの作成・チェック・並べ替え・複製・メモ・色分け・TTL による自動非表示
- [x] グループの作成・URL 招待・メンバー管理・デフォルトグループ
- [x] 店舗ごと・カテゴリごとの整理とカテゴリ順のソート
- [x] 写真・URL からのアイテム抽出と AI のカテゴリ分け、レシート保存
- [x] ホーム画面ウィジェット、リスト更新のプッシュ通知、お問い合わせ (Slack)
- [x] プレミアムの paywall (RevenueCat)
- [ ] 店舗の近くで知らせるリマインダーの公開 (実装済みだがコンパイル時のフラグで非表示。`documents/adr/0032`)
- [ ] iOS の App Check を DeviceCheck から App Attest へ移行 (#594)

## デザインの方向

既存アプリのため Claude Design のモックは無い。現行の画面 (`documents/design-handoff-v2-*.md` で検証した v2 デザイン) を正とする。

## 決めたこと

| 日付 | 場面 | 決めたこと | 決めた人 |
| --- | --- | --- | --- |
| 2026-09-29 | 既存アプリへの後付け | 下書きを agent が作成。bannzai が直すか黙認する。しきい値は 2026-09-29 時点の実測 (評価 0 件、直近 14 日の ★1〜2 レビュー 0 件、直近 14 日の FATAL issue 0 件) を基準に「現状維持なら継続、明確に落ちたら打ち切り」で置いた | agent |

## agent に任せること

文書に無い問いはすべて。RevenueCat の課金指標は、`metrics/overview` を読める v2 API key が `.envrc` に入った時に agent が判定基準へ足す。Android (Google Play の internal トラック) の公開状況は未確認で、公開済みなら Android の指標も同様に扱う。
