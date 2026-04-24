import 'package:flutter/material.dart';

/// Inline error banner rendered above the primary submit button.
///
/// Passing a null or empty message renders nothing — callers can
/// unconditionally drop this widget into a column and rely on the
/// `SizedBox.shrink()` fallback.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: errorColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: errorColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(color: errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
