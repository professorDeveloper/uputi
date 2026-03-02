import 'package:uputi/src/features/auth/data/models/auth_verify_response.dart';

class DevLoginResponse {
  final String message;
  final String accessToken;
  final String tokenType;
  final AuthUser user;

  DevLoginResponse({
    required this.message,
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory DevLoginResponse.fromJson(Map<String, dynamic> json) {
    return DevLoginResponse(
      message: json["message"] as String? ?? "",
      accessToken: json["access_token"] as String,
      tokenType: json["token_type"] as String? ?? "Bearer",
      user: AuthUser.fromJson(Map<String, dynamic>.from(json["user"] as Map)),
    );
  }
}
