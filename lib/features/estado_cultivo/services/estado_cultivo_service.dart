import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/estado_cultivo_model.dart';

class EstadoCultivoService {
  static String get _baseUrl {
    return 'https://agro-bolivar-api-1.onrender.com';
  }

  static String get _endpoint => '$_baseUrl/api/v1/estado-cultivos/admin';

  Future<String?> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? prefs.getString('jwt') ?? prefs.getString('token_access');
  }

  /// Obtiene la lista administrativa paginada
  Future<PaginatedEstadoCultivo> fetchEstadoCultivosAdmin({
    String? nombre,
    bool active = true, // Por defecto solemos buscar los activos
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = {
        if (nombre != null && nombre.isNotEmpty) 'nombre': nombre,
        'active': active.toString(),
        'page': page.toString(),
        'size': size.toString(),
      };

      final uri = Uri.parse(_endpoint).replace(queryParameters: queryParams);
      final token = await _obtenerToken();

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📡 [EstadoCultivoService] GET $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Para evitar problemas de codificación con tildes y eñes
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> body = jsonDecode(decodedBody);
        return PaginatedEstadoCultivo.fromJson(body);
      } else {
        debugPrint('❌ [EstadoCultivoService] Respuesta de error: ${response.body}');
        throw Exception('Error al obtener estados de cultivo (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ [EstadoCultivoService] Error en fetchEstadoCultivosAdmin: $e');
      rethrow;
    }
  }

  /// Método auxiliar rápido para obtener la lista simple (útil para Dropdowns)
  Future<List<EstadoCultivo>> fetchEstadoCultivosList() async {
    // Obtenemos una página grande para asegurarnos de traer todos los estados activos
    final paginated = await fetchEstadoCultivosAdmin(page: 0, size: 100, active: false);
    return paginated.content;
  }
}