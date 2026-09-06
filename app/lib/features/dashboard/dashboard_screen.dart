import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stemwise_button.dart';
import '../../shared/widgets/stemwise_card.dart';
import '../auth/auth_controller.dart';
import '../calculator/application/calculator_controller.dart';
import '../saved_plans/saved_plans_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final calc = ref.watch(calculatorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('STEMWISE'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(auth.isAuthenticated ? 'Welcome back 👋' : 'Welcome to STEMWISE',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text("Let's build your education financial plan.",
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                if (calc.started && calc.percentComplete < 100) ...[
                  _ContinueCard(percent: calc.percentComplete),
                  const SizedBox(height: 16),
                ],
                if (auth.isAuthenticated) _SavedSummary() else _AnonCta(),
                const SizedBox(height: 16),
                const SectionHeader('Quick actions'),
                const SizedBox(height: 12),
                StemwiseButton(
                    label: 'Calculate My Degree',
                    onPressed: () => context.go('/calculate/degree')),
                const SizedBox(height: 10),
                StemwiseButton(
                    label: 'Compare Universities',
                    variant: StemwiseButtonVariant.secondary,
                    onPressed: () => context.go('/compare')),
                const SizedBox(height: 10),
                StemwiseButton(
                    label: 'Explore Careers',
                    variant: StemwiseButtonVariant.secondary,
                    onPressed: () => context.go('/career')),
                const SizedBox(height: 20),
                const DisclaimerCard(compact: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueCard extends ConsumerWidget {
  final int percent;
  const _ContinueCard({required this.percent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StemwiseCard(
      color: AppColors.primaryDarkGreen,
      borderColor: AppColors.primaryDarkGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Continue your plan',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text("You're $percent% complete.",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: StemwiseButton(
                  label: 'Continue', onPressed: () => context.go('/calculate/degree')),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StemwiseButton(
                label: 'Start Over',
                variant: StemwiseButtonVariant.ghost,
                onPressed: () => _confirmStartOver(context, ref),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  void _confirmStartOver(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Start over?'),
        content: const Text('Your current calculation will be cleared.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(calculatorControllerProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: const Text('Start Over', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _AnonCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StemwiseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Save your plans across devices',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Create a free account to save plans and scenarios.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          StemwiseButton(
              label: 'Create Account',
              variant: StemwiseButtonVariant.secondary,
              onPressed: () => context.push('/auth/signup')),
        ],
      ),
    );
  }
}

class _SavedSummary extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(savedPlansProvider);
    return plansAsync.when(
      loading: () => const StemwiseCard(child: SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => StemwiseCard(child: Text(e.toString())),
      data: (plans) {
        if (plans.isEmpty) {
          return const StemwiseCard(
            child: Text("You don't have any saved plans yet. Run a calculation and tap Save My Plan."),
          );
        }
        final p = plans.first;
        final r = p.results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader('Your latest plan'),
            const SizedBox(height: 12),
            StemwiseCard(
              onTap: () => context.push('/saved-plans'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  if (r != null)
                    Wrap(spacing: 20, runSpacing: 10, children: [
                      _stat('Score', '${r.score.score}/100', AppColors.scoreColor(r.score.classification)),
                      _stat('Projected debt', Fmt.money(r.loan.principal), null),
                      _stat('Monthly', Fmt.moneyCents(r.loan.monthlyPayment), null),
                      _stat('Salary', Fmt.money(r.career.startingSalary), null),
                    ]),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _stat(String label, String value, Color? color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ],
      );
}
