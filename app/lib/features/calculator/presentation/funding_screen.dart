import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/currency_input.dart';
import '../../../shared/widgets/stemwise_button.dart';
import '../../../shared/widgets/stemwise_card.dart';
import '../application/calculator_controller.dart';
import '../application/local_calc.dart';
import '../domain/calculation_inputs.dart';
import 'widgets/calc_step_scaffold.dart';

class FundingScreen extends ConsumerWidget {
  const FundingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorControllerProvider);
    final controller = ref.read(calculatorControllerProvider.notifier);
    final f = state.inputs.funding;
    final total = LocalCalc.totalCost(state.inputs.costs);
    final funding = LocalCalc.totalFunding(f);
    final gap = LocalCalc.fundingGap(state.inputs);

    void update(FundingInputs next) => controller.updateFunding(next);

    return CalcStepScaffold(
      stepIndex: 2,
      title: 'How will you pay for it?',
      subtitle: 'Enter any funding you expect (yearly or one-time totals).',
      bottomBar: StemwiseButton(
        label: 'See Loan Details  →',
        onPressed: () => context.push('/calculate/loan'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurrencyInput(label: 'Scholarships', value: f.scholarships, onChanged: (v) => update(f.copyWith(scholarships: v))),
          const SizedBox(height: 14),
          CurrencyInput(label: 'Grants', value: f.grants, onChanged: (v) => update(f.copyWith(grants: v))),
          const SizedBox(height: 14),
          CurrencyInput(label: 'Savings', value: f.savings, onChanged: (v) => update(f.copyWith(savings: v))),
          const SizedBox(height: 14),
          CurrencyInput(label: 'Family contribution', value: f.familyContribution, onChanged: (v) => update(f.copyWith(familyContribution: v))),
          const SizedBox(height: 14),
          CurrencyInput(label: 'Assistantship', tooltip: 'Teaching/research assistantship stipend or tuition waiver value.', value: f.assistantship, onChanged: (v) => update(f.copyWith(assistantship: v))),
          const SizedBox(height: 14),
          CurrencyInput(label: 'Employer contribution', value: f.employerContribution, onChanged: (v) => update(f.copyWith(employerContribution: v))),
          const SizedBox(height: 14),
          CurrencyInput(label: 'Other funding', value: f.otherFunding, onChanged: (v) => update(f.copyWith(otherFunding: v))),
          const SizedBox(height: 20),
          StemwiseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Total education cost', Fmt.money(total)),
                const SizedBox(height: 6),
                _row('Total non-loan funding', Fmt.money(funding)),
                const Divider(height: 22),
                Text('Your funding gap',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(Fmt.money(gap),
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: gap > 0 ? AppColors.textPrimary : AppColors.success)),
                const SizedBox(height: 4),
                const Text('This is the amount you may need to finance.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      );
}
