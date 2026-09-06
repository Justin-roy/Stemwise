import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../calculator/application/calculator_controller.dart';
import '../saved_plans/saved_plans_repository.dart';

/// After sign in/up, auto-save the in-progress plan if that was the intent,
/// so anonymous calculator work is never lost (RULE 12, spec §32, §77).
Future<void> handlePostAuth(BuildContext context, WidgetRef ref, String? intent) async {
  if (intent == 'save') {
    final calc = ref.read(calculatorControllerProvider);
    try {
      final name = _planName(calc.degreeLevel, calc.field);
      await ref.read(savedPlansRepositoryProvider).create(
            name: name,
            field: calc.field,
            degreeLevel: calc.degreeLevel,
            universityId: calc.universityId,
            inputs: calc.inputs,
          );
      ref.invalidate(savedPlansProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Your plan has been saved.')));
        context.go('/saved-plans');
      }
      return;
    } catch (_) {
      // fall through to dashboard
    }
  }
  if (context.mounted) context.go('/dashboard');
}

/// Builds a readable plan name, e.g. "Master's Computer Science Plan".
String _planName(String? degreeLevel, String? field) {
  final degree = switch (degreeLevel) {
    'bachelors' => "Bachelor's ",
    'masters' => "Master's ",
    'phd' => 'PhD ',
    _ => '',
  };
  final fieldLabel = field == null
      ? 'STEM'
      : kStemFields
          .firstWhere((f) => f.slug == field,
              orElse: () => const StemField('', 'STEM'))
          .label;
  return '$degree$fieldLabel Plan';
}
