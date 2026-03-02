class AuthVerifyRequest {
  final String verificationId;
  final String code;

  AuthVerifyRequest({required this.verificationId, required this.code});

  Map<String, dynamic> toJson() => {
    "verification_id": verificationId,
    "code": code,
  };
}
