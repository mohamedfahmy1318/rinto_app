import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/auth/entities/user_type.dart';

/// Four-way chip row for picking a [UserType] on the register form.
class UserTypeSelector extends StatelessWidget {
  const UserTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final UserType value;
  final ValueChanged<UserType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: UserType.values.map((type) {
        return ChoiceChip(
          label: Text(context.tr(type.labelKey)),
          selected: value == type,
          onSelected: (_) => onChanged(type),
        );
      }).toList(),
    );
  }
}
