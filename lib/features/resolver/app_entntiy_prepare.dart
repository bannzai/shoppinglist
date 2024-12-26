import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shoppinglist/components/loading/loading.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/memo.dart';

class AppEntityPrepareResolver extends HookConsumerWidget {
  final Widget Function(BuildContext context) builder;

  const AppEntityPrepareResolver({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memos = ref.watch(memosProvider);

    useEffect(() {
      void f() async {
        if (memos is AsyncData && memos.valueOrNull?.isEmpty == true) {
          final docRef = ref.read(userDatabaseProvider).newMemoReference();
          final shoppingListMemo = Memo(
            id: docRef.id,
            name: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            status: MemoStatus.active,
          );
          docRef.set(shoppingListMemo, SetOptions(merge: true));
        }
      }

      f();
      return null;
    }, []);

    if (memos.valueOrNull?.isEmpty == true) {
      return const Loading();
    }
    return builder(context);
  }
}
