import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/provider/memo.dart';

class AppEntityPrepareResolver extends HookConsumerWidget {
  final String userID;
  final Widget Function(BuildContext context) builder;

  const AppEntityPrepareResolver({
    super.key,
    required this.userID,
    required this.builder,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoAdd = ref.watch(memoAddProvider);
    final memos = ref.watch(memosProvider);

    useEffect(() {
      void f() async {
        if (memos is AsyncData && memos.value?.isEmpty == true) {
          await memoAdd(userID: userID);
        }
      }

      f();
      return null;
    }, [memos]);

    if (memos.valueOrNull?.isEmpty == true) {
      return const Loading();
    }
    return builder(context);
  }
}
