import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable N-digit verification-code input (defaults to 6).
///
/// Self-contained: owns its controllers and focus nodes, advances
/// focus forward on digit entry, backtracks on delete, and fires
/// [onCompleted] exactly once when the last field receives its digit.
///
/// Always rendered LTR regardless of the ambient [Directionality]
/// — OTP codes read left-to-right in every locale.
class AppOtpCodeField extends StatefulWidget {
  const AppOtpCodeField({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.autoFocus = true,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autoFocus;

  @override
  State<AppOtpCodeField> createState() => _AppOtpCodeFieldState();
}

class _AppOtpCodeFieldState extends State<AppOtpCodeField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _completedFired = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

  void _onFieldChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _fullCode;
    widget.onChanged(code);

    if (code.length == widget.length &&
        !_completedFired &&
        widget.onCompleted != null) {
      _completedFired = true;
      widget.onCompleted!(code);
    } else if (code.length < widget.length) {
      _completedFired = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.length, (index) {
          return SizedBox(
            width: 45,
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              autofocus: widget.autoFocus && index == 0,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => _onFieldChanged(index, value),
            ),
          );
        }),
      ),
    );
  }
}
