class UserModel {
  final int id;
  final String username;
  final String mobile;
  final List<String> userType;
  final String arabicName;
  final String phone;
  final int balance;
  final String status;
  final String expiryDate;
  final BaseService baseService;
  final Quota quota;
  final String arabicStatus;
  final List<Package> packages;
  final List<AddonService> addonServices;
  final String? token;
  final String? refreshToken;
  final int? tokenExpiry;
  final bool? fcmRegistered;
  final bool isExpired;
  UserModel({
    required this.id,
    required this.username,
    required this.mobile,
    required this.userType,
    required this.arabicName,
    required this.phone,
    required this.balance,
    required this.status,
    required this.expiryDate,
    required this.baseService,
    required this.isExpired,
    required this.quota,
    required this.arabicStatus,
    required this.packages,
    required this.addonServices,
    this.token,
    this.refreshToken,
    this.tokenExpiry,
    this.fcmRegistered,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _toInt(json['id']),
      username: _toString(json['username']),
      mobile: _toString(json['mobile']),
      userType: _toStringList(json['user_type']),
      arabicName: _toString(json['arabic_name']),
      phone: _toString(json['phone']),
      balance: _toInt(json['balance']),
      status: _toString(json['status']),
      expiryDate: _toString(json['expiry_date']),
      baseService: BaseService.fromJson(json['base_service']),
      quota: Quota.fromJson(json['quota']),
      packages: _toList(
        json['packages'],
      ).map((e) => Package.fromJson(e)).toList(),
      isExpired: json['is_expired'] == true,
      arabicStatus: _toString(json['arabic_status']),
      addonServices: _toList(
        json['addon_services'],
      ).map((e) => AddonService.fromJson(e)).toList(),
      token: json['token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      tokenExpiry:
          json['token_expiry'] != null ? _toInt(json['token_expiry']) : null,
      fcmRegistered: json['fcm_registered'] == true,
    );
  }

  static String _toString(dynamic value) {
    if (value == null) return "";
    return value.toString();
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static List _toList(dynamic value) {
    if (value == null || value is! List) return [];
    return value;
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null || value is! List) return [];
    return value.map((e) => e.toString()).toList();
  }
}

class BaseService {
  final int id;
  final int quota;
  final String itemType;
  final String name;
  final String label;
  final int regPrice;
  final bool unlimitted;

  BaseService({
    required this.id,
    required this.quota,
    required this.itemType,
    required this.name,
    required this.label,
    required this.regPrice,
    required this.unlimitted,
  });

  factory BaseService.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return BaseService(
        id: 0,
        quota: 0,
        itemType: "",
        name: "",
        label: "",
        regPrice: 0,
        unlimitted: false,
      );
    }

    return BaseService(
      id: UserModel._toInt(json['id']),
      quota: UserModel._toInt(json['quota']),
      itemType: UserModel._toString(json['item_type']),
      name: UserModel._toString(json['name']),
      label: UserModel._toString(json['label']),
      regPrice: UserModel._toInt(json['reg_price']),
      unlimitted: json['unlimitted'] == true,
    );
  }
}

class Quota {
  final int remainingCharged;
  final String currentSpeed;
  final int remainingDefault;
  final int totalExtra;
  final int totalRemain;
  final int totalUsage;
  final int totalUsagePercent;
  final String speed;

  Quota({
    required this.remainingCharged,
    required this.currentSpeed,
    required this.remainingDefault,
    required this.totalExtra,
    required this.totalRemain,
    required this.totalUsage,
    required this.totalUsagePercent,
    required this.speed,
  });

  factory Quota.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Quota(
        remainingCharged: 0,
        currentSpeed: "",
        remainingDefault: 0,
        totalExtra: 0,
        totalRemain: 0,
        totalUsage: 0,
        totalUsagePercent: 0,
        speed: "",
      );
    }

    return Quota(
      remainingCharged: UserModel._toInt(json['remaining_charged']),
      currentSpeed: UserModel._toString(json['current_speed']),
      remainingDefault: UserModel._toInt(json['remaining_default']),
      totalExtra: UserModel._toInt(json['total_extra']),
      totalRemain: UserModel._toInt(json['total_remain']),
      totalUsage: UserModel._toInt(json['total_usage']),
      totalUsagePercent: UserModel._toInt(json['total_usage_percent']),
      speed: UserModel._toString(json['speed']),
    );
  }
}

class Package {
  final String name;
  final int packagePercent;
  final int packageRemaining;
  final int packageLimit;
  final String createdAt;
  final String expireAt;

  Package({
    required this.name,
    required this.packagePercent,
    required this.packageRemaining,
    required this.packageLimit,
    required this.createdAt,
    required this.expireAt,
  });

  factory Package.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Package(
        name: "",
        packagePercent: 0,
        packageRemaining: 0,
        packageLimit: 0,
        createdAt: "",
        expireAt: "",
      );
    }

    return Package(
      name: UserModel._toString(json['name']),
      packagePercent: UserModel._toInt(json['package_percent']),
      packageRemaining: UserModel._toInt(json['package_remaining']),
      packageLimit: UserModel._toInt(json['package_limit']),
      createdAt: UserModel._toString(json['created_at']),
      expireAt: UserModel._toString(json['expire_at']),
    );
  }
}

class AddonService {
  final int id;
  final String itemType;
  final String name;
  final String nameAr;
  final int regPrice;

  AddonService({
    required this.id,
    required this.itemType,
    required this.name,
    required this.nameAr,
    required this.regPrice,
  });

  factory AddonService.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AddonService(
        id: 0,
        itemType: "",
        name: "",
        nameAr: "",
        regPrice: 0,
      );
    }

    return AddonService(
      id: UserModel._toInt(json['id']),
      itemType: UserModel._toString(json['item_type']),
      name: UserModel._toString(json['name']),
      nameAr: UserModel._toString(json['name_ar']),
      regPrice: UserModel._toInt(json['reg_price']),
    );
  }
}
