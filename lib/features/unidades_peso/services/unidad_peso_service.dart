import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/unidad_peso_model.dart';

class UnidadPesoService {
  // Ajusta la IP según la plataforma (10.0.2.2 para Android, localhost para iOS/Web)
  static String get _baseUrl {

    return 'https://agro-bolivar-api-1.onrender.com';
  }

  static String get _endpoint => '$_baseUrl/api/v1/unidades-peso/admin';

  Future<String?> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? prefs.getString('jwt') ?? prefs.getString('token_access');
  }

  /// Obtiene la lista administrativa paginada
  Future<PaginatedUnidadesPeso> fetchUnidadesPesoAdmin({
    String? nombre,
    bool active = false,
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

      debugPrint('📡 [UnidadPesoService] GET $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return PaginatedUnidadesPeso.fromJson(body);
      } else {
        debugPrint('❌ [UnidadPesoService] Respuesta de error: ${response.body}');
        throw Exception('Error al obtener unidades de peso (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ [UnidadPesoService] Error en fetchUnidadesPesoAdmin: $e');
      rethrow;
    }
  }

  /// Método auxiliar rápido para obtener la lista simple (para Dropdowns)
  Future<List<UnidadPeso>> fetchUnidadesPesoList() async {
    final paginated = await fetchUnidadesPesoAdmin(page: 0, size: 100);
    return paginated.content;
  }
}