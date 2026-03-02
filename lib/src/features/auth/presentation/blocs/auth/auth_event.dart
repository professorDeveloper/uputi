import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStartPressed extends AuthEvent {
  final String name;
  final String phone; // 9-digit: 90xxxxxxx
  const AuthStartPressed({required this.name, required this.phone});

  @override
  List<Object?> get props => [name, phone];
}
