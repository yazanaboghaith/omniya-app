class DataModel {
  final List<PackageModel> prepaid;
  final PackageModel? postpaid;

  DataModel({required this.prepaid, this.postpaid});

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      prepaid: (json['prepaid'] as List<dynamic>)
          .map((e) => PackageModel.fromJson(e))
          .toList(),
      postpaid: json['postpaid'] != null
          ? PackageModel.fromJson(json['postpaid'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "prepaid": prepaid.map((e) => e.toJson()).toList(),
      "postpaid": postpaid?.toJson(),
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
      id: json['id'],
      name: json['name'],
      quota: json['quota'],
      regPrice: json['reg_price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "quota": quota, "reg_price": regPrice};
  }
}
