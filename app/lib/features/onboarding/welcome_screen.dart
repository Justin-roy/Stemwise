import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/stemwise_button.dart';

/// Welcome / hero screen (spec §12).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkGreen,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: AppColors.primaryGreen, size: 34),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: const TextSpan(children: [
                      TextSpan(
                          text: 'STEM',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                      TextSpan(
                          text: 'WISE',
                          style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                    ]),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Know the cost.\nKnow the debt.\nKnow your future.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        height: 1.15,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Make smarter financial decisions before choosing your STEM degree.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 15,
                        height: 1.5),
                  ),
                  const Spacer(flex: 3),
                  StemwiseButton(
                    label: 'Calculate My Degree  →',
                    onPressed: () => context.go('/calculate/degree'),
                  ),
                  const SizedBox(height: 12),
                  StemwiseButton(
                    label: 'Compare Universities',
                    variant: StemwiseButtonVariant.secondary,
                    onPressed: () => context.go('/compare'),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/auth/login'),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14)),
                          const TextSpan(
                              text: 'Sign in',
                              style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
