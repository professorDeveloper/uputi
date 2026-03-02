import 'package:equatable/equatable.dart';

abstract class RoleEvent extends Equatable {
  const RoleEvent();
  @override
  List<Object?> get props => [];
}

class RoleSelected extends RoleEvent {
  final String role;
  const RoleSelected({required this.role});

  @override
  List<Object?> get props => [role];
}
