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

class CostsScreen extends ConsumerWidget {
  const CostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorControllerProvider);
    final controller = ref.read(calculatorControllerProvider.notifier);
    final c = state.inputs.costs;
    final annual = LocalCalc.annualCost(c);
    final total = LocalCalc.totalCost(c);

    void update(CostInputs next) => controller.updateCosts(next);

    return CalcStepScaffold(
      stepIndex: 1,
      title: 'Enter your costs',
      subtitle: 'All fields are yearly amounts in USD.',
      bottomBar: StemwiseButton(
        label: 'Next  →',
        onPressed: annual > 0 ? () => context.push('/calculate/funding') : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurrencyInput(
            label: 'Tuition / year',
            tooltip: 'Annual tuition and mandatory academic fees.',
            value: c.tuitionAnnual,
            onChanged: (v) => update(c.copyWith(tuitionAnnual: v)),
          ),
          const SizedBox(height: 14),
          CurrencyInput(
            label: 'Housing / year',
            tooltip: 'Estimated annual housing or campus accommodation.',
            value: c.housingAnnual,
            onChanged: (v) => update(c.copyWith(housingAnnual: v)),
          ),
          const SizedBox(height: 14),
          CurrencyInput(
            label: 'Food / year',
            tooltip: 'Estimated annual food expenses.',
            value: c.foodAnnual,
            onChanged: (v) => update(c.copyWith(foodAnnual: v)),
          ),
          const SizedBox(height: 14),
          CurrencyInput(
            label: 'Books & equipment / year',
            tooltip:
                'Books, computer equipment, software, lab supplies and academic materials.',
            value: c.booksAnnual,
            onChanged: (v) => update(c.copyWith(booksAnnual: v)),
          ),
          const SizedBox(height: 14),
          CurrencyInput(
            label: 'Transportation / year',
            tooltip: 'Estimated annual transportation and commuting costs.',
            value: c.transportationAnnual,
            onChanged: (v) => update(c.copyWith(transportationAnnual: v)),
          ),
          const SizedBox(height: 14),
          CurrencyInput(
            label: 'Other expenses / year',
            tooltip: 'Any other annual education-related expenses.',
            value: c.otherAnnual,
            onChanged: (v) => update(c.copyWith(otherAnnual: v)),
          ),
          const SizedBox(height: 20),
          Text('Program duration',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: c.programYears.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '${c.programYears} yr',
                  onChanged: (v) => update(c.copyWith(programYears: v.round())),
                ),
              ),
              SizedBox(
                width: 64,
                child: Text('${c.programYears} yr',
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StemwiseCard(
            color: AppColors.primaryDarkGreen,
            borderColor: AppColors.primaryDarkGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated total cost',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                const SizedBox(height: 4),
                Text(Fmt.money(total),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                    '${Fmt.money(annual)} / year  •  ${c.programYears} year${c.programYears == 1 ? '' : 's'}',
                    style: TextStyle(
                        color: AppColors.primaryGreen, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
