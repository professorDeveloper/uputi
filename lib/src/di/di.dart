import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:uputi/src/features/createTrip/data/datasources/trip_remote_datasource.dart';
import 'package:uputi/src/features/createTrip/domain/usecases/create_trip_usecase.dart';
import 'package:uputi/src/features/createTrip/presentation/blocs/trip_create_bloc.dart';
import 'package:uputi/src/features/historyPassenger/data/datasources/fetch_history_datasource.dart';
import 'package:uputi/src/features/historyPassenger/data/datasources/fetch_history_datasource_imp.dart';
import 'package:uputi/src/features/historyPassenger/domain/repositories/passenger_history_repository.dart';
import 'package:uputi/src/features/historyPassenger/domain/repositories/passenger_history_repository_imp.dart';
import 'package:uputi/src/features/historyPassenger/domain/usecases/get_passenger_history_usecase.dart';
import 'package:uputi/src/features/homeDriver/data/datasource/accept_booking_datsource_imp.dart';
import 'package:uputi/src/features/homeDriver/data/datasource/reject_booking_datasource_imp.dart';
import 'package:uputi/src/features/homeDriver/domain/ds/accept_booking_datasource.dart';
import 'package:uputi/src/features/homeDriver/domain/ds/reject_booking_datasource.dart';
import 'package:uputi/src/features/homeDriver/domain/usecase/accept_booking_usecase.dart';
import 'package:uputi/src/features/homeDriver/domain/usecase/complete_my_bookings_trip_usecase.dart';
import 'package:uputi/src/features/homeDriver/domain/usecase/get_active_trips_usecase.dart';
import 'package:uputi/src/features/homeDriver/domain/usecase/reject_booking_usecase.dart';
import 'package:uputi/src/features/homePassenger/data/datasources/cancel_trip_data_source.dart';
import 'package:uputi/src/features/homePassenger/data/datasources/create_booking_data_source.dart';
import 'package:uputi/src/features/homePassenger/data/datasources/create_booking_data_source_imp.dart';
import 'package:uputi/src/features/homePassenger/data/datasources/in_progress_data_source_imp.dart';
import 'package:uputi/src/features/homePassenger/data/datasources/offered_data_source_imp.dart';
import 'package:uputi/src/features/homePassenger/data/datasources/offered_price_data_source.dart';
import 'package:uputi/src/features/homePassenger/data/datasources/my_trips_datasource_imp.dart';
import 'package:uputi/src/features/homePassenger/domain/usecases/cancel_my_trip_usecase.dart';
import 'package:uputi/src/features/homePassenger/domain/usecases/create_booking_use_case.dart';
import 'package:uputi/src/features/homePassenger/domain/usecases/get_my_trips_for_passenger_usecase.dart';
import 'package:uputi/src/features/homePassenger/domain/usecases/offer_price_use_case.dart';
import 'package:uputi/src/features/profilePassenger/domain/repository/profile_repository.dart';
import 'package:uputi/src/features/profilePassenger/domain/repository/profile_repository_imp.dart';
import 'package:uputi/src/features/searchPassenger/data/datasources/filter_in_citys_datasource.dart';
import 'package:uputi/src/features/searchPassenger/domain/usecases/search_trips_by_location_usecase.dart';
import 'package:uputi/src/features/searchPassenger/presentation/blocs/city_search_bloc.dart';
import '../core/network/dio_client.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource_imp.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository_imp.dart';
import '../features/auth/domain/usecases/start_auth_usecase.dart';
import '../features/auth/domain/usecases/update_role_usecase.dart';
import '../features/auth/domain/usecases/verify_auth_usecase.dart';
import '../features/auth/presentation/blocs/auth/auth_bloc.dart';
import '../features/auth/presentation/blocs/auth/otp_bloc.dart';
import '../features/auth/presentation/blocs/auth/role_bloc.dart';
import '../features/createTrip/data/datasources/geo_code_data_source.dart';
import '../features/createTrip/domain/repositories/create_trip_repository.dart';
import '../features/createTrip/domain/repositories/create_trip_repository_imp.dart';
import '../features/createTrip/domain/usecases/reverse_geocode_usecase.dart';
import '../features/createTrip/presentation/blocs/choose_direction_bloc.dart';
import '../features/createTripDriver/data/datasource/trip_remote_datasource_imp.dart';
import '../features/createTripDriver/data/repo/create_trip_repo_imp.dart';
import '../features/createTripDriver/domain/ds/trip_remote_datasource.dart';
import '../features/createTripDriver/domain/repo/driver_create_trip_repo.dart';
import '../features/createTripDriver/domain/usecase/driver_create_trip_usecase.dart';
import '../features/createTripDriver/domain/usecase/driver_geocode_usecase.dart';
import '../features/createTripDriver/presentation/bloc/create_trip_bloc.dart';
import '../features/historyDriver/data/datasources/fetch_driver_history_ds_imp.dart';
import '../features/historyDriver/data/repos/driver_history_repo.dart';
import '../features/historyDriver/domain/ds/fetch_driver_history_datasource.dart';
import '../features/historyDriver/domain/repo/driver_history_repo.dart';
import '../features/historyDriver/domain/usecase/get_driver_history_usecase.dart';
import '../features/historyDriver/presentation/bloc/history_bloc.dart';
import '../features/historyPassenger/presentation/blocs/history_bloc.dart';
import '../features/homeDriver/data/datasource/cancel_booking_datasource_imp.dart';
import '../features/homeDriver/data/datasource/complete_trip_datasource_imp.dart';
import '../features/homeDriver/data/datasource/create_booking_driver_datasource_imp.dart';
import '../features/homeDriver/data/datasource/driver_active_trips_datasource_imp.dart';
import '../features/homeDriver/data/datasource/driver_in_progress_datasource_imp.dart';
import '../features/homeDriver/data/datasource/driver_my_trips_datasource_imp.dart';
import '../features/homeDriver/data/datasource/driver_user_datasource_imp.dart';
import '../features/homeDriver/data/repo/home_repository_imp.dart';
import '../features/homeDriver/domain/ds/cancel_booking_driver_datasource.dart';
import '../features/homeDriver/domain/ds/complete_trip_datasource.dart';
import '../features/homeDriver/domain/ds/create_booking_driver_datasource.dart';
import '../features/homeDriver/domain/ds/driver_active_trips_datasource.dart';
import '../features/homeDriver/domain/ds/driver_in_progress_datasource.dart';
import '../features/homeDriver/domain/ds/driver_my_trips_datasource.dart';
import '../features/homeDriver/domain/ds/driver_user_datasource.dart';
import '../features/homeDriver/domain/repo/home_driver_repository.dart';
import '../features/homeDriver/domain/usecase/cancel_booking_usecase.dart';
import '../features/homeDriver/domain/usecase/complete_trip_usecase.dart';
import '../features/homeDriver/domain/usecase/create_booking_usecase.dart';
import '../features/homeDriver/domain/usecase/get_driver_booking_usecase.dart';
import '../features/homeDriver/domain/usecase/get_driver_my_trips_usecase.dart';
import '../features/homeDriver/domain/usecase/get_driver_usecase.dart';
import '../features/homeDriver/presentation/bloc/home_bloc.dart';
import '../features/homePassenger/data/datasources/cancel_mytrip_datasource.dart';
import '../features/homePassenger/data/datasources/cancel_trip_data_source_imp.dart';
import '../features/homePassenger/data/datasources/get_user_data_source.dart';
import '../features/homePassenger/data/datasources/home_passenger_data_source.dart';
import '../features/homePassenger/data/datasources/home_passenger_data_source_imp.dart';
import '../features/homePassenger/data/datasources/in_progress_data_source.dart';
import '../features/homePassenger/data/datasources/my_trip_datasource.dart';
import '../features/homePassenger/data/datasources/user_remote_data_source_imp.dart';
import '../features/homePassenger/domain/repositories/home_passenger_repository.dart';
import '../features/homePassenger/domain/repositories/home_passenger_repository_imp.dart';
import '../features/homePassenger/domain/usecases/cancel_booking_use_case.dart';
import '../features/homePassenger/domain/usecases/get_active_trip_usecase.dart';
import '../features/homePassenger/domain/usecases/get_my_bookings_usecase.dart';
import '../features/homePassenger/domain/usecases/get_user_use_case.dart';
import '../features/homePassenger/presentation/bloc/home_passenger_bloc.dart';
import '../features/profilePassenger/data/datasources/get_profile_response_datasource.dart';
import '../features/profilePassenger/data/datasources/get_profile_response_datasource_imp.dart';
import '../features/profilePassenger/domain/usecase/get_profile_usecase.dart';
import '../features/profilePassenger/presentation/blocs/profile_bloc.dart';
import '../features/searchDriver/data/ds/city_search_datasource.dart';
import '../features/searchDriver/data/ds/region_search_datasource.dart';
import '../features/searchDriver/data/repo/search_repo_imp.dart';
import '../features/searchDriver/domain/repo/search_repository.dart';
import '../features/searchDriver/domain/usecases/search_driver_by_location_usecase.dart';
import '../features/searchDriver/domain/usecases/search_driver_usecase.dart';
import '../features/searchDriver/presentation/bloc/driver_city_search_bloc.dart';
import '../features/searchDriver/presentation/bloc/driver_search_trips_bloc.dart';
import '../features/searchPassenger/data/datasources/filter_in_religions_datasource.dart';
import '../features/searchPassenger/domain/repositories/search_passenger_repository.dart';
import '../features/searchPassenger/domain/repositories/search_passenger_repository_imp.dart';
import '../features/searchPassenger/domain/usecases/search_passenger_usecase.dart';
import '../features/searchPassenger/presentation/blocs/search_trips_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  sl.registerLazySingleton<Dio>(() {
    var create = DioClient.create();
    return create;
  });

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<MyTripsDataSource>(
    () => MyTripsDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<OfferPriceDataSource>(
    () => OfferPriceDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<StartAuthUseCase>(
    () => StartAuthUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<CreateTripUseCase>(
    () => CreateTripUseCase(sl<CreateTripRepository>()),
  );

  sl.registerLazySingleton<VerifyAuthUseCase>(
    () => VerifyAuthUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetMyTripsForPassengerUseCase>(
    () => GetMyTripsForPassengerUseCase(sl<HomePassengerRepository>()),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<StartAuthUseCase>()));
  sl.registerFactory<OtpBloc>(() => OtpBloc(sl<VerifyAuthUseCase>()));
  sl.registerLazySingleton(() => UpdateRoleUseCase(sl()));
  sl.registerLazySingleton(() => OfferPriceUseCase(sl()));
  sl.registerFactory(() => RoleBloc(sl()));
  sl.registerFactory<TripCreateBloc>(
    () => TripCreateBloc(createTrip: sl<CreateTripUseCase>()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<HomePassengerRepository>(
    () => HomePassengerRepositoryImpl(
      passengersTripDs: sl<MyTripsDataSource>(),
      cancelMyTripDs: sl<CancelMyTripDataSource>(),
      createBookingDS: sl<CreateBookingDataSource>(),
      userDS: sl<UserRemoteDataSource>(),
      bookingDS: sl<BookingRemoteDataSource>(),
      tripsDS: sl<HomePassengerDataSource>(),
      cancelTripDS: sl<CancelTripDataSource>(),
      offerPriceDataSource: sl<OfferPriceDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetUserUseCase>(
    () => GetUserUseCase(sl<HomePassengerRepository>()),
  );

  sl.registerLazySingleton<GetMyBookingsUseCase>(
    () => GetMyBookingsUseCase(sl<HomePassengerRepository>()),
  );
  sl.registerLazySingleton<CreateBookingUseCase>(
    () => CreateBookingUseCase(sl<HomePassengerRepository>()),
  );

  sl.registerLazySingleton<GetActiveTripsUseCase>(
    () => GetActiveTripsUseCase(sl<HomePassengerRepository>()),
  );
  sl.registerLazySingleton<CancelBookingUseCase>(
    () => CancelBookingUseCase(sl<HomePassengerRepository>()),
  );

  sl.registerLazySingleton<CancelMyTripUseCase>(
    () => CancelMyTripUseCase(sl<HomePassengerRepository>()),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => InProgressDataSourceImp(sl<Dio>()),
  );
  sl.registerLazySingleton<CreateBookingDataSource>(
    () => CreateBookingDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<CancelTripDataSource>(
    () => CancelTripDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<TripRemoteDataSource>(
    () => TripRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<CancelMyTripDataSource>(
    () => CancelMyTripDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<HomePassengerDataSource>(
    () => HomePassengerDataSourceImpl(sl<Dio>()),
  );
  sl.registerFactory<HomePassengerBloc>(
    () => HomePassengerBloc(
      offerPrice: sl<OfferPriceUseCase>(),
      createBooking: sl<CreateBookingUseCase>(),
      cancelBooking: sl<CancelBookingUseCase>(),
      getUser: sl<GetUserUseCase>(),
      getBookings: sl<GetMyBookingsUseCase>(),
      getTrips: sl<GetActiveTripsUseCase>(),
      getMyTrips: sl<GetMyTripsForPassengerUseCase>(),
      cancelMyTrip: sl<CancelMyTripUseCase>(),
    ),
  );
  sl.registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(sl()));
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(getProfile: sl(), dio: sl()),
  );

  sl.registerLazySingleton<FetchHistoryDataSource>(
    () => FetchHistoryDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<PassengerHistoryRepository>(
    () => PassengerHistoryRepositoryImpl(
      dataSource: sl<FetchHistoryDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetProfileResponseDatasource>(
    () => GetProfileResponseDatasourceImp(sl<Dio>()),
  );

  sl.registerLazySingleton<GetPassengerHistoryUseCase>(
    () => GetPassengerHistoryUseCase(sl<PassengerHistoryRepository>()),
  );

  sl.registerFactory<HistoryBloc>(
    () => HistoryBloc(getHistory: sl<GetPassengerHistoryUseCase>()),
  );

  sl.registerLazySingleton<GeoCodeDataSource>(
    () => GeoCodeDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImp(dataSource: sl<GetProfileResponseDatasource>()),
  );
  sl.registerLazySingleton<CreateTripRepository>(
    () => CreateTripRepositoryImpl(sl(), sl<TripRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => ReverseGeocodeUseCase(sl()));

  sl.registerFactory(
    () => ChooseDirectionsBloc(
      reverse: sl(),
      initialLat: 41.2342,
      initialLng: 69.2157,
    ),
  );
  sl.registerLazySingleton<TripsSearchRemoteDataSource>(
    () => TripsSearchDataSourceImp(sl<Dio>()),
  );
  sl.registerLazySingleton<CityTripsRemoteDataSource>(
    () => CityTripsRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<SearchPassengerRepository>(
    () => SearchPassengerRepositoryImp(
      sl<TripsSearchRemoteDataSource>(),
      sl<CityTripsRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<SearchPassengerUseCase>(
    () => SearchPassengerUseCase(sl<SearchPassengerRepository>()),
  );

  sl.registerLazySingleton<SearchTripsByLocationUsecase>(
    () => SearchTripsByLocationUsecase(sl<SearchPassengerRepository>()),
  );

  sl.registerLazySingleton<DriverUserRemoteDataSource>(
    () => DriverUserRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<DriverInProgressDataSource>(
    () => DriverInProgressDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<HomeDriverDataSource>(
    () => HomeDriverDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<DriverMyTripsDataSource>(
    () => DriverMyTripsDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<CreateDriverBookingDataSource>(
    () => CreateDriverBookingDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<CancelDriverBookingDataSource>(
    () => CancelDriverBookingDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<CompleteTripDataSource>(
    () => CompleteTripDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AcceptDriverBookingDataSource>(
    () => AcceptDriverBookingDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<RejectDriverBookingDataSource>(
    () => RejectDriverBookingDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<HomeDriverRepository>(
    () => HomeDriverRepositoryImpl(
      rejectBookingDs: sl<RejectDriverBookingDataSource>(),
      acceptBookingDS: sl<AcceptDriverBookingDataSource>(),
      userDS: sl<DriverUserRemoteDataSource>(),
      inProgressDS: sl<DriverInProgressDataSource>(),
      tripsDS: sl<HomeDriverDataSource>(),
      myTripsDS: sl<DriverMyTripsDataSource>(),
      createBookingDS: sl<CreateDriverBookingDataSource>(),
      cancelBookingDS: sl<CancelDriverBookingDataSource>(),
      completeTripDS: sl<CompleteTripDataSource>(),
    ),
  );

  sl.registerLazySingleton<FetchDriverHistoryDataSource>(
    () => FetchDriverHistoryDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<DriverHistoryRepository>(
    () => DriverHistoryRepositoryImpl(
      dataSource: sl<FetchDriverHistoryDataSource>(),
    ),
  );
  sl.registerLazySingleton<DriverTripRemoteDataSource>(
    () => DriverTripRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<DriverCreateTripRepository>(
    () => DriverCreateTripRepositoryImpl(
      sl<GeoCodeDataSource>(),
      sl<DriverTripRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<DriverReverseGeocodeUseCase>(
    () => DriverReverseGeocodeUseCase(sl<DriverCreateTripRepository>()),
  );
  sl.registerLazySingleton<DriverCreateTripUseCase>(
    () => DriverCreateTripUseCase(sl<DriverCreateTripRepository>()),
  );
  sl.registerFactory<DriverTripCreateBloc>(
    () => DriverTripCreateBloc(createTrip: sl<DriverCreateTripUseCase>()),
  );

  sl.registerLazySingleton<GetDriverHistoryUseCase>(
    () => GetDriverHistoryUseCase(sl<DriverHistoryRepository>()),
  );

  sl.registerFactory<DriverHistoryBloc>(
    () => DriverHistoryBloc(getHistory: sl<GetDriverHistoryUseCase>()),
  );

  sl.registerLazySingleton<GetDriverUserUseCase>(
    () => GetDriverUserUseCase(sl<HomeDriverRepository>()),
  );
  sl.registerLazySingleton<GetDriverBookingsUseCase>(
    () => GetDriverBookingsUseCase(sl<HomeDriverRepository>()),
  );
  sl.registerLazySingleton<GetActiveDriverTripsUseCase>(
    () => GetActiveDriverTripsUseCase(sl<HomeDriverRepository>()),
  );
  sl.registerLazySingleton<CreateDriverBookingUseCase>(
    () => CreateDriverBookingUseCase(sl<HomeDriverRepository>()),
  );
  sl.registerLazySingleton<CancelDriverBookingUseCase>(
    () => CancelDriverBookingUseCase(sl<HomeDriverRepository>()),
  );
  sl.registerLazySingleton<CompleteTripUseCase>(
    () => CompleteTripUseCase(sl<HomeDriverRepository>()),
  );
  sl.registerLazySingleton<AcceptDriverBookingUseCase>(
    () => AcceptDriverBookingUseCase(sl<HomeDriverRepository>()),
  );
  sl.registerLazySingleton<RejectDriverBookingUseCase>(
    () => RejectDriverBookingUseCase(sl<HomeDriverRepository>()),
  );
  sl.registerLazySingleton<GetDriverMyTripsUseCase>(
    () => GetDriverMyTripsUseCase(sl<HomeDriverRepository>()),
  );

  sl.registerLazySingleton<CompleteMyBookingsTripUsecase>(
    () => CompleteMyBookingsTripUsecase(sl<HomeDriverRepository>()),
  );
  sl.registerFactory<HomeDriverBloc>(
    () => HomeDriverBloc(
      getUser: sl<GetDriverUserUseCase>(),
      getBookings: sl<GetDriverBookingsUseCase>(),
      getTrips: sl<GetActiveDriverTripsUseCase>(),
      createBooking: sl<CreateDriverBookingUseCase>(),
      cancelBooking: sl<CancelDriverBookingUseCase>(),
      completeTrip: sl<CompleteTripUseCase>(),
      getMyTrips: sl<GetDriverMyTripsUseCase>(),
      acceptBooking: sl<AcceptDriverBookingUseCase>(),
      rejectBooking: sl<RejectDriverBookingUseCase>(),
      completeMyBookingsTripUsecase: sl<CompleteMyBookingsTripUsecase>(),
    ),
  );

  sl.registerFactory<SearchTripsBloc>(
    () => SearchTripsBloc(
      searchTrips: sl<SearchPassengerUseCase>(),
      createBooking: sl<CreateBookingUseCase>(),
      offerPrice: sl<OfferPriceUseCase>(),
    ),
  );

  sl.registerFactory<CitySearchBloc>(
    () => CitySearchBloc(searchByLocation: sl<SearchTripsByLocationUsecase>()),
  );
  sl.registerLazySingleton<DriverRegionSearchRemoteDataSource>(
    () => DriverRegionSearchRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<DriverCitySearchRemoteDataSource>(
    () => DriverCitySearchRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<SearchDriverRepository>(
    () => SearchDriverRepositoryImpl(
      sl<DriverRegionSearchRemoteDataSource>(),
      sl<DriverCitySearchRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<SearchDriverPassengersUseCase>(
    () => SearchDriverPassengersUseCase(sl<SearchDriverRepository>()),
  );
  sl.registerLazySingleton<SearchDriverByLocationUseCase>(
    () => SearchDriverByLocationUseCase(sl<SearchDriverRepository>()),
  );

  sl.registerFactory<DriverSearchTripsBloc>(
    () => DriverSearchTripsBloc(
      searchPassengers: sl<SearchDriverPassengersUseCase>(),
      createBooking: sl<CreateDriverBookingUseCase>(),
    ),
  );
  sl.registerFactory<DriverCitySearchBloc>(
    () => DriverCitySearchBloc(
      searchByLocation: sl<SearchDriverByLocationUseCase>(),
    ),
  );

  await dotenv.load(fileName: '.env');
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
}
