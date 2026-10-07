import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ciclo_germinacion_model.dart';

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

        // Soporta tanto respuesta directa List [...] como respuesta paginada {"content": [...]}
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
}