
import '../../domain/ds/fetch_driver_history_datasource.dart';
import '../../domain/repo/driver_history_repo.dart';
import '../models/driver_history_resposne.dart';

class DriverHistoryRepositoryImpl implements DriverHistoryRepository {
  final FetchDriverHistoryDataSource dataSource;

  DriverHistoryRepositoryImpl({required this.dataSource});

  @override
  Future<DriverHistoryResponse> getDriverHistory({
    required int type,
    int page = 1,
  }) {
    return dataSource.fetchDriverHistory(type: type, page: page);
  }
}