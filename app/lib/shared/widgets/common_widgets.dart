import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'stemwise_button.dart';
import 'stemwise_card.dart';

/// Financial metric tile (spec §116).
class FinancialMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? supporting;
  final Color? valueColor;
  final IconData? icon;

  const FinancialMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.supporting,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StemwiseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: valueColor ??
                      (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary))),
          if (supporting != null) ...[
            const SizedBox(height: 4),
            Text(supporting!,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}

/// Section header (spec §113).
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Compact financial disclaimer (spec §66).
class DisclaimerCard extends StatelessWidget {
  final bool compact;
  const DisclaimerCard({super.key, this.compact = false});

  static const _full =
      'STEMWISE provides educational estimates for planning purposes only. It is not a lender, financial advisor, admissions service, or guarantee of future income, employment, loan approval, or repayment outcomes. Actual costs, financial aid, interest rates, taxes, salaries, and repayment terms may differ.';
  static const _compact =
      'Estimates only. Actual costs, aid, interest, taxes, salaries and repayment terms may differ.';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.veryLightGreen,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.lightGreen),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.darkGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(compact ? _compact : _full,
                style: const TextStyle(
                    fontSize: 11.5, height: 1.4, color: AppColors.darkGreen)),
          ),
        ],
      ),
    );
  }
}

/// Empty state (spec §71).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? ctaLabel;
  final VoidCallback? onCta;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: 20),
              StemwiseButton(label: ctaLabel!, onPressed: onCta, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with retry (spec §70).
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorStateView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44, color: AppColors.danger),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              StemwiseButton(
                  label: 'Try Again',
                  onPressed: onRetry,
                  variant: StemwiseButtonVariant.secondary,
                  expand: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simple shimmer-free skeleton block (spec §69).
class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  const SkeletonBox({super.key, this.height = 16, this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
