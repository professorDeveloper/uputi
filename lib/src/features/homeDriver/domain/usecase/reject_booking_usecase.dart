import 'package:uputi/src/features/homeDriver/data/repo/home_repository_imp.dart';

import '../repo/home_driver_repository.dart';

class RejectDriverBookingUseCase {
  final HomeDriverRepository repository;

  RejectDriverBookingUseCase(this.repository);

  Future<String> call({required int bookingId}) =>
      repository.rejectBooking(bookingId);
}
