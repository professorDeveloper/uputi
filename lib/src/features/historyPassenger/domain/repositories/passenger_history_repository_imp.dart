import 'package:uputi/src/features/historyPassenger/data/models/passenger_history_response.dart';

import '../../data/datasources/fetch_history_datasource.dart';
import '../../domain/repositories/passenger_history_repository.dart';

class PassengerHistoryRepositoryImpl implements PassengerHistoryRepository {
  final FetchHistoryDataSource dataSource;

  PassengerHistoryRepositoryImpl({required this.dataSource});

  @override
  Future<PassengerHistoryResponse> getPassengerHistory({
    required int type,
    int page = 1,
  }) {
    return dataSource.fetchPassengerHistory(type: type, page: page);
  }
}
