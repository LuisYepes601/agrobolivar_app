// lib/features/familia_planta/services/familia_planta_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/familia_planta_model.dart';

class FamiliaPlantaService {
  final String baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1/familias-botanicas/admin';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Obtiene la lista de familias de plantas
  Future<List<FamiliaPlantaModel>> fetchFamilias({String? nombre}) async {
    final queryParams = <String, String>{};
    if (nombre != null && nombre.trim().isNotEmpty) {
      queryParams['nombre'] = nombre.trim();
    }

    final uri = Uri.parse(baseUrl).replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    print('================ [FamiliaPlantaService] ================');
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

        return listData.map((json) => FamiliaPlantaModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar familias de planta. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN EN FamiliaPlantaService: $e');
      print('📍 STACKTRACE:\n$stackTrace');
      print('==================================================');
      rethrow;
    }
  }

  /// Crea una nueva familia de planta (POST /api/v1/familias-botanicas/admin)
  Future<bool> crearFamilia(Map<String, dynamic> data) async {
    final uri = Uri.parse(baseUrl);

    print('🚀 [FamiliaPlantaService] Creando familia en: $uri');
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
        print('✅ Familia de planta creada con éxito');
        return true;
      } else {
        print('⚠️ Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN EN crearFamilia: $e');
      print('📍 STACKTRACE:\n$stackTrace');
      return false;
    }
  }

  /// Actualiza una familia de planta existente (PUT /api/v1/familias-botanicas/admin/{id})
  Future<bool> actualizarFamilia(dynamic id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$id');

    print('🚀 [FamiliaPlantaService] Actualizando familia en: $uri');
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
        print('✅ Familia de planta actualizada con éxito');
        return true;
      } else {
        print('⚠️ Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN EN actualizarFamilia: $e');
      print('📍 STACKTRACE:\n$stackTrace');
      return false;
    }
  }
}