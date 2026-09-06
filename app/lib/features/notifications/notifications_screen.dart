import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/stemwise_card.dart';
import '../auth/auth_controller.dart';

final _notificationsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final data = await api.get('/notifications');
  return data as List;
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: !auth.isAuthenticated
                ? const EmptyState(
                    icon: Icons.notifications_none,
                    title: "You're all caught up.",
                    message: 'Sign in to receive plan and data updates.')
                : _list(ref),
          ),
        ),
      ),
    );
  }

  Widget _list(WidgetRef ref) {
    final async = ref.watch(_notificationsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateView(message: e.toString(), onRetry: () => ref.invalidate(_notificationsProvider)),
      data: (items) => items.isEmpty
          ? const EmptyState(icon: Icons.check_circle_outline, title: "You're all caught up.")
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final n = items[i] as Map<String, dynamic>;
                return StemwiseCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['title']?.toString() ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(n['message']?.toString() ?? '',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
