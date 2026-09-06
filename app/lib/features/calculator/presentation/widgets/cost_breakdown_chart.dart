import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/calculation_inputs.dart';

/// Donut cost breakdown (spec §27). Tapping a segment shows amount + %.
class CostBreakdownChart extends StatefulWidget {
  final CostInputs costs;
  const CostBreakdownChart({super.key, required this.costs});

  @override
  State<CostBreakdownChart> createState() => _CostBreakdownChartState();
}

class _CostBreakdownChartState extends State<CostBreakdownChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final c = widget.costs;
    final items = <_Seg>[
      _Seg('Tuition', c.tuitionAnnual, AppColors.primaryGreen),
      _Seg('Housing', c.housingAnnual, AppColors.darkGreen),
      _Seg('Food', c.foodAnnual, AppColors.info),
      _Seg('Books', c.booksAnnual, AppColors.purple),
      _Seg('Transport', c.transportationAnnual, AppColors.warning),
      _Seg('Other', c.otherAnnual, AppColors.textMuted),
    ].where((s) => s.value > 0).toList();

    final total = items.fold<double>(0, (a, s) => a + s.value);
    if (total <= 0) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 54,
              sections: List.generate(items.length, (i) {
                final s = items[i];
                final pct = s.value / total * 100;
                final touched = i == _touched;
                return PieChartSectionData(
                  value: s.value,
                  color: s.color,
                  radius: touched ? 60 : 50,
                  showTitle: touched,
                  title: '${pct.toStringAsFixed(1)}%',
                  titleStyle: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                );
              }),
              pieTouchData: PieTouchData(
                touchCallback: (event, resp) {
                  setState(() {
                    _touched = resp?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: List.generate(items.length, (i) {
            final s = items[i];
            final pct = s.value / total * 100;
            return Semantics(
              label: '${s.label}: ${Fmt.money(s.value)}, ${pct.toStringAsFixed(1)} percent',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  Text('${s.label} • ${Fmt.money(s.value)} (${pct.toStringAsFixed(1)}%)',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Seg {
  final String label;
  final double value;
  final Color color;
  _Seg(this.label, this.value, this.color);
}
