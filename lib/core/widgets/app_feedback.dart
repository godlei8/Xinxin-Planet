import 'package:flutter/material.dart';

enum AppToastType { info, success, warning, error }

void showAppToast(
  BuildContext context,
  String message, {
  AppToastType type = AppToastType.info,
  Duration duration = const Duration(milliseconds: 1400),
}) {
  final scheme = Theme.of(context).colorScheme;
  final messenger = ScaffoldMessenger.of(context);

  final (bgColor, fgColor, icon) = switch (type) {
    AppToastType.success => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.check_circle_rounded
      ),
    AppToastType.warning => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        Icons.warning_rounded
      ),
    AppToastType.error => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.error_rounded
      ),
    AppToastType.info => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        Icons.info_rounded
      ),
  };

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: bgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: fgColor.withValues(alpha: 0.2)),
        ),
        content: Row(
          children: [
            Icon(icon, size: 18, color: fgColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: fgColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
}
