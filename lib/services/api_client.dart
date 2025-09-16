// ignore: depend_on_referenced_packages
import 'package:dio/dio.dart';
import '../config.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: backendBaseUrl,
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {
      'x-device-key': deviceApiKey,
    },
  ));

  Future<({String code, DateTime expiresAt})> fetchKioskCode() async {
    final res = await _dio.get('/kiosk/qr');
    final data = res.data as Map<String, dynamic>;
    final code = data['code'] as String;
    final expiresAt = DateTime.parse(data['expiresAt'] as String).toLocal();
    return (code: code, expiresAt: expiresAt);
  }
}
