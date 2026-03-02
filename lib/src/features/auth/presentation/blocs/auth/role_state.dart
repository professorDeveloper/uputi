import 'package:equatable/equatable.dart';

class RoleState extends Equatable {
  final bool loading;
  final String? error;
  final bool success;
  final String? role;
  final String? message;

  const RoleState({
    required this.loading,
    this.error,
    required this.success,
    this.role,
    this.message,
  });

  factory RoleState.initial() => const RoleState(
    loading: false,
    success: false,
  );

  RoleState copyWith({
    bool? loading,
    String? error,
    bool? success,
    String? role,
    String? message,
  }) {
    return RoleState(
      loading: loading ?? this.loading,
      error: error,
      success: success ?? this.success,
      role: role ?? this.role,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [loading, error, success, role, message];
}
