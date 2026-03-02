
import '../../data/models/driver_history_resposne.dart';

abstract class DriverHistoryRepository {
  Future<DriverHistoryResponse> getDriverHistory({
    required int type,
    int page = 1,
  });
}