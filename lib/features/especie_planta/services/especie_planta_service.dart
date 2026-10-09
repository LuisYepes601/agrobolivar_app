// lib/features/especie_planta/services/especie_planta_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agro_bolivar/features/especie_planta/model/especie_planta_model.dart';

class EspeciePlantaService {
  final String baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1/especies-plantas/admin';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Obtiene la lista de especies de planta
  Future<List<EspeciePlantaModel>> fetchEspecies({String? nombre}) async {
    final queryParams = <String, String>{};
    if (nombre != null && nombre.isNotEmpty) queryParams['nombre'] = nombre;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    print('================ [EspeciePlantaService] ================');
    print('🌐 REQUEST URL: $uri');

    try {
      final response = await http.get(uri, headers: _headers);

      print('📊 STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');
      print('======================================================');

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        List<dynamic> listData = [];

        if (decodedData is List) {
          listData = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          listData = decodedData['content'] ?? decodedData['data'] ?? [];
        }

        final especies = listData.map((json) => EspeciePlantaModel.fromJson(json)).toList();
        return especies;
      } else {
        throw Exception(
            'Error al cargar especies. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN CAPTURADA: $e');
      print('📍 STACKTRACE:\n$stackTrace');
      rethrow;
    }
  }

  /// Crea una nueva especie de planta (POST /api/v1/especies-plantas/admin)
  Future<bool> crearEspecie(Map<String, dynamic> data) async {
    final uri = Uri.parse(baseUrl);

    print('🚀 [EspeciePlantaService] Creando especie en: $uri');
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
        print('✅ Especie de planta creada con éxito');
        return true;
      } else {
        print('⚠️ Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN EN crearEspecie: $e');
      print('📍 STACKTRACE:\n$stackTrace');
      return false;
    }
  }

  /// Actualiza una especie de planta existente (PUT /api/v1/especies-plantas/admin/{id})
  Future<bool> actualizarEspecie(dynamic id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$id');

    print('🚀 [EspeciePlantaService] Actualizando especie en: $uri');
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
        print('✅ Especie de planta actualizada con éxito');
        return true;
      } else {
        print('⚠️ Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN EN actualizarEspecie: $e');
      print('📍 STACKTRACE:\n$stackTrace');
      return false;
    }
  }
}