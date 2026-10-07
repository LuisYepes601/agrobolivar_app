import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/unidad_area_model.dart';

class UnidadAreaService {
  static String get _baseUrl {
    return 'https://agro-bolivar-api-1.onrender.com';
  }

  // Ajusta este endpoint si en tu backend se llama diferente (ej: /api/v1/unidad-area/admin)
  static String get _endpoint => '$_baseUrl/api/v1/unidades-area/admin';

  Future<String?> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? prefs.getString('jwt') ?? prefs.getString('token_access');
  }

  /// Obtiene la lista administrativa paginada
  Future<PaginatedUnidadArea> fetchUnidadesAreaAdmin({
    String? nombre,
    bool active = true,
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

      debugPrint('📡 [UnidadAreaService] GET $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> body = jsonDecode(decodedBody);
        return PaginatedUnidadArea.fromJson(body);
      } else {
        debugPrint('❌ [UnidadAreaService] Respuesta de error: ${response.body}');
        throw Exception('Error al obtener unidades de área (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ [UnidadAreaService] Error en fetchUnidadesAreaAdmin: $e');
      rethrow;
    }
  }

  /// Método auxiliar rápido para obtener la lista simple (útil para Dropdowns)
  Future<List<UnidadArea>> fetchUnidadesAreaList() async {
    final paginated = await fetchUnidadesAreaAdmin(page: 0, size: 100, active: false);
    return paginated.content;
  }
}