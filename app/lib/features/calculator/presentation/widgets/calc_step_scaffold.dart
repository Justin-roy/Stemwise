import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/progress_stepper.dart';

/// Consistent layout for every calculator step (spec §75, §112 sticky CTA).
class CalcStepScaffold extends StatelessWidget {
  final int stepIndex;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? bottomBar;

  const CalcStepScaffold({
    super.key,
    required this.stepIndex,
    required this.title,
    required this.child,
    this.subtitle,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Calculate')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: ProgressStepper(currentIndex: stepIndex),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(subtitle!,
                            style: const TextStyle(
                                fontSize: 14.5, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                      top: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.border)),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: bottomBar,
                ),
              ),
            ),
    );
  }
}
