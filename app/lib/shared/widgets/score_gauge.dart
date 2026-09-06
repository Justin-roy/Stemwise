import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Animated circular STEMWISE planning score (spec §24, §115).
/// Animates 0 → score, exposes an accessible text representation.
class ScoreGauge extends StatelessWidget {
  final int score;
  final String classification;
  final String label;
  final double size;

  const ScoreGauge({
    super.key,
    required this.score,
    required this.classification,
    required this.label,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(classification);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'STEMWISE planning score $score out of 100. $label.',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score.toDouble()),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _GaugePainter(
                value / 100,
                color,
                isDark ? AppColors.darkBorder : AppColors.border,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: value.round().toString(),
                          style: TextStyle(
                            fontSize: size * 0.28,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: ' /100',
                          style: TextStyle(
                            fontSize: size * 0.11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: size * 0.075,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction;
  final Color color;
  final Color track;
  _GaugePainter(this.fraction, this.color, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.09;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    const start = -math.pi / 2;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, 2 * math.pi, false, trackPaint);
    canvas.drawArc(rect, start, 2 * math.pi * fraction, false, valuePaint);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fraction != fraction || old.color != color;
}
