class BankModel {
  final int id;
  final String nameAr;
  final String nameEn;

  BankModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'],
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
    );
  }
}

class BankResponse {
  final bool success;
  final String message;
  final List<BankModel> data;

  BankResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BankResponse.fromJson(Map<String, dynamic> json) {
    return BankResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List)
          .map((e) => BankModel.fromJson(e))
          .toList(),
    );
  }
}