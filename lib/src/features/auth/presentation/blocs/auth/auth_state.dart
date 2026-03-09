import 'package:equatable/equatable.dart';
import 'package:uputi/src/features/auth/data/models/auth_verify_response.dart';

class AuthState extends Equatable {
  static const Object _unset = Object();

  final bool loading;
  final String? error;
  final String? verificationId;
  final bool loggedIn;
  final AuthUser? user;
  final String? message;
  final String? accessToken;

  const AuthState({
    required this.loading,
    this.error,
    this.verificationId,
    this.user,
    this.message,
    this.loggedIn = false,
    this.accessToken,
  });

  factory AuthState.initial() => const AuthState(loading: false);

  AuthState copyWith({
    bool? loading,
    AuthUser? user,
    Object? error = _unset,
    Object? verificationId = _unset,
    Object? message = _unset,
    bool? loggedIn,
    Object? accessToken = _unset,
  }) {
    return AuthState(
      user: user == _unset ? this.user : user as AuthUser?,
      loading: loading ?? this.loading,
      error: error == _unset ? this.error : error as String?,
      verificationId: verificationId == _unset
          ? this.verificationId
          : verificationId as String?,
      message: message == _unset ? this.message : message as String?,
      loggedIn: loggedIn ?? this.loggedIn,
      accessToken: accessToken == _unset ? this.accessToken : accessToken as String?,
    );
  }

  @override
  List<Object?> get props => [loading, error, verificationId, loggedIn, message, user, accessToken];
}
