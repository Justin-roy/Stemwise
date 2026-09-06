import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/currency_input.dart';
import '../../../shared/widgets/stemwise_button.dart';
import '../../../shared/widgets/stemwise_card.dart';
import '../../career/careers_repository.dart';
import '../application/calculator_controller.dart';
import '../application/local_calc.dart';
import 'widgets/calc_step_scaffold.dart';

class CareerScreen extends ConsumerStatefulWidget {
  const CareerScreen({super.key});
  @override
  ConsumerState<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends ConsumerState<CareerScreen> {
  bool _useOwn = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorControllerProvider);
    final controller = ref.read(calculatorControllerProvider.notifier);
    final career = state.inputs.career;
    final careersAsync = ref.watch(careersProvider(state.field));

    final burden = LocalCalc.debtBurden(state.inputs);
    final takeHome = LocalCalc.monthlyTakeHome(career);

    return CalcStepScaffold(
      stepIndex: 4,
      title: 'Your future career',
      subtitle: 'Based on your selected field. Salary is an estimate, not a guarantee.',
      bottomBar: StemwiseButton(
        label: 'View Results  →',
        onPressed: career.startingSalary > 0 ? () => context.push('/calculate/result') : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          careersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => ErrorStateView(
              message: e.toString(),
              onRetry: () => ref.invalidate(careersProvider(state.field)),
            ),
            data: (careers) {
              if (careers.isEmpty && !_useOwn) {
                return Column(children: [
                  const EmptyState(
                    icon: Icons.work_outline,
                    title: 'No salary data for this field yet',
                    message: 'Enter your own estimate to continue.',
                  ),
                  StemwiseButton(
                    label: 'Use my own salary estimate',
                    variant: StemwiseButtonVariant.secondary,
                    onPressed: () => setState(() => _useOwn = true),
                  ),
                ]);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_useOwn)
                    ...careers.map((c) {
                      final selected = career.startingSalary == c.startingSalary;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: StemwiseCard(
                          borderColor: selected ? AppColors.primaryGreen : null,
                          color: selected ? AppColors.veryLightGreen : null,
                          onTap: () => controller.updateCareer(
                              career.copyWith(startingSalary: c.startingSalary)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.title,
                                        style: const TextStyle(
                                            fontSize: 15, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text('Est. starting salary • source: ${c.source ?? '—'}',
                                        style: const TextStyle(
                                            fontSize: 11.5, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              Text('${Fmt.money(c.startingSalary)}/yr',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.darkGreen)),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Use my own salary estimate',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    value: _useOwn,
                    activeThumbColor: AppColors.primaryGreen,
                    onChanged: (v) => setState(() => _useOwn = v),
                  ),
                  if (_useOwn)
                    CurrencyInput(
                      label: 'Expected starting salary / year',
                      value: career.startingSalary,
                      onChanged: (v) =>
                          controller.updateCareer(career.copyWith(startingSalary: v)),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (career.startingSalary > 0)
            StemwiseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Expected starting salary', '${Fmt.money(career.startingSalary)}/yr'),
                  const SizedBox(height: 6),
                  _row('Monthly gross (est.)', Fmt.money(career.startingSalary / 12)),
                  const SizedBox(height: 6),
                  _row('Monthly take-home (est.)', Fmt.money(takeHome)),
                  const Divider(height: 22),
                  _row('Debt payment burden',
                      Fmt.percent(burden),
                      valueColor: AppColors.bandColor(_band(burden))),
                  const SizedBox(height: 2),
                  const Text('of estimated monthly take-home income',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          const DisclaimerCard(compact: true),
        ],
      ),
    );
  }

  String _band(double b) {
    if (b < 10) return 'low';
    if (b < 20) return 'moderate';
    if (b < 30) return 'elevated';
    return 'high';
  }

  Widget _row(String label, String value, {Color? valueColor}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: valueColor)),
        ],
      );
}
