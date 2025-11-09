import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static final String baseUrl = kIsWeb
      ? "http://localhost:3000/api"
      : "http://10.0.2.2:3000/api";

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {"Content-Type": "application/json"},
            validateStatus: (s) => s != null && s >= 200 && s < 400,
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onError: (e, h) {
              // print("DIO ERROR => ${e.response?.statusCode} ${e.requestOptions.uri} ${e.response?.data}");
              return h.next(e);
            },
          ),
        );

  static Future<List<Map<String, dynamic>>> listarClientes() async {
    final r = await _dio.get('/clientes');
    final data = r.data;
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  static Future<Map<String, dynamic>> crearCliente(
    Map<String, dynamic> json,
  ) async {
    final r = await _dio.post('/clientes', data: json);
    if (r.data is Map) return (r.data as Map).cast<String, dynamic>();
    // si el backend devuelve 201 sin cuerpo, devolvemos lo enviado
    return (json..remove('id'));
  }

  /// Intenta PUT, y si tu backend usa PATCH, lo intenta automáticamente.
  /// Soporta 200 con JSON o 204 sin contenido.
  static Future<Map<String, dynamic>?> actualizarCliente(
    int id,
    Map<String, dynamic> json,
  ) async {
    Response r;
    try {
      r = await _dio.put('/clientes/$id', data: json);
    } on DioException catch (e) {
      // Si PUT no existe pero PATCH sí:
      if (e.response?.statusCode == 404) {
        r = await _dio.patch('/clientes/$id', data: json);
      } else {
        rethrow;
      }
    }
    if (r.statusCode == 204 ||
        r.data == null ||
        (r.data is String && (r.data as String).isEmpty)) {
      return null; // éxito sin cuerpo
    }
    if (r.data is Map) return (r.data as Map).cast<String, dynamic>();
    return null;
  }

  static Future<void> eliminarCliente(int id) async {
    await _dio.delete('/clientes/$id');
  }
}
