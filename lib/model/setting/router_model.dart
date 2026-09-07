import 'dart:convert';

class RouterBrand {
  final int id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? description;
  final int routerCount;

  RouterBrand({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.description,
    required this.routerCount,
  });

  factory RouterBrand.fromJson(Map<String, dynamic> json) {
    return RouterBrand(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString(),
      description: json['description']?.toString(),
      routerCount: _toInt(json['router_count']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  String toString() {
    return 'RouterBrand('
        'id: $id, '
        'name: $name, '
        'slug: $slug, '
        'routerCount: $routerCount'
        ')';
  }
}

class RouterModel {
  final int id;
  final String name;
  final String modelNumber;
  final String? description;
  final List<String> supportedFeatures;
  final String defaultIp;
  final String defaultUsername;
  final int defaultPort;
  final String? iconUrl;

  RouterModel({
    required this.id,
    required this.name,
    required this.modelNumber,
    this.description,
    required this.supportedFeatures,
    required this.defaultIp,
    required this.defaultUsername,
    required this.defaultPort,
    this.iconUrl,
  });

  factory RouterModel.fromJson(Map<String, dynamic> json) {
    return RouterModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      modelNumber: json['model_number']?.toString() ?? '',
      description: json['description']?.toString(),
      supportedFeatures: _parseFeatures(json['supported_features']),
      defaultIp: json['default_ip']?.toString() ?? '192.168.1.1',
      defaultUsername: json['default_username']?.toString() ?? 'admin',
      defaultPort: _toInt(json['default_port'], fallback: 23),
      iconUrl: json['icon_url']?.toString(),
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static List<String> _parseFeatures(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    if (value is String) {
      try {
        final decoded = jsonDecode(value);

        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return [];
  }

  @override
  String toString() {
    return 'RouterModel('
        'id: $id, '
        'name: $name, '
        'modelNumber: $modelNumber, '
        'defaultIp: $defaultIp, '
        'defaultPort: $defaultPort'
        ')';
  }
}

class RouterModelsResponse {
  final List<RouterModel> routers;
  final int totalRouters;

  RouterModelsResponse({required this.routers, required this.totalRouters});

  factory RouterModelsResponse.fromJson(Map<String, dynamic> json) {
    final routersJson = json['routers'];

    return RouterModelsResponse(
      routers: routersJson is List
          ? routersJson
                .whereType<Map<String, dynamic>>()
                .map(RouterModel.fromJson)
                .toList()
          : [],
      totalRouters: int.tryParse(json['total_routers']?.toString() ?? '') ?? 0,
    );
  }
}
