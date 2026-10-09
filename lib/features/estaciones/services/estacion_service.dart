// lib/features/estaciones_cultivo/services/estacion_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estacion_model.dart';

class EstacionService {
  final String baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1/estacion-cultivos/admin';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Obtiene la lista de estaciones de cultivo
  Future<List<EstacionModel>> fetchEstaciones({String? nombre}) async {
    final queryParams = <String, String>{};
    if (nombre != null && nombre.trim().isNotEmpty) {
      queryParams['nombre'] = nombre.trim();
    }

    final uri = Uri.parse(baseUrl).replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    print('================ [EstacionService] ================');
    print('🌐 REQUEST URL: $uri');

    try {
      final response = await http.get(uri, headers: _headers);

      print('📊 STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');
      print('==================================================');

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        List<dynamic> listData = [];

        if (decodedData is List) {
          listData = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          listData = decodedData['content'] ?? decodedData['data'] ?? [];
        }

        return listData.map((json) => EstacionModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar estaciones. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN EN EstacionService: $e');
      print('📍 STACKTRACE:\n$stackTrace');
      print('==================================================');
      rethrow;
    }
  }

  /// Crea una nueva estación de cultivo (POST /api/v1/estacion-cultivos/admin)
  Future<bool> crearEstacion(Map<String, dynamic> data) async {
    final uri = Uri.parse(baseUrl);

    print('🚀 [EstacionService] Creando estación en: $uri');
    print('📦 Body: ${jsonEncode(data)}');

    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(data),
      );

      print('📊 STATUS CODE POST: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Estación de cultivo creada con éxito');
        return true;
      } else {
        print('⚠️ Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN EN crearEstacion: $e');
      print('📍 STACKTRACE:\n$stackTrace');
      return false;
    }
  }

  /// Actualiza una estación de cultivo existente (PUT /api/v1/estacion-cultivos/admin/{id})
  Future<bool> actualizarEstacion(dynamic id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$id');

    print('🚀 [EstacionService] Actualizando estación en: $uri');
    print('📦 Body: ${jsonEncode(data)}');

    try {
      final response = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(data),
      );

      print('📊 STATUS CODE PUT: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Estación de cultivo actualizada con éxito');
        return true;
      } else {
        print('⚠️ Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN EN actualizarEstacion: $e');
      print('📍 STACKTRACE:\n$stackTrace');
      return false;
    }
  }
}