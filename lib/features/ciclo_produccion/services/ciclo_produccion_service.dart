// lib/features/ciclo_produccion/services/ciclo_produccion_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/ciclo_produccion_model.dart';

class CicloProduccionService {
  static const String _defaultBaseUrl = 'https://agro-bolivar-api-1.onrender.com';
  final String baseUrl;
  final http.Client httpClient;

  CicloProduccionService({
    this.baseUrl = _defaultBaseUrl,
    http.Client? client,
  }) : httpClient = client ?? http.Client();

  /// Obtiene la lista de ciclos de producción desde el endpoint admin
  Future<List<CicloProduccionModel>> getCiclosProduccion({
    int page = 0,
    int size = 100,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/ciclos-produccion/admin').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    try {
      debugPrint('--> [CicloProduccionService.getCiclosProduccion] GET: $uri');

      final response = await httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al cargar ciclos de producción.');
        },
      );

      debugPrint('<-- [CicloProduccionService.getCiclosProduccion] Status Code: ${response.statusCode}');
      debugPrint('📦 [CicloProduccionService.getCiclosProduccion] Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        List<dynamic> listData = [];

        if (decodedData is Map<String, dynamic> && decodedData.containsKey('content')) {
          listData = decodedData['content'] ?? [];
        } else if (decodedData is List) {
          listData = decodedData;
        }

        debugPrint('--> [CicloProduccionService] Ciclos de producción obtenidos: ${listData.length}');
        return listData
            .map((item) => CicloProduccionModel.fromJson(item))
            .toList();
      } else if (response.statusCode == 404) {
        debugPrint('--> [CicloProduccionService] 404 No se encontraron ciclos de producción');
        return [];
      } else {
        throw Exception('Error al obtener los ciclos de producción (${response.statusCode}): ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('x-- [EXCEPCIÓN CicloProduccionService.getCiclosProduccion]: $e');
      debugPrint('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene un ciclo de producción específico por su ID
  Future<CicloProduccionModel?> getCicloById(int id) async {
    final uri = Uri.parse('$baseUrl/api/v1/ciclos-produccion/admin/$id');

    try {
      debugPrint('--> [CicloProduccionService.getCicloById] GET: $uri');

      final response = await httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al consultar el ciclo de producción ID $id.');
        },
      );

      debugPrint('<-- [CicloProduccionService.getCicloById] Status Code: ${response.statusCode}');
      debugPrint('📦 [CicloProduccionService.getCicloById] Body: ${response.body}');

      if (response.statusCode == 200) {
        return CicloProduccionModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener ciclo ID $id (${response.statusCode}): ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('x-- [EXCEPCIÓN CicloProduccionService.getCicloById]: $e');
      debugPrint('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  /// Crea un nuevo ciclo de producción (POST /api/v1/ciclos-produccion/admin)
  Future<bool> crearCicloProduccion(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/api/v1/ciclos-produccion/admin');

    try {
      debugPrint('--> [CicloProduccionService.crearCicloProduccion] POST: $uri');
      debugPrint('📦 Body: ${jsonEncode(data)}');

      final response = await httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al crear ciclo de producción.');
        },
      );

      debugPrint('<-- [CicloProduccionService.crearCicloProduccion] Status Code: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Ciclo de producción creado con éxito');
        return true;
      } else {
        debugPrint('⚠️ Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('x-- [EXCEPCIÓN CicloProduccionService.crearCicloProduccion]: $e');
      debugPrint('Stacktrace: $stackTrace');
      return false;
    }
  }

  /// Actualiza un ciclo de producción existente (PUT /api/v1/ciclos-produccion/admin/{id})
  Future<bool> actualizarCicloProduccion(dynamic id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/api/v1/ciclos-produccion/admin/$id');

    try {
      debugPrint('--> [CicloProduccionService.actualizarCicloProduccion] PUT: $uri');
      debugPrint('📦 Body: ${jsonEncode(data)}');

      final response = await httpClient.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al actualizar ciclo de producción.');
        },
      );

      debugPrint('<-- [CicloProduccionService.actualizarCicloProduccion] Status Code: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Ciclo de producción actualizado con éxito');
        return true;
      } else {
        debugPrint('⚠️ Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('x-- [EXCEPCIÓN CicloProduccionService.actualizarCicloProduccion]: $e');
      debugPrint('Stacktrace: $stackTrace');
      return false;
    }
  }
}