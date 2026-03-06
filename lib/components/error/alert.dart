import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorAlert extends StatelessWidget {
  final String? title;
  final String errorMessage;
  final String? faqLinkURL;

  const ErrorAlert(
      {super.key,
      required this.title,
      required this.faqLinkURL,
      required this.errorMessage});
  @override
  Widget build(BuildContext context) {
    final faq = faqLinkURL;
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(
        title ?? 'エラーが発生しました',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
      ),
      content: Text(errorMessage,
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 14,
            color: colorScheme.onSurface,
          )),
      actions: <Widget>[
        if (faq != null)
          TextButton(
            onPressed: () async {
              launchUrl(Uri.parse(faq));
            },
            child: Text(
              'FAQを見る',
              style: TextStyle(
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
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

void showErrorAlert(BuildContext? context, Object error) {
  if (context == null) {
    return;
  }
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
    title = '予期せぬエラーが発生しました';
    message = error.toString();
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
