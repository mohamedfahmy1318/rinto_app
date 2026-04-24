import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_provider.dart';
// TODO(feature-003-settings-repository): migrate the terms fetch onto a
// SettingsRepository so this widget stops touching ApiService directly.
import '../../../services/api_service.dart';

/// Checkbox + legal copy with a tappable link that opens the terms
/// dialog. Used on the register form.
class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(text: context.tr('agree_to_terms_prefix')),
                  TextSpan(
                    text: context.tr('terms_of_service'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _showTermsDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const _TermsDialog(),
    );
  }
}

class _TermsDialog extends StatelessWidget {
  const _TermsDialog();

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppProvider>(context, listen: false).languageCode;
    return AlertDialog(
      title: Text(context.tr('terms_of_service')),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: FutureBuilder(
          future: ApiService.get('settings/terms?lang=$lang'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data!.success) {
              final data = snapshot.data!.data;
              final content = data is Map
                  ? (data['content'] ?? '').toString()
                  : '';
              return SingleChildScrollView(
                child: Text(
                  content.replaceAll(RegExp(r'<[^>]*>'), ''),
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }
            return Center(child: Text(context.tr('error_loading')));
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('close')),
        ),
      ],
    );
  }
}
