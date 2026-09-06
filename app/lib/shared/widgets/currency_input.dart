import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// Currency field with label, info tooltip and inline validation (spec §15, §68).
/// Accepts numbers only, rejects negatives/invalid characters, formats on the fly.
class CurrencyInput extends StatefulWidget {
  final String label;
  final String? tooltip;
  final double value;
  final ValueChanged<double> onChanged;
  final String prefix;

  const CurrencyInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.tooltip,
    this.prefix = '\$',
  });

  @override
  State<CurrencyInput> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<CurrencyInput> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(
      text: widget.value == 0 ? '' : _trim(widget.value),
    );
  }

  String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                )),
            if (widget.tooltip != null) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: widget.tooltip!,
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 4),
                child: Semantics(
                  label: '${widget.label} info',
                  child: const Icon(Icons.info_outline,
                      size: 15, color: AppColors.textMuted),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            prefixText: '${widget.prefix} ',
            hintText: '0',
          ),
          onChanged: (raw) {
            final parsed = double.tryParse(raw) ?? 0;
            widget.onChanged(parsed < 0 ? 0 : parsed);
          },
        ),
      ],
    );
  }
}
