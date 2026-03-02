import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();
  @override
  List<Object?> get props => [];
}

class OtpVerifyPressed extends OtpEvent {
  final String verificationId;
  final String code;
  const OtpVerifyPressed({required this.verificationId, required this.code});

  @override
  List<Object?> get props => [verificationId, code];
}
