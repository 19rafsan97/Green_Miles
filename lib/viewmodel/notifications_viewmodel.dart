import 'package:flutter/foundation.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/data/models/app_notification_model.dart';
import 'package:green_miles_app/data/services/supabase_app_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  NotificationsViewModel(this._service) {
    fetchNotifications();
  }

  final SupabaseAppService _service;

  List<AppNotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isMarkingAllRead = false;
  String? _error;

  List<AppNotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isMarkingAllRead => _isMarkingAllRead;
  String? get error => _error;
  int get unreadCount => _notifications.where((item) => !item.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _service.fetchNotifications();
      _error = null;
    } catch (_) {
      _notifications = [];
      _error = AppStrings.notificationsLoadFailed;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markRead(AppNotificationModel notification) async {
    if (notification.isRead) {
      return;
    }

    final index = _notifications.indexWhere((item) => item.id == notification.id);
    if (index < 0) {
      return;
    }

    final previous = _notifications[index];
    _notifications[index] = AppNotificationModel(
      id: previous.id,
      title: previous.title,
      message: previous.message,
      type: previous.type,
      isRead: true,
      createdAt: previous.createdAt,
    );
    notifyListeners();

    try {
      await _service.markNotificationRead(notification.id);
    } catch (_) {
      _notifications[index] = previous;
      notifyListeners();
    }
  }

  Future<bool> markAllRead() async {
    if (_isMarkingAllRead || unreadCount == 0) {
      return true;
    }

    _isMarkingAllRead = true;
    notifyListeners();

    final previous = List<AppNotificationModel>.from(_notifications);
    _notifications = _notifications
        .map(
          (item) => AppNotificationModel(
            id: item.id,
            title: item.title,
            message: item.message,
            type: item.type,
            isRead: true,
            createdAt: item.createdAt,
          ),
        )
        .toList();
    notifyListeners();

    try {
      await _service.markAllNotificationsRead();
      return true;
    } catch (_) {
      _notifications = previous;
      return false;
    } finally {
      _isMarkingAllRead = false;
      notifyListeners();
    }
  }
}

