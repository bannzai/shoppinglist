import 'package:flutter/material.dart';
import 'package:shoppinglist/utils/config/environment.dart';

/// 認証〜ホーム到達までの Resolver 連鎖（AuthResolver → UserDatabaseResolver →
/// AppUserCreateResolver → ForceUpdateResolver → AppEntityPrepareResolver）が
/// 解決待ちの間に表示する Loading へ共通で付与する key。
///
/// 各 Resolver は未解決の間それぞれ独立して Loading を返すが、段が解決するたびに
/// Loading のツリー上の位置（祖先 Widget の型構成）が変わる。key が無いと Flutter は
/// element を再利用できず、CircularProgressIndicator の State（回転を駆動する
/// AnimationController）が破棄・再生成され、回転が 0 度からリセットされて「ぶつ切り」に見える。
/// 連鎖の全 Loading に同一の GlobalKey を付与すると、段をまたいで element を reparent して
/// State を保持できるため回転が連続する。連鎖内では同時に 1 つの Loading しか mount しないため
/// GlobalKey 重複は発生しない。
final resolverChainLoadingKey = GlobalKey();

class Loading extends StatelessWidget {
  const Loading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (Environment.disableWidgetAnimation) {
      return Center(
        child: Container(
          color: colorScheme.secondary,
          width: 40,
          height: 40,
        ),
      );
    }
    return Center(
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(colorScheme.secondary)),
    );
  }
}

class ScaffoldLoading extends StatelessWidget {
  const ScaffoldLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Loading(),
    );
  }
}
