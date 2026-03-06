import 'package:flutter/material.dart';
import 'package:shoppinglist/utils/config/environment.dart';

class Loading extends StatelessWidget {
  const Loading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (Environment.disableWidgetAnimation) {
      return Center(
        child: Container(
          color: colorScheme.secondary,
          width: 40,
          height: 40,
        ),
      );
    }
    return Center(
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(colorScheme.secondary)),
    );
  }
}

class ScaffoldLoading extends StatelessWidget {
  const ScaffoldLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Loading(),
    );
  }
}
