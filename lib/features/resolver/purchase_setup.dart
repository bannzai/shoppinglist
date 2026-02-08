import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shoppinglist/components/loading/loading.dart';

class PurchaseSetupResolver extends HookConsumerWidget {
  final String userID;
  final Widget Function(BuildContext) builder;

  const PurchaseSetupResolver({
    super.key,
    required this.userID,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = useState(false);
    useEffect(() {
      void f() async {
        Purchases.logIn(userID);
        isDone.value = true;
      }

      f();
      return null;
    }, []);

    if (!isDone.value) {
      return const Loading();
    }
    return builder(context);
  }
}
