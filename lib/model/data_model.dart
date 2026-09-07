class DataModel {
  final List<PackageModel> prepaid;
  final List<PackageModel> postpaid;

  DataModel({
    required this.prepaid,
    required this.postpaid,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      prepaid: (json['prepaid'] as List<dynamic>? ?? [])
          .map(
            (e) => PackageModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      postpaid: (json['postpaid'] as List<dynamic>? ?? [])
          .map(
            (e) => PackageModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "prepaid": prepaid.map((e) => e.toJson()).toList(),
      "postpaid": postpaid.map((e) => e.toJson()).toList(),
    };
  }
}

class PackageModel {
  final int id;
  final String name;
  final String quota;
  final String regPrice;

  PackageModel({
    required this.id,
    required this.name,
    required this.quota,
    required this.regPrice,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      quota: json['quota']?.toString() ?? '',
      regPrice: json['reg_price']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "quota": quota,
      "reg_price": regPrice,
    };
  }
}
