import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/data/models/app_notification_model.dart';
import 'package:green_miles_app/viewmodel/notifications_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        actions: [
          Consumer<NotificationsViewModel>(
            builder: (context, viewModel, child) {
              return TextButton(
                onPressed: (viewModel.unreadCount == 0 || viewModel.isMarkingAllRead)
                    ? null
                    : () async {
                        final success = await context
                            .read<NotificationsViewModel>()
                            .markAllRead();
                        if (!context.mounted || !success) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(AppStrings.notificationsMarkedRead),
                          ),
                        );
                      },
                child: viewModel.isMarkingAllRead
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppStrings.markAllRead),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return _NotificationMessageState(
              message: viewModel.error!,
              icon: Icons.error_outline,
              actionLabel: 'Retry',
              onAction: viewModel.fetchNotifications,
            );
          }

          if (viewModel.notifications.isEmpty) {
            return _NotificationMessageState(
              message: AppStrings.noNotificationsYet,
              icon: Icons.notifications_none_rounded,
              actionLabel: null,
              onAction: null,
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.fetchNotifications,
            color: AppTheme.primaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: viewModel.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = viewModel.notifications[index];
                return _NotificationTile(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () => context.read<NotificationsViewModel>().markRead(notification),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppTheme.shadowColor.withValues(alpha: 0.15)
                : AppTheme.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _iconForType(notification.type),
            color: notification.isRead
                ? AppTheme.subtitleTextColor
                : AppTheme.primaryColor,
          ),
        ),
        title: Text(
          notification.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 6),
            Text(
              DateFormat('MMM d, h:mm a').format(notification.createdAt.toLocal()),
              style: textTheme.bodySmall?.copyWith(
                color: AppTheme.subtitleTextColor,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : const Icon(Icons.fiber_manual_record, size: 12, color: AppTheme.primaryColor),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'trip':
        return Icons.route_rounded;
      case 'reward':
        return Icons.card_giftcard_rounded;
      case 'system':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}

class _NotificationMessageState extends StatelessWidget {
  const _NotificationMessageState({
    required this.message,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(icon, size: 42, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: textTheme.titleMedium?.copyWith(color: AppTheme.textColor),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

