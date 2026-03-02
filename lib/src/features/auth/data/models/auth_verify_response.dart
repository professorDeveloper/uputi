class AuthUser {
  final int id;
  final String? avatar;
  final String name;
  final String phone;
  final int? telegramChatId;
  final String role;
  final num balance;
  final num rating;
  final int ratingCount;

  const AuthUser({
    required this.id,
    required this.avatar,
    required this.name,
    required this.phone,
    required this.telegramChatId,
    required this.role,
    required this.balance,
    required this.rating,
    required this.ratingCount,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json["id"] ?? 0) as int,
      avatar: json["avatar"]?.toString(),
      name: (json["name"] ?? "").toString(),
      phone: (json["phone"] ?? "").toString(),
      telegramChatId: json["telegram_chat_id"] is int
          ? json["telegram_chat_id"] as int
          : int.tryParse((json["telegram_chat_id"] ?? "").toString()),
      role: (json["role"] ?? "").toString(),
      balance: json["balance"] ?? 0,
      rating: json["rating"] ?? 0,
      ratingCount: (json["rating_count"] ?? 0) as int,
    );
  }
}

class AuthVerifyResponse {
  final String message;
  final String? accessToken;
  final String? tokenType;
  final AuthUser? user;

  const AuthVerifyResponse({
    required this.message,
    this.accessToken,
    this.tokenType,
    this.user,
  });

  bool get isSuccess => accessToken != null && accessToken!.isNotEmpty;

  factory AuthVerifyResponse.fromJson(Map<String, dynamic> json) {
    return AuthVerifyResponse(
      message: (json["message"] ?? "").toString(),
      accessToken: json["access_token"]?.toString(),
      tokenType: json["token_type"]?.toString(),
      user: json["user"] is Map<String, dynamic>
          ? AuthUser.fromJson(json["user"] as Map<String, dynamic>)
          : null,
    );
  }
}
