class ServicesPackageResponse {
  final bool success;
  final String message;
  final List<ServicesPackage> data;

  ServicesPackageResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ServicesPackageResponse.fromJson(Map<String, dynamic> json) {
    return ServicesPackageResponse(
      success: json['success'] ?? false,
      message: (json['message'] ?? '').toString(),
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ServicesPackage.fromJson(e))
          .toList(),
    );
  }
}

class ServicesPackage {
  final int id;
  final String name;
  final String regPrice;

  ServicesPackage({
    required this.id,
    required this.name,
    required this.regPrice,
  });

  factory ServicesPackage.fromJson(Map<String, dynamic> json) {
    return ServicesPackage(
      id: _parseInt(json['id']),
      name: _safeString(json['name']),
      regPrice: _cleanPrice(json['reg_price']),
    );
  }

  // ================= helpers =================

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String _cleanPrice(dynamic value) {
    if (value == null) return '0';

    final str = value.toString().trim();

    if (str.isEmpty) return '0';

    return str;
  }
}
