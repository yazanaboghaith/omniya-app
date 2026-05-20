class OrdersResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<OrderModel> results;

  OrdersResponseModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  int get totalPages => (count / 10).ceil();

  bool get hasNextPage => next != null;

  bool get hasPreviousPage => previous != null;

  factory OrdersResponseModel.fromJson(Map<String, dynamic> json) {
    return OrdersResponseModel(
      count: json['count'] ?? 0,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => OrderModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderModel {
  final String orderType;
  final String service;
  final String status;
  final String timestamp;

  OrderModel({
    required this.orderType,
    required this.service,
    required this.status,
    required this.timestamp,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderType: json['order_type']?.toString() ?? '',
      service: json['service']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_type': orderType,
      'service': service,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
