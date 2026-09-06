import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

enum StemwiseButtonVariant { primary, secondary, danger, ghost }

/// Brand button with all states incl. loading (spec §114). Min 48px touch target.
class StemwiseButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final StemwiseButtonVariant variant;
  final bool loading;
  final bool expand;
  final IconData? icon;

  const StemwiseButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = StemwiseButtonVariant.primary,
    this.loading = false,
    this.expand = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Color? borderColor;
    switch (variant) {
      case StemwiseButtonVariant.primary:
        bg = AppColors.primaryGreen;
        fg = Colors.white;
        break;
      case StemwiseButtonVariant.secondary:
        bg = Colors.transparent;
        fg = AppColors.darkGreen;
        borderColor = AppColors.primaryGreen;
        break;
      case StemwiseButtonVariant.danger:
        bg = Colors.transparent;
        fg = AppColors.danger;
        borderColor = AppColors.danger;
        break;
      case StemwiseButtonVariant.ghost:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        break;
    }
    if (disabled) {
      bg = variant == StemwiseButtonVariant.primary
          ? AppColors.primaryGreen.withValues(alpha: 0.4)
          : bg;
      fg = fg.withValues(alpha: 0.6);
    }

    final child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w600, color: fg, fontSize: 15),
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: expand ? double.infinity : null,
        height: 52,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.button),
            onTap: disabled ? null : onPressed,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: borderColor != null
                    ? Border.all(color: borderColor.withValues(alpha: disabled ? 0.5 : 1))
                    : null,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
