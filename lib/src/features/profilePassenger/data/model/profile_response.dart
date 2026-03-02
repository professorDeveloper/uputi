class ProfileResponse {
  final int id;
  final String? avatar;
  final String name;
  final String phone;
  final int? telegramChatId;
  final String role;
  final int? balance;
  final int? rating;
  final int? ratingCount;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;
  final Car? car;

  const ProfileResponse({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.avatar,
    this.telegramChatId,
    this.balance,
    this.rating,
    this.ratingCount,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.car,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: _asInt(json['id']),
      avatar: json['avatar']?.toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      telegramChatId: json['telegram_chat_id'] == null ? null : _asInt(json['telegram_chat_id']),
      role: (json['role'] ?? '').toString(),
      balance: json['balance'] == null ? null : _asInt(json['balance']),
      rating: json['rating'] == null ? null : _asInt(json['rating']),
      ratingCount: json['rating_count'] == null ? null : _asInt(json['rating_count']),
      deletedAt: json['deleted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      car: json['car'] == null ? null : Car.fromJson(json['car'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'avatar': avatar,
    'name': name,
    'phone': phone,
    'telegram_chat_id': telegramChatId,
    'role': role,
    'balance': balance,
    'rating': rating,
    'rating_count': ratingCount,
    'deleted_at': deletedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'car': car?.toJson(),
  };
}

class Car {
  final int id;
  final int? userId;
  final String model;
  final String color;
  final String number;
  final String? createdAt;
  final String? updatedAt;

  const Car({
    required this.id,
    required this.model,
    required this.color,
    required this.number,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: _asInt(json['id']),
      userId: json['user_id'] == null ? null : _asInt(json['user_id']),
      model: (json['model'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      number: (json['number'] ?? '').toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'model': model,
    'color': color,
    'number': number,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}
