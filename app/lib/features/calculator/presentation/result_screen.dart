import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/score_gauge.dart';
import '../../../shared/widgets/stemwise_button.dart';
import '../../../shared/widgets/stemwise_card.dart';
import '../../auth/auth_controller.dart';
import '../../saved_plans/saved_plans_repository.dart';
import '../application/calculator_controller.dart';
import '../application/result_provider.dart';
import '../domain/calculation_result.dart';
import 'widgets/cost_breakdown_chart.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(fullResultProvider);
    final calc = ref.watch(calculatorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your financial picture'),
        actions: [
          IconButton(
            tooltip: 'View assumptions',
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showAssumptions(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: resultAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorStateView(
                message: e.toString(),
                onRetry: () => ref.invalidate(fullResultProvider),
              ),
              data: (r) => _ResultBody(result: r, calc: calc),
            ),
          ),
        ),
      ),
    );
  }

  void _showAssumptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Planning assumptions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 12),
            Text('• Take-home rate: 70% of gross (estimate).\n'
                '• Example planning interest rate; last updated 2026-01-01.\n'
                '• Debt-burden bands: <10% low, 10–20% moderate, 20–30% elevated, >30% high.\n'
                '• Score weights: cost 20%, debt 25%, payment burden 25%, income 20%, funding 10%.',
                style: TextStyle(height: 1.6, color: AppColors.textSecondary)),
            SizedBox(height: 16),
            DisclaimerCard(),
          ],
        ),
      ),
    );
  }
}

class _ResultBody extends ConsumerWidget {
  final FullResult result;
  final CalculatorState calc;
  const _ResultBody({required this.result, required this.calc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = result.score;
    final metrics = [
      _M('Total education cost', Fmt.money(result.cost.totalEducationCost)),
      _M('Expected funding', Fmt.money(result.funding.totalNonLoanFunding)),
      _M('Projected borrowing', Fmt.money(result.loan.principal)),
      _M('Monthly payment', Fmt.moneyCents(result.loan.monthlyPayment)),
      _M('Expected starting salary', Fmt.money(result.career.startingSalary)),
      _M('Debt payment burden', Fmt.percent(result.debtBurden.loanPaymentBurden),
          color: AppColors.bandColor(result.debtBurden.band)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Center(
          child: ScoreGauge(
            score: s.score,
            classification: s.classification,
            label: s.classificationLabel,
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('A simplified estimate based on the information you entered.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          final cols = constraints.maxWidth > 520 ? 3 : 2;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: metrics
                .map((m) => FinancialMetricCard(
                    label: m.label, value: m.value, valueColor: m.color))
                .toList(),
          );
        }),
        const SizedBox(height: 20),
        const SectionHeader('Cost breakdown'),
        const SizedBox(height: 12),
        StemwiseCard(child: CostBreakdownChart(costs: calc.inputs.costs)),
        const SizedBox(height: 20),
        StemwiseCard(
          color: AppColors.veryLightGreen,
          borderColor: AppColors.lightGreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.insights, color: AppColors.darkGreen, size: 18),
                const SizedBox(width: 8),
                Text(_verdictSentence(s.classification),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
              ]),
            ],
          ),
        ),
        if (result.recommendations.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionHeader('${result.recommendations.length} ways to improve your plan'),
          const SizedBox(height: 12),
          ...result.recommendations.take(3).map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecCard(rec: rec),
              )),
        ],
        const SizedBox(height: 20),
        StemwiseButton(
          label: 'Try What If?',
          onPressed: () => context.push('/what-if'),
        ),
        const SizedBox(height: 10),
        StemwiseButton(
          label: 'Compare Universities',
          variant: StemwiseButtonVariant.secondary,
          onPressed: () => context.go('/compare'),
        ),
        const SizedBox(height: 10),
        StemwiseButton(
          label: 'Save My Plan',
          variant: StemwiseButtonVariant.secondary,
          onPressed: () => _save(context, ref),
        ),
        const SizedBox(height: 20),
        const DisclaimerCard(),
      ],
    );
  }

  /// Grammatically correct verdict per classification (spec §99 — never overstate).
  String _verdictSentence(String classification) {
    switch (classification) {
      case 'strong':
        return 'Your plan appears to be in a strong position under these assumptions.';
      case 'manageable':
        return 'Your plan appears relatively manageable under these assumptions.';
      case 'attention':
        return 'Your plan may need attention under these assumptions.';
      case 'pressure':
        return 'Your plan shows high financial pressure under these assumptions.';
      default:
        return 'This is a simplified estimate based on the information you entered.';
    }
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated) {
      final choice = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create a free account to save this plan',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text("Your calculation won't be lost — we'll save it right after you sign up.",
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              StemwiseButton(label: 'Create Account', onPressed: () => Navigator.pop(context, 'signup')),
              const SizedBox(height: 10),
              StemwiseButton(
                  label: 'Sign In',
                  variant: StemwiseButtonVariant.secondary,
                  onPressed: () => Navigator.pop(context, 'login')),
              const SizedBox(height: 10),
              StemwiseButton(
                  label: 'Not Now',
                  variant: StemwiseButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context, 'cancel')),
            ],
          ),
        ),
      );
      if (choice == 'signup') {
        if (context.mounted) context.push('/auth/signup?intent=save');
      } else if (choice == 'login') {
        if (context.mounted) context.push('/auth/login?intent=save');
      }
      return;
    }
    await _doSave(context, ref);
  }

  Future<void> _doSave(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final name = calc.field != null
          ? '${_degreeLabel(calc.degreeLevel)} ${_fieldLabel(calc.field!)} Plan'
          : 'My STEM Plan';
      await ref.read(savedPlansRepositoryProvider).create(
            name: name,
            field: calc.field,
            degreeLevel: calc.degreeLevel,
            universityId: calc.universityId,
            inputs: calc.inputs,
          );
      ref.invalidate(savedPlansProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Your plan has been saved.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String _degreeLabel(String? d) => switch (d) {
        'bachelors' => "Bachelor's",
        'masters' => "Master's",
        'phd' => 'PhD',
        _ => '',
      };

  String _fieldLabel(String slug) =>
      kStemFields.firstWhere((f) => f.slug == slug, orElse: () => const StemField('', 'STEM')).label;
}

class _RecCard extends StatelessWidget {
  final Recommendation rec;
  const _RecCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return StemwiseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.veryLightGreen,
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.darkGreen),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(rec.title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(rec.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 6),
          Text(rec.estimatedImpact,
              style: const TextStyle(fontSize: 12.5, color: AppColors.darkGreen, height: 1.4)),
        ],
      ),
    );
  }
}

class _M {
  final String label, value;
  final Color? color;
  _M(this.label, this.value, {this.color});
}
