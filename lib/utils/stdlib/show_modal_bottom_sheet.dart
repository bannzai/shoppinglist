import 'package:flutter/material.dart';
import 'package:shoppinglist/features/resolver/app.dart';

Future<T?> appShowModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final height = MediaQuery.of(context).size.height;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return SizedBox(
        height: height * 0.9,
        child: AppResolvers(builder: (context, user) => builder(context)),
      );
    },
  );
}
