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

  AddonServiceModel({
    required this.id,
    required this.name,
    required this.regPrice,
  });

  factory AddonServiceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AddonServiceModel(id: 0, name: '', regPrice: '');
    }

    return AddonServiceModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      regPrice: json['reg_price']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
  }
}
