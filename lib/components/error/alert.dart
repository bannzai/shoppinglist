import 'package:flutter/material.dart';
import 'package:shoppinglist/utils/error/error_display.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorAlert extends StatelessWidget {
  final String? title;
  final String errorMessage;
  final String? faqLinkURL;

  const ErrorAlert({
    super.key,
    required this.title,
    required this.faqLinkURL,
    required this.errorMessage,
  });
  @override
  Widget build(BuildContext context) {
    final faq = faqLinkURL;
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(
        title ?? 'エラーが発生しました',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      content: Text(
        errorMessage,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w300,
          color: colorScheme.onSurface,
        ),
      ),
      actions: <Widget>[
        if (faq != null)
          TextButton(
            onPressed: () async {
              launchUrl(Uri.parse(faq));
            },
            child: Text(
              'FAQを見る',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          child: Text(
            '閉じる',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

void showErrorAlert(
  BuildContext? context,
  Object error, [
  StackTrace? stackTrace,
]) {
  if (context == null) {
    return;
  }
  logError(error, stackTrace);
  final String title;
  final String message;
  final String? faqLinkURL;
  if (error is FormatException) {
    title = '不明なエラーが発生しました';
    message = error.message;
    faqLinkURL = null;
  } else if (error is String) {
    title = 'エラーが発生しました';
    message = error;
    faqLinkURL = null;
  } else {
    // FirebaseException 等は describeError で StackTrace を分離する。
    final display = describeError(error);
    title = display.title ?? '予期せぬエラーが発生しました';
    message = display.message;
    faqLinkURL = null;
  }
  showDialog(
    context: context,
    builder: (_) {
      return ErrorAlert(
        title: title,
        errorMessage: message,
        faqLinkURL: faqLinkURL,
      );
    },
  );
}
