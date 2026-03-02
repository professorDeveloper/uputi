import 'package:equatable/equatable.dart';
import '../../../data/models/auth_verify_response.dart';

class OtpState extends Equatable {
  final bool loading;
  final String? error;
  final String? message;
  final AuthUser? user;
  final String? accessToken;
  final String? tokenType;

  const OtpState({
    required this.loading,
    this.error,
    this.message,
    this.user,
    this.accessToken,
    this.tokenType,
  });

  factory OtpState.initial() => const OtpState(loading: false);

  OtpState copyWith({
    bool? loading,
    String? error,
    String? message,
    String? accessToken,
    AuthUser? user,
    String? tokenType,
  }) {
    return OtpState(
      loading: loading ?? this.loading,
      error: error,
      user: user ?? this.user,
      message: message ?? this.message,
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    error,
    message,
    accessToken,
    tokenType,
    user,
  ];
}
