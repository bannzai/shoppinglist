import 'package:flutter/material.dart';
import 'package:shoppinglist/style/color.dart';
import 'package:shoppinglist/utils/config/environment.dart';

class Loading extends StatelessWidget {
  const Loading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (Environment.disableWidgetAnimation) {
      return Center(
        child: Container(
          color: AppColors.secondary,
          width: 40,
          height: 40,
        ),
      );
    }
    return const Center(
      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.secondary)),
    );
  }
}

class ScaffoldLoading extends StatelessWidget {
  const ScaffoldLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Loading(),
    );
  }
}
