import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

/// Standard chrome for an authentication / form page.
///
/// Provides: `AppBar` with a localized title, `SafeArea`,
/// `SingleChildScrollView`, outer padding, and a `Form` owning the
/// [formKey]. Callers supply just the body column as [children].
class AppFormScaffold extends StatelessWidget {
  const AppFormScaffold({
    super.key,
    required this.titleKey,
    required this.children,
    this.formKey,
    this.padding = const EdgeInsets.all(24),
  });

  final String titleKey;
  final List<Widget> children;
  final GlobalKey<FormState>? formKey;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(titleKey)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
