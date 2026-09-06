import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stemwise_button.dart';
import '../../shared/widgets/stemwise_card.dart';
import '../auth/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: !auth.isAuthenticated
                ? EmptyState(
                    icon: Icons.person_outline,
                    title: 'Sign in to manage your profile',
                    message: 'Create a free account to save plans and scenarios.',
                    ctaLabel: 'Sign In',
                    onCta: () => context.push('/auth/login'),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      StemwiseCard(
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.veryLightGreen,
                              child: Icon(Icons.person, color: AppColors.darkGreen),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(auth.user?.email.isNotEmpty == true ? auth.user!.email : 'Your account',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                  const Text('STEMWISE member',
                                      style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _tile(context, Icons.folder_outlined, 'Saved plans', () => context.push('/saved-plans')),
                      _tile(context, Icons.notifications_none, 'Notifications', () => context.push('/notifications')),
                      const SizedBox(height: 16),
                      StemwiseButton(
                        label: 'Sign Out',
                        variant: StemwiseButtonVariant.danger,
                        onPressed: () async {
                          await ref.read(authControllerProvider.notifier).logout();
                          if (context.mounted) context.go('/dashboard');
                        },
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: StemwiseCard(
          onTap: onTap,
          child: Row(children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ]),
        ),
      );
}
