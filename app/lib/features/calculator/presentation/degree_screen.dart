import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/stemwise_button.dart';
import '../application/calculator_controller.dart';
import 'widgets/calc_step_scaffold.dart';

const _fieldIcons = <String, IconData>{
  'computer-science': Icons.code,
  'engineering': Icons.settings,
  'data-science': Icons.bar_chart,
  'biotechnology': Icons.eco,
  'mathematics': Icons.functions,
  'physics': Icons.blur_circular,
  'other': Icons.more_horiz,
};

class DegreeScreen extends ConsumerWidget {
  const DegreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorControllerProvider);
    final controller = ref.read(calculatorControllerProvider.notifier);
    final canProceed = state.field != null && state.degreeLevel != null;

    return CalcStepScaffold(
      stepIndex: 0,
      title: 'What do you want to study?',
      subtitle: 'Choose your field of study.',
      bottomBar: StemwiseButton(
        label: 'Next  →',
        onPressed: canProceed ? () => context.push('/calculate/costs') : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth > 420 ? 3 : 2;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: kStemFields.map((f) {
                final selected = state.field == f.slug;
                return _FieldCard(
                  label: f.label,
                  icon: _fieldIcons[f.slug] ?? Icons.school,
                  selected: selected,
                  onTap: () => controller.setField(f.slug),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 24),
          const Text('What degree are you pursuing?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              _degreeChip(context, controller, state, 'bachelors', "Bachelor's"),
              const SizedBox(width: 10),
              _degreeChip(context, controller, state, 'masters', "Master's"),
              const SizedBox(width: 10),
              _degreeChip(context, controller, state, 'phd', 'PhD'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _degreeChip(BuildContext context, CalculatorController controller,
      CalculatorState state, String value, String label) {
    final selected = state.degreeLevel == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setDegreeLevel(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.veryLightGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
                color: selected ? AppColors.primaryGreen : AppColors.border,
                width: selected ? 1.6 : 1),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.darkGreen : AppColors.textSecondary)),
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _FieldCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.veryLightGreen : AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
                color: selected ? AppColors.primaryGreen : AppColors.border,
                width: selected ? 1.6 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  size: 26,
                  color: selected ? AppColors.darkGreen : AppColors.textSecondary),
              const Spacer(),
              Text(label,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.darkGreen : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
