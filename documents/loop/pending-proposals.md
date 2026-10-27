# 週次の承認を待つ方向性の文書への変更提案

product-loop skill が積み、weekly-product-report skill の週次レポートでチェックされた提案だけを `documents/DIRECTION.md` に反映する。書式は weekly-product-report skill の `scripts/build-report.sh` のヘッダーコメントが SSOT。

- [P-2026-10-27-1] 判定基準の行の追加: 「直近14日の新規顧客数」を足す。計測元は `bash ~/.agents/skills/product-loop/scripts/read-dashboard-metric.sh --repo bannzai/shoppinglist --metric new_customers --field new_customers --days 14 --agg sum` の `VALUE`、継続のしきい値は `>= 10`、打ち切り条件は `< 5 x2`、転換の条件は「新規顧客が続いているのに有料化が 1 件も起きなければ、paywall の導線の見直しを改善 issue にする」 / 背景: 判定基準はレビューとクラッシュの 3 行だけで「問題が起きていない」ことしか示さず、利用の有無を読めなかった (2026-10-13 の判定の記録)。2026-10-27 に dashboard から RevenueCat の新規顧客が日次で読めることを実測し、新規の流入が続いている向きを確認した。一方で MRR・有効な購読・売上は判定を分けられない値のままのため、行には新規顧客だけを足し、しきい値は今回の実測を基準に「現状維持なら継続、明確に落ちたら打ち切り」で置く
