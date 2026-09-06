import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stemwise_card.dart';
import '../calculator/application/calculations_repository.dart';
import '../calculator/application/calculator_controller.dart';
import '../calculator/domain/calculation_inputs.dart';
import '../calculator/domain/calculation_result.dart';

class WhatIfScreen extends ConsumerStatefulWidget {
  const WhatIfScreen({super.key});
  @override
  ConsumerState<WhatIfScreen> createState() => _WhatIfScreenState();
}

class _WhatIfScreenState extends ConsumerState<WhatIfScreen> {
  late CalculationInputs _baseline;
  late CalculationInputs _scenario;
  WhatIfResult? _result;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _baseline = ref.read(calculatorControllerProvider).inputs;
    _scenario = _baseline;
    _recompute();
  }

  Future<void> _recompute() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await ref.read(calculationsRepositoryProvider).whatIf(_baseline, _scenario);
      if (mounted) setState(() => _result = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setScenario(CalculationInputs next) {
    setState(() => _scenario = next);
    _recompute();
  }

  @override
  Widget build(BuildContext context) {
    final f = _scenario.funding;
    final total = _baseline.costs.tuitionAnnual;
    return Scaffold(
      appBar: AppBar(title: const Text('What if?')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                const Text('See how changes impact your finances.',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                StemwiseCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Adjust your scenario',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _slider(
                        'Scholarships',
                        f.scholarships,
                        0,
                        (total * 4).clamp(20000, 200000).toDouble(),
                        (v) => _setScenario(_scenario.copyWith(
                            funding: f.copyWith(scholarships: v))),
                        Fmt.money(f.scholarships),
                      ),
                      _slider(
                        'Starting salary',
                        _scenario.career.startingSalary,
                        0,
                        200000,
                        (v) => _setScenario(_scenario.copyWith(
                            career: _scenario.career.copyWith(startingSalary: v))),
                        Fmt.money(_scenario.career.startingSalary),
                      ),
                      _slider(
                        'Repayment term',
                        _scenario.loan.repaymentYears.toDouble(),
                        5,
                        25,
                        (v) => _setScenario(_scenario.copyWith(
                            loan: _scenario.loan.copyWith(repaymentYears: v.round()))),
                        '${_scenario.loan.repaymentYears} yrs',
                        divisions: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_loading && _result == null)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                if (_error != null) ErrorStateView(message: _error!, onRetry: _recompute),
                if (_result != null) _differences(_result!),
                const SizedBox(height: 16),
                const DisclaimerCard(compact: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _differences(WhatIfResult r) {
    return StemwiseCard(
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(flex: 3, child: Text('Metric', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5))),
              Expanded(flex: 2, child: Text('Current', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5))),
              Expanded(flex: 2, child: Text('Scenario', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5))),
            ],
          ),
          const Divider(height: 18),
          ...r.differences.map(_diffRow),
        ],
      ),
    );
  }

  Widget _diffRow(ScenarioDifference d) {
    final color = switch (d.direction) {
      'improvement' => AppColors.success,
      'worsening' => AppColors.danger,
      _ => AppColors.textMuted,
    };
    final isPct = d.field == 'loanPaymentBurden' || d.field == 'score';
    String fmt(double v) => d.field == 'score'
        ? v.toStringAsFixed(0)
        : (d.field == 'loanPaymentBurden' ? Fmt.percent(v) : Fmt.money(v));
    final arrow = d.direction == 'improvement'
        ? '▲'
        : d.direction == 'worsening'
            ? '▼'
            : '–';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(d.label, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text(fmt(d.baseline), textAlign: TextAlign.end, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(fmt(d.scenario), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                if (d.delta != 0)
                  Text('$arrow ${isPct ? (d.field == 'score' ? d.delta.toStringAsFixed(0) : Fmt.percent(d.delta.abs())) : Fmt.signedMoney(d.delta)}',
                      style: TextStyle(fontSize: 10.5, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max,
      ValueChanged<double> onChanged, String valueLabel, {int? divisions}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            Text(valueLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions ?? 40,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
