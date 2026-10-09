import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ciclo_germinacion_model.dart';
import '../models/create_ciclo_germinacion_dto.dart';
import '../models/ciclo_germinacion_detail_model.dart';

class CicloGerminacionService {
  static const String _defaultBaseUrl = 'https://agro-bolivar-api-1.onrender.com';
  final String baseUrl;
  final http.Client httpClient;

  CicloGerminacionService({
    this.baseUrl = _defaultBaseUrl,
    http.Client? client,
  }) : httpClient = client ?? http.Client();

  /// Obtiene la lista de ciclos de germinación desde el endpoint admin
  Future<List<CicloGerminacionModel>> getCiclosGerminacion() async {
    final url = Uri.parse('$baseUrl/api/v1/ciclo-germinaciones/admin');

    try {
      debugPrint('--> [CicloGerminacionService.getCiclosGerminacion] GET: $url');

      final response = await httpClient.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al cargar ciclos de germinación.');
        },
      );

      debugPrint('<-- [CicloGerminacionService.getCiclosGerminacion] Status Code: ${response.statusCode}');
      debugPrint('📦 [CicloGerminacionService.getCiclosGerminacion] Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        List<dynamic> listData = [];

        if (decodedData is Map<String, dynamic> && decodedData.containsKey('content')) {
          listData = decodedData['content'] ?? [];
        } else if (decodedData is List) {
          listData = decodedData;
        }

        debugPrint('--> [CicloGerminacionService] Ciclos obtenidos: ${listData.length}');
        return listData
            .map((item) => CicloGerminacionModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Error al cargar ciclos (${response.statusCode}): ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('x-- [EXCEPCIÓN CicloGerminacionService.getCiclosGerminacion]: $e');
      debugPrint('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene un ciclo de germinación específico por su ID
  Future<CicloGerminacionModel?> getCicloById(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/ciclo-germinaciones/admin/$id');

    try {
      debugPrint('--> [CicloGerminacionService.getCicloById] GET: $url');

      final response = await httpClient.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al cargar el ciclo ID $id.');
        },
      );

      debugPrint('<-- [CicloGerminacionService.getCicloById] Status Code: ${response.statusCode}');
      debugPrint('📦 [CicloGerminacionService.getCicloById] Body: ${response.body}');

      if (response.statusCode == 200) {
        return CicloGerminacionModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener ciclo ID $id (${response.statusCode}): ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('x-- [EXCEPCIÓN CicloGerminacionService.getCicloById]: $e');
      debugPrint('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene los detalles de auditoría de un ciclo de germinación por su ID
  Future<CicloGerminacionDetailModel?> getCicloDetails(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/ciclo-germinaciones/admin/$id/details');

    try {
      debugPrint('--> [CicloGerminacionService.getCicloDetails] GET: $url');

      final response = await httpClient.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al cargar los detalles del ciclo ID $id.');
        },
      );

      debugPrint('<-- [CicloGerminacionService.getCicloDetails] Status Code: ${response.statusCode}');
      debugPrint('📦 [CicloGerminacionService.getCicloDetails] Body: ${response.body}');

      if (response.statusCode == 200) {
        return CicloGerminacionDetailModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener detalles del ciclo ID $id (${response.statusCode}): ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('x-- [EXCEPCIÓN CicloGerminacionService.getCicloDetails]: $e');
      debugPrint('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  /// Crea un nuevo ciclo de germinación enviando el DTO de creación
  Future<void> crearCicloGerminacion(CreateCicloGerminacionDto dto) async {
    final url = Uri.parse('$baseUrl/api/v1/ciclo-germinaciones/admin');

    try {
      final payloadJson = jsonEncode(dto.toJson());
      debugPrint('--> [CicloGerminacionService.crearCicloGerminacion] POST: $url');
      debugPrint('📦 [CicloGerminacionService.crearCicloGerminacion] Payload: $payloadJson');

      final response = await httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payloadJson,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al crear ciclo de germinación.');
        },
      );

      debugPrint('<-- [CicloGerminacionService.crearCicloGerminacion] Status Code: ${response.statusCode}');
      debugPrint('📦 [CicloGerminacionService.crearCicloGerminacion] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception('Error al crear ciclo (${response.statusCode}): ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('x-- [EXCEPCIÓN CicloGerminacionService.crearCicloGerminacion]: $e');
      debugPrint('Stacktrace: $stackTrace');
      rethrow;
    }
  }

  /// Actualiza un ciclo de germinación existente por su ID
  Future<void> actualizarCicloGerminacion(int id, CreateCicloGerminacionDto dto) async {
    final url = Uri.parse('$baseUrl/api/v1/ciclo-germinaciones/admin/$id');

    try {
      final payloadJson = jsonEncode(dto.toJson());
      debugPrint('--> [CicloGerminacionService.actualizarCicloGerminacion] PUT: $url');
      debugPrint('📦 [CicloGerminacionService.actualizarCicloGerminacion] Payload: $payloadJson');

      final response = await httpClient.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payloadJson,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al actualizar ciclo de germinación.');
        },
      );

      debugPrint('<-- [CicloGerminacionService.actualizarCicloGerminacion] Status Code: ${response.statusCode}');
      debugPrint('📦 [CicloGerminacionService.actualizarCicloGerminacion] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw Exception('Error al actualizar ciclo ID $id (${response.statusCode}): ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('x-- [EXCEPCIÓN CicloGerminacionService.actualizarCicloGerminacion]: $e');
      debugPrint('Stacktrace: $stackTrace');
      rethrow;
    }
  }
}