import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Standard rounded card with a thin border and very subtle shadow (spec §7, §8).
class StemwiseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;

  const StemwiseCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.borderColor,
    this.radius = AppRadius.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.darkSurface : AppColors.white),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? (isDark ? AppColors.darkBorder : AppColors.border),
        ),
        boxShadow: isDark ? null : AppShadows.soft,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
