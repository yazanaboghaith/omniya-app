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
    return ServicePackage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      regPrice: json['reg_price'] ?? '',
      actions: (json['actions'] as List?)
              ?.map((e) => ActionItem.fromJson(e))
              .toList() ??
          [],
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
  final AddAction? add;
  final AddAction? remove;

  ActionItem({
    this.add,
    this.remove,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      add: json['add'] != null ? AddAction.fromJson(json['add']) : null,
      remove:
          json['remove'] != null ? AddAction.fromJson(json['remove']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (add != null) 'add': add!.toJson(),
      if (remove != null) 'remove': remove!.toJson(),
    };
  }
}

class AddAction {
  final String method;
  final String url;
  final Map<String, dynamic> body;

  AddAction({
    required this.method,
    required this.url,
    required this.body,
  });

  factory AddAction.fromJson(Map<String, dynamic> json) {
    return AddAction(
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
