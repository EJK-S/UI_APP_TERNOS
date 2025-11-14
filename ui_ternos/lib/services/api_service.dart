// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'dart:convert'; // 👈 para utf8 y jsonDecode
import 'package:flutter/foundation.dart'; // kIsWeb

class ApiService {
  ApiService() {
    // ignore: avoid_print
    print('🌐 API baseUrl = $_baseUrl');
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }
  // ===============================
  // 🔧 Base URL compatible con Web
  // ===============================
  static String get _baseUrl {
    // 1) Si pasas --dart-define, se usa eso
    const defineUrl = String.fromEnvironment('API_URL');
    if (defineUrl.isNotEmpty) return defineUrl;

    // 2) Defaults por plataforma
    const prodUrl = 'https://backend-production-bc9e.up.railway.app/api';

    if (kIsWeb) {
      // Cuando corres en Chrome/Edge:
      // apunta al backend local en :3000 (ajústalo si usas otro puerto)
      final uri = Uri.base; // p.ej. http://localhost:59636/#/
      final host = uri.host.isEmpty ? 'localhost' : uri.host;
      final scheme = uri.scheme.isEmpty ? 'http' : uri.scheme;
      return '$scheme://$host:3000/api';
      // Si prefieres usar prod por defecto en Web, cambia la línea anterior por:
      // return prodUrl;
    }

    // En emulador Android: 10.0.2.2 → host
    // En dispositivo físico cambia a la IP de tu PC
    return const String.fromEnvironment(
      'API_URL_MOBILE',
      defaultValue: 'http://10.0.2.2:3000/api',
    );
  }

  // ===============================
  // ⚙️ Configuración de Dio
  // ===============================
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // ===============================
  // 👥 CLIENTES
  // ===============================

  Future<List<dynamic>> getClientes({String? search}) async {
    final qp = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) {
      qp['search'] = search.trim();
    }

    // Pedimos la respuesta como BYTES para evitar el problema de UTF-8 de Dio
    final res = await _dio.get(
      '/clientes',
      queryParameters: qp,
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = res.data as List<int>;

    // Decodificamos permitiendo caracteres mal formados (U+FFFD)
    final text = utf8.decode(bytes, allowMalformed: true);

    // Ahora parseamos el JSON nosotros
    final body = jsonDecode(text);

    // Soportamos tanto: [ {...}, {...} ] como { data: [ {...} ], ... }
    if (body is List) return body;
    if (body is Map && body['data'] is List) {
      return List.from(body['data']);
    }

    throw Exception('Formato inesperado en /clientes: $body');
  }

  Future<Map<String, dynamic>?> getCliente(String id) async {
    try {
      final res = await _dio.get('/clientes/$id');
      final body = res.data;
      if (body is Map<String, dynamic>) return body;
      if (body is Map && body['data'] is Map) {
        return Map<String, dynamic>.from(body['data']);
      }
      return null;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> createCliente(
    Map<String, dynamic> cliente,
  ) async {
    try {
      final response = await _dio.post('/clientes', data: cliente);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateCliente(
    String id,
    Map<String, dynamic> cliente,
  ) async {
    try {
      final response = await _dio.put('/clientes/$id', data: cliente);
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<bool> deleteCliente(String id) async {
    try {
      await _dio.delete('/clientes/$id');
      return true;
    } on DioException catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<Map<String, dynamic>?> updateVeto(
    String id,
    bool vetado,
    String motivo,
  ) async {
    try {
      final response = await _dio.patch(
        '/clientes/$id/veto',
        data: {'vetado': vetado, 'motivo_veto': motivo},
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // =========================================
  //                C I T A S
  // =========================================

  // GET /api/citas
  Future<List<dynamic>> getCitas() async {
    final res = await _dio.get('/citas');
    final data = res.data;
    if (data is List) {
      return data;
    }
    if (data is Map && data['data'] is List) {
      return List<dynamic>.from(data['data'] as List);
    }
    throw Exception('Respuesta inesperada al listar citas: $data');
  }

  // POST /api/citas
  Future<dynamic> createCita(Map<String, dynamic> body) async {
    final res = await _dio.post('/citas', data: body);
    return res.data; // el backend devuelve la cita creada
  }

  // PUT /api/citas/:id
  Future<dynamic> updateCita(String id, Map<String, dynamic> body) async {
    final res = await _dio.put('/citas/$id', data: body);
    return res.data;
  }

  // PATCH /api/citas/:id/estado
  Future<dynamic> updateEstadoCita(String id, String estado) async {
    final res = await _dio.patch('/citas/$id/estado', data: {'estado': estado});
    return res.data;
  }

  // DELETE /api/citas/:id
  Future<bool> deleteCita(String id) async {
    final res = await _dio.delete('/citas/$id');
    return res.statusCode == 200 || res.statusCode == 204;
  }

  // ===============================
  // ⚠️ Errores
  // ===============================
  void _handleError(DioException e) {
    if (e.response != null) {
      // ignore: avoid_print
      print('❌ Error ${e.response?.statusCode}: ${e.response?.data}');
    } else {
      // ignore: avoid_print
      print('⚠️ Error de conexión: ${e.message}');
    }
  }
}
