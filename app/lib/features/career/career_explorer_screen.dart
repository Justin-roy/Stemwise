import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stemwise_button.dart';
import '../../shared/widgets/stemwise_card.dart';
import '../calculator/application/calculator_controller.dart';
import 'careers_repository.dart';

class CareerExplorerScreen extends ConsumerWidget {
  const CareerExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careersAsync = ref.watch(careersProvider(null));
    return Scaffold(
      appBar: AppBar(title: const Text('Explore STEM careers')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: careersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorStateView(
                  message: e.toString(), onRetry: () => ref.invalidate(careersProvider(null))),
              data: (careers) => careers.isEmpty
                  ? const EmptyState(icon: Icons.work_outline, title: 'No careers available yet.')
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: careers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _CareerCard(career: careers[i]),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CareerCard extends ConsumerWidget {
  final Career career;
  const _CareerCard({required this.career});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StemwiseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(career.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Text('${Fmt.money(career.startingSalary)}/yr',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
            ],
          ),
          const SizedBox(height: 6),
          Text(career.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: [
            if (career.typicalDegreeLevel != null) _tag(_degree(career.typicalDegreeLevel!)),
            if (career.typicalProgramYears != null) _tag('${career.typicalProgramYears} yr program'),
            if (career.salaryRangeMin != null && career.salaryRangeMax != null)
              _tag('${Fmt.money(career.salaryRangeMin!)}–${Fmt.money(career.salaryRangeMax!)}'),
          ]),
          const SizedBox(height: 6),
          Text('Estimate • source: ${career.source ?? '—'}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          StemwiseButton(
            label: 'Use This Career',
            variant: StemwiseButtonVariant.secondary,
            onPressed: () {
              final ctrl = ref.read(calculatorControllerProvider.notifier);
              final career0 = ref.read(calculatorControllerProvider).inputs.career;
              ctrl.updateCareer(career0.copyWith(startingSalary: career.startingSalary));
              ctrl.setField(career.field);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${career.title} salary applied to your calculator.')));
              context.go('/calculate/degree');
            },
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: AppColors.veryLightGreen, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: const TextStyle(fontSize: 11.5, color: AppColors.darkGreen)),
      );

  String _degree(String d) => switch (d) {
        'bachelors' => "Bachelor's",
        'masters' => "Master's",
        'phd' => 'PhD',
        _ => d,
      };
}
