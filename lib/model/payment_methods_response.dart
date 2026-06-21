class PaymentMethodsResponse {
  final bool success;
  final List<PaymentMethod> data;
  final String? message;
  final dynamic errors;
  final List<dynamic> filters;

  PaymentMethodsResponse({
    required this.success,
    required this.data,
    this.message,
    this.errors,
    required this.filters,
  });

  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodsResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => PaymentMethod.fromJson(e))
              .toList() ??
          [],
      message: json['message']?.toString(),
      errors: json['errors'],
      filters: json['filters'] ?? [],
    );
  }
}

class PaymentMethod {
  final String name;
  final String value;
  final String icon;
  final bool externalBrowser;

  PaymentMethod({
    required this.name,
    required this.value,
    required this.icon,
    required this.externalBrowser,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      name: (json['name'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
      externalBrowser: json['external_browser'] ?? false,
    );
  }
}
