---
scope: repository
recorded: 2026-11-10
---
# Paywall に月額・年額が出ない時は、コードより先に RevenueCat の本番の Offering の設定を確かめる

`lib/features/paywall/paywall_page.dart` は `monthlyPackageProvider` / `annualPackageProvider` / `lifetimePackageProvider` を watch し、null でないプランだけを表示する。パッケージは商品 ID ではなく RevenueCat の標準の `PackageType` (`$rc_monthly` / `$rc_annual` 等) で照合する。

`lib/utils/purchase/purchase.dart` の `currentOfferingPackages` は `offerings.all[customerInfo.currentOfferingType.identifier]` を参照し、無ければ `offerings.current` を使う。

2026-06-05 に debug ビルドで確かめた。debug ビルドは RevenueCat の Test Store (`REVENUECAT_TEST_STORE_API_KEY`) を使い、Test Store の Offering には 3 つのパッケージがそろっているため、Paywall に月額・年額・買い切りの 3 つが表示された。表示のコードは正しく動いている。

**なぜ:** debug ビルドで出て本番でだけ出ない時、表示のコードは同じなので、差は本番のキーで SDK が返す Offering の中身にある。まず RevenueCat の本番の Offering の構成 (パッケージが標準の `PackageType` で登録されているか) を確かめる。パッケージの種別が `custom` だと照合に一致せず、コードでは直せない。

**どう使う:**

- 本番のキーのビルドで、開発者オプションの「Offering 構成」の出力 (`offerings.all` のキー・`current`・各パッケージの種別) を読む。debug ビルド (Test Store) の出力は本番の Offering を反映しない
- パッケージの種別が `custom` なら、RevenueCat の側で標準の識別子に直す
