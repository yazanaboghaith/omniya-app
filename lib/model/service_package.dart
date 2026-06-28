class ServicePackage {
  final int id;
  final String name;
  final String regPrice;
  final List<ActionItem> actions;

  ServicePackage({
    required this.id,
    required this.name,
    required this.regPrice,
    required this.actions,
  });

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    List<ActionItem> parsedActions = [];

    if (json['actions'] != null) {
      if (json['actions'] is List) {
        parsedActions = (json['actions'] as List)
            .map((e) => ActionItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (json['actions'] is Map) {
        parsedActions = [
          ActionItem.fromJson(json['actions'] as Map<String, dynamic>)
        ];
      }
    }

    return ServicePackage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      regPrice: json['reg_price'] ?? '',
      actions: parsedActions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'reg_price': regPrice,
      'actions': actions.map((e) => e.toJson()).toList(),
    };
  }
}

class ActionItem {
  final ActionDetails? create;
  final ActionDetails? remove;

  ActionItem({
    this.create,
    this.remove,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      create: json['create'] != null
          ? ActionDetails.fromJson(json['create'])
          : null,
      remove: json['remove'] != null
          ? ActionDetails.fromJson(json['remove'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (create != null) 'create': create!.toJson(),
      if (remove != null) 'remove': remove!.toJson(),
    };
  }
}

class ActionDetails {
  final String method;
  final String url;
  final Map<String, dynamic> body;

  ActionDetails({
    required this.method,
    required this.url,
    required this.body,
  });

  factory ActionDetails.fromJson(Map<String, dynamic> json) {
    return ActionDetails(
      method: json['method'] ?? '',
      url: json['url'] ?? '',
      body: Map<String, dynamic>.from(json['body'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'url': url,
      'body': body,
    };
  }
}
