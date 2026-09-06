import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stemwise_card.dart';
import 'saved_plans_repository.dart';

class SavedPlansScreen extends ConsumerWidget {
  const SavedPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(savedPlansProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved plans')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: plansAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  ErrorStateView(message: e.toString(), onRetry: () => ref.invalidate(savedPlansProvider)),
              data: (plans) => plans.isEmpty
                  ? EmptyState(
                      icon: Icons.folder_open,
                      title: "You don't have any saved plans yet.",
                      ctaLabel: 'Create Your First Plan',
                      onCta: () => context.go('/calculate/degree'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(savedPlansProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: plans.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _PlanCard(plan: plans[i]),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final SavedPlan plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = plan.results;
    return StemwiseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(plan.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              if (r != null)
                Text('${r.score.score}/100',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.scoreColor(r.score.classification))),
            ],
          ),
          const SizedBox(height: 8),
          if (r != null)
            Text(
                'Projected debt ${Fmt.money(r.loan.principal)} • Monthly ${Fmt.moneyCents(r.loan.monthlyPayment)}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _confirmDelete(context, ref),
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                label: const Text('Delete', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this plan?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              try {
                await ref.read(savedPlansRepositoryProvider).delete(plan.id);
                ref.invalidate(savedPlansProvider);
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
