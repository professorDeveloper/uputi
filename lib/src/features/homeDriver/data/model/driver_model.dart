class DriverUserModel {
  final int? id;
  final String? name;
  final String? phone;
  final String? role;
  final int? balance;
  final int? telegramChatId;
  final double? rating;

  DriverUserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.balance,
    required this.telegramChatId,
    required this.rating,
  });

  factory DriverUserModel.fromJson(Map<String, dynamic> json) {
    return DriverUserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      telegramChatId: json['telegram_chat_id'],
      balance: json['balance'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}