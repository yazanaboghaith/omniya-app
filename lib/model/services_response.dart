class AddonServiceResponse {
  final bool success;
  final List<AddonServiceModel> data;
  final String message;

  AddonServiceResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory AddonServiceResponse.fromJson(Map<String, dynamic> json) {
    return AddonServiceResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => AddonServiceModel.fromJson(e))
          .toList(),
    );
  }
}

class AddonServiceModel {
  final int id;
  final String name;
  final String regPrice;
  final Map<String, dynamic>? createAction;
  final Map<String, dynamic>? removeAction;

  AddonServiceModel({
    required this.id,
    required this.name,
    required this.regPrice,
    this.createAction,
    this.removeAction,
  });

  factory AddonServiceModel.fromJson(Map<String, dynamic> json) {
    final actions = json['actions'];

    Map<String, dynamic>? create;
    Map<String, dynamic>? remove;

    if (actions is Map<String, dynamic>) {
      // حالة create
      if (actions['create'] != null) {
        create = actions['create'];
      }
    }

    if (actions is List) {
      // حالة remove داخل list
      for (final item in actions) {
        if (item is Map && item['remove'] != null) {
          remove = item['remove'];
        }
      }
    }

    return AddonServiceModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      regPrice: json['reg_price']?.toString() ?? '',
      createAction: create,
      removeAction: remove,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(
          value.toString().replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
  }

  /// helpers
  String? get actionUrl {
    final action = createAction ?? removeAction;
    if (action == null) return null;
    return action['url'];
  }

  Map<String, dynamic>? get actionBody {
    final action = createAction ?? removeAction;
    if (action == null) return null;
    return action['body'];
  }

  String get actionMethod {
    final action = createAction ?? removeAction;
    if (action == null) return '';
    return action['method'] ?? '';
  }
}
