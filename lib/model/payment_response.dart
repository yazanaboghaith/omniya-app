class PaymentResponse {
  final bool success;
  final bool data;
  final String message;
  final dynamic errors;
  final List<dynamic> filters;

  PaymentResponse({
    required this.success,
    required this.data,
    required this.message,
    required this.errors,
    required this.filters,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      data: json['data'] ?? false,
      message: json['message'] ?? '',
      errors: json['errors'],
      filters: json['filters'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'errors': errors,
      'filters': filters,
    };
  }
}
