import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

/// Primary call-to-action button with a built-in loading state.
///
/// When [isLoading] is true, the button disables and shows a compact
/// spinner in place of the label. Matches the existing
/// login/register "submit" button look.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.labelKey,
    required this.onPressed,
    this.isLoading = false,
  });

  final String labelKey;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              context.tr(labelKey),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
