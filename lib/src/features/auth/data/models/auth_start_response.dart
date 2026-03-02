import 'auth_verify_response.dart';

class AuthStartResponse {
  final String message;
  final String verificationId;

  final String? accessToken;
  final String? tokenType;
  final AuthUser? user;

  const AuthStartResponse({
    required this.message,
    required this.verificationId,
    this.accessToken,
    this.tokenType,
    this.user,
  });

  bool get requiresOtp => verificationId.isNotEmpty;

  bool get isLoggedIn => (accessToken ?? "").isNotEmpty;

  bool get isSuccess => requiresOtp || isLoggedIn;


  String toJson() {
    return '''
    {
      "message": "$message",
      "verification_id": "$verificationId",
      "access_token": "${accessToken ?? ""}",
      "token_type": "${tokenType ?? ""}",
      "user": ${user != null ? '''
        {
          "id": ${user!.id},
          "avatar": "${user!.avatar ?? ""}",
          "name": "${user!.name}",
          "phone": "${user!.phone}",
          "telegram_chat_id": ${user!.telegramChatId ?? "null"},
          "role": "${user!.role}",
          "balance": ${user!.balance},
          "rating": ${user!.rating},
          "rating_count": ${user!.ratingCount}
        }
      ''' : "null"}
    }
    ''';
  }

  factory AuthStartResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json["user"];
    return AuthStartResponse(
      message: (json["message"] ?? "").toString(),
      verificationId: (json["verification_id"] ?? "").toString(),
      accessToken: (json["access_token"] ?? "").toString().isEmpty
          ? null
          : (json["access_token"] ?? "").toString(),
      tokenType: (json["token_type"] ?? "").toString().isEmpty
          ? null
          : (json["token_type"] ?? "").toString(),
      user: (userJson is Map)
          ? AuthUser.fromJson(Map<String, dynamic>.from(userJson))
          : null,
    );
  }
}
