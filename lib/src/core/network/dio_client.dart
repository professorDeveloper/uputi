import 'package:dio/dio.dart';

class DioClient {
  DioClient._();

  static Dio create() {
    return Dio(

      BaseOptions(
        baseUrl: "https://api.uputi.net",
        headers: {
          "accept": "application/json, text/plain, */*",
          "content-type": "application/json",
        },
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
  }
}
