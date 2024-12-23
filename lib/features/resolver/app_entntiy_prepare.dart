import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shoppinglist/entity/memo.dart';
import 'package:shoppinglist/features/resolver/database.dart';
import 'package:shoppinglist/provider/memo.dart';

class AppEntityPrepareResolver extends HookConsumerWidget {
  final Widget Function(BuildContext context) builder;

  const AppEntityPrepareResolver({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = ref.watch(shoppingListMemoProvider);

    useEffect(() {
      if (shoppingList.asData?.value == null) {
        final docRef = ref.read(userDatabaseProvider).shoppingMemoReference();
        final shoppingListMemo = Memo(
          id: docRef.id,
          name: '買い物メモ',
          status: MemoStatus.active,
        );
        docRef.set(shoppingListMemo, SetOptions(merge: true));
      }
      return null;
    }, []);

    return builder(context);
  }
}
