class RoleUpdateResponse {
  final String message;
  final String role;

  const RoleUpdateResponse({
    required this.message,
    required this.role,
  });

  factory RoleUpdateResponse.fromJson(Map<String, dynamic> json) {
    return RoleUpdateResponse(
      message: (json["message"] ?? "").toString(),
      role: (json["role"] ?? "").toString(),
    );
  }

  bool get isSuccess => role.isNotEmpty;
}
