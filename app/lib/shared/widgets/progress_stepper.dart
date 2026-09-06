import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Segmented calculator progress indicator (spec §75).
/// Completed = darkGreen, current = primaryGreen, upcoming = border.
class ProgressStepper extends StatelessWidget {
  final int currentIndex;
  final List<String> steps;
  const ProgressStepper({
    super.key,
    required this.currentIndex,
    this.steps = const ['Degree', 'Costs', 'Funding', 'Loan', 'Career', 'Results'],
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step ${currentIndex + 1} of ${steps.length}: ${steps[currentIndex]}',
      child: Row(
        children: List.generate(steps.length, (i) {
          Color color;
          if (i < currentIndex) {
            color = AppColors.darkGreen;
          } else if (i == currentIndex) {
            color = AppColors.primaryGreen;
          } else {
            color = AppColors.border;
          }
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == steps.length - 1 ? 0 : 5),
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
