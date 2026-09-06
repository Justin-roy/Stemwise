import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/currency_input.dart';
import '../../../shared/widgets/stemwise_button.dart';
import '../../../shared/widgets/stemwise_card.dart';
import '../application/calculator_controller.dart';
import '../application/local_calc.dart';
import 'widgets/calc_step_scaffold.dart';

class LoanScreen extends ConsumerWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorControllerProvider);
    final controller = ref.read(calculatorControllerProvider.notifier);
    final loan = state.inputs.loan;
    final gap = LocalCalc.fundingGap(state.inputs);
    final principal = LocalCalc.principal(state.inputs);
    final monthly = LocalCalc.monthlyPayment(state.inputs);
    final totalRepayment = monthly * loan.repaymentYears * 12;
    final totalInterest = (totalRepayment - principal).clamp(0, double.infinity);

    return CalcStepScaffold(
      stepIndex: 3,
      title: 'Loan simulator',
      subtitle: 'Adjust the values to see the real impact.',
      bottomBar: StemwiseButton(
        label: 'Continue  →',
        onPressed: () => context.push('/calculate/career'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StemwiseCard(
            color: AppColors.primaryDarkGreen,
            borderColor: AppColors.primaryDarkGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated monthly payment',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                const SizedBox(height: 4),
                _AnimatedMoney(value: monthly, suffix: ' /month'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _miniStat('Total repayment', Fmt.money(totalRepayment))),
                    Expanded(child: _miniStat('Total interest', Fmt.money(totalInterest.toDouble()))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          CurrencyInput(
            label: 'Loan amount',
            tooltip: 'Defaults to your funding gap. You can override it.',
            value: loan.loanPrincipalOverride ?? gap,
            onChanged: (v) => controller.updateLoan(loan.copyWith(loanPrincipalOverride: v)),
          ),
          if (loan.loanPrincipalOverride != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => controller.updateLoan(loan.copyWith(clearOverride: true)),
                child: const Text('Reset to funding gap'),
              ),
            ),
          const SizedBox(height: 8),
          _sliderBlock(
            label: 'Interest rate',
            valueLabel: Fmt.percent(loan.annualInterestRate, decimals: 1),
            value: loan.annualInterestRate,
            min: 0,
            max: 20,
            divisions: 200,
            onChanged: (v) => controller.updateLoan(
                loan.copyWith(annualInterestRate: double.parse(v.toStringAsFixed(1)))),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 2, bottom: 8),
            child: Text('Example planning rate. Last updated: 2026-01-01',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          ),
          _sliderBlock(
            label: 'Repayment term',
            valueLabel: '${loan.repaymentYears} years',
            value: loan.repaymentYears.toDouble(),
            min: 5,
            max: 25,
            divisions: 4,
            onChanged: (v) => controller.updateLoan(loan.copyWith(repaymentYears: v.round())),
          ),
          const SizedBox(height: 16),
          const DisclaimerCard(compact: true),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.5)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      );

  Widget _sliderBlock({
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            Text(valueLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _AnimatedMoney extends StatelessWidget {
  final double value;
  final String suffix;
  const _AnimatedMoney({required this.value, this.suffix = ''});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 300),
      builder: (context, v, _) => RichText(
        text: TextSpan(children: [
          TextSpan(
            text: Fmt.money(v),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
          ),
          TextSpan(
            text: suffix,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ]),
      ),
    );
  }
}
