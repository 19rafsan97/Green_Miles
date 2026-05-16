class AppNotificationModel {
  AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotificationModel.fromSupabase(Map<String, dynamic> data) {
    return AppNotificationModel(
      id: _toInt(data['id']),
      title: (data['title'] ?? '').toString(),
      message: (data['message'] ?? '').toString(),
      type: (data['type'] ?? 'general').toString(),
      isRead: data['is_read'] == true,
      createdAt: DateTime.tryParse((data['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

