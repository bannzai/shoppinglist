# Google Play Edits ワークフロー

Edits は AAB アップロード / Track 操作 / Listing 編集の前提となる「編集トランザクション」。

## 基本フロー
```
1. edits.insert         → editId 取得
2. edits.bundles.upload → versionCode 取得（アップロードした AAB のバージョン）
3. edits.tracks.update  → versionCode を track に登録
4. edits.commit         → 公開
```

## 重要な特性
- **Edits は楽観ロック**: 他のセッション（人間 / 別 Skill）が同時に edit を作成すると 409 Conflict
- **Edit を `commit` せずに放置すると dangling 状態**になる
- **Edit に有効期限あり**（明示的なドキュメントなし、概ね 24h）
- **Production track は alpha/beta より少ない頻度で操作するのが公式推奨**（1 日 1 回以下）

## Skill での扱い
- 各スクリプトは「自分で edit を insert → 操作 → commit」を 1 単位として実行
- 例外発生時は `commit` 前に edit を delete してロールバック
- `cleanup_edits.sh` で残ってしまった edits を一括削除可能

## エラーハンドリング
- **409 Conflict**: 5 秒待ってリトライ
- **400 Bad Request**: AAB のバージョン重複、Listing 不正など、内容を確認
- **403 Forbidden**: Service Account 招待忘れ or 権限不足

## 段階的ロールアウト
- `release.userFraction` (0-1) で割合を指定
- `release.status`: `draft` / `inProgress` / `halted` / `completed`
- 国別ターゲティングは production の `inProgress` リリースのみ可能（CLDR 2 文字）
