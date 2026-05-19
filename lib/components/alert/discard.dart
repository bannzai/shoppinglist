import 'package:flutter/material.dart';

class DiscardDialog extends StatelessWidget {
  final String title;
  final Widget message;
  final List<Widget> actions;

  const DiscardDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Icon(
        Icons.warning,
        color: Theme.of(context).primaryColor,
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 15,
            ),
          ],
          message,
        ],
      ),
      actions: actions,
    );
  }
}

void showDiscardDialog(
  BuildContext context, {
  required String title,
  required String message,
  required List<Widget> actions,
}) {
  showDialog(
    context: context,
    builder: (context) => DiscardDialog(
      title: title,
      message: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
      actions: actions,
    ),
  );
}
