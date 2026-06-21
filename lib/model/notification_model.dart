class NotificationModel {
  final bool success;
  final List<NotificationItem> data;
  final String message;
  final dynamic errors;
  final List<dynamic> filters;

  NotificationModel({
    required this.success,
    required this.data,
    required this.message,
    this.errors,
    required this.filters,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => NotificationItem.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
      errors: json['errors'],
      filters: json['filters'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
      'errors': errors,
      'filters': filters,
    };
  }
}

class NotificationItem {
  final int id;
  final String body;
  final String title;
  final String createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.body,
    required this.title,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      body: json['body'] ?? '',
      title: json['title'] ?? '',
      createdAt: json['created_at'] ?? '',
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'title': title,
      'created_at': createdAt,
      'is_read': isRead,
    };
  }
}
