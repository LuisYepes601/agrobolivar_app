import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/unidad_area_model.dart';

class UnidadAreaService {
  static String get _baseUrl {
    return 'https://agro-bolivar-api-1.onrender.com';
  }

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

  /// Método auxiliar rápido para obtener la lista simple
  Future<List<UnidadArea>> fetchUnidadesAreaList() async {
    final paginated = await fetchUnidadesAreaAdmin(page: 0, size: 100, active: false);
    return paginated.content;
  }

  /// Crear una nueva unidad de área (POST /api/v1/unidades-area/admin)
  Future<Map<String, dynamic>> crearUnidadArea(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse(_endpoint);
      final token = await _obtenerToken();

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      debugPrint('📡 [UnidadAreaService] POST $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedBody) as Map<String, dynamic>;
      } else {
        debugPrint('❌ [UnidadAreaService] Error: ${response.body}');
        throw Exception('Error al crear la unidad de área (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ [UnidadAreaService] Error en crearUnidadArea: $e');
      rethrow;
    }
  }

  /// Editar/Actualizar una unidad de área existente por ID (PUT /api/v1/unidades-area/admin/{id})
  Future<Map<String, dynamic>> actualizarUnidadArea(int id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$_endpoint/$id');
      final token = await _obtenerToken();

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      debugPrint('📡 [UnidadAreaService] PUT $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedBody) as Map<String, dynamic>;
      } else {
        debugPrint('❌ [UnidadAreaService] Error: ${response.body}');
        throw Exception('Error al actualizar la unidad de área (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ [UnidadAreaService] Error en actualizarUnidadArea: $e');
      rethrow;
    }
  }
}