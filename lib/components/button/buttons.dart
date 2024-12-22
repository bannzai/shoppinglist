import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';

final fillWidthStyle = ButtonStyle(
  minimumSize: WidgetStateProperty.all(const Size(double.infinity, 48)),
);

class ColorButton extends HookWidget {
  final Widget child;
  final Color color;
  final Future<void> Function()? onPressed;

  const ColorButton({
    super.key,
    required this.child,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isProcessing = useState(false);

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return null;
            }
            return color;
          },
        ),
      ),
      onPressed: onPressed == null
          ? null
          : () async {
              if (isProcessing.value) {
                return;
              }
              isProcessing.value = true;
              try {
                await onPressed?.call();
              } catch (error) {
                rethrow;
              } finally {
                if (context.mounted) isProcessing.value = false;
              }
            },
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          if (isProcessing.value) _Loading(),
        ],
      ),
    );
  }
}

class AlertButton extends HookWidget {
  final String text;
  final Future<void> Function()? onPressed;

  const AlertButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isProcessing = useState(false);

    return TextButton(
      onPressed: onPressed == null
          ? null
          : () async {
              if (isProcessing.value) {
                return;
              }
              isProcessing.value = true;
              try {
                await onPressed?.call();
              } catch (error) {
                rethrow;
              } finally {
                if (context.mounted) isProcessing.value = false;
              }
            },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: (isProcessing.value || onPressed == null) ? Colors.grey : Colors.purple,
            ),
          ),
          if (isProcessing.value) _Loading(),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation(Colors.black87),
      ),
    );
  }
}
