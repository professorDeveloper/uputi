class RoleUpdateRequest {
  final String role;
  const RoleUpdateRequest({required this.role});

  Map<String, dynamic> toJson() => {"role": role};
}
