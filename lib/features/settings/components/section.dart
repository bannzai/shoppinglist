import 'package:flutter/material.dart';
import 'package:shoppinglist/style/color.dart';

class SettingSectionTitle extends StatelessWidget {
  final String text;
  final List<Widget> children;

  const SettingSectionTitle({
    super.key,
    required this.text,
    required this.children,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(text: text),
        ...children,
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 32, left: 15, right: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 14,
          color: TextColor.primary,
        ),
      ),
    );
  }
}
