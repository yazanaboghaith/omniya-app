class TransactionModel {
  final int id;
  final String status;
  final String transType;
  final num amount;
  final String timestamp;

  TransactionModel({
    required this.id,
    required this.status,
    required this.transType,
    required this.amount,
    required this.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json["id"] ?? 0,
      status: json["status"] ?? "",
      transType: json["trans_type"] ?? "",
      amount: json["amount"] ?? 0,
      timestamp: json["timestamp"] ?? "",
    );
  }
}

class TransactionResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<TransactionModel> results;

  TransactionResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      count: json["count"] ?? 0,
      next: json["next"],
      previous: json["previous"],
      results: (json["results"] as List? ?? [])
          .map((e) => TransactionModel.fromJson(e))
          .toList(),
    );
  }
}
