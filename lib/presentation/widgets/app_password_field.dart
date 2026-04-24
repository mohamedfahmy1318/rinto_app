import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

/// Password input with a self-contained visibility toggle.
///
/// Use in place of [AppTextField] whenever the field is a password.
/// Validation (required, min length, confirm-match) is the caller's
/// responsibility.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.controller,
    required this.labelKey,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String labelKey;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: context.tr(widget.labelKey),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
