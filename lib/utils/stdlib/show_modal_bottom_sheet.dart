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
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SizedBox(
        height: height * 0.8,
        child: AppResolvers(
          builder: (context, user) => builder(context),
        ),
      );
    },
  );
}
