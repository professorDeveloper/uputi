class AuthStartRequest {
  final String name;
  final String phone;

  AuthStartRequest({required this.name, required this.phone});

  Map<String, dynamic> toJson() => {"name": name, "phone": phone};
}
