import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

/// Themed text-field primitive used across the app's form screens.
/// All visual styling comes from the active [Theme] — no inline
/// colors, paddings, or text styles.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.labelKey,
    this.hintKey,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.textDirection,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String labelKey;
  final String? hintKey;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: context.tr(labelKey),
        hintText: hintKey != null ? context.tr(hintKey!) : hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }
}
