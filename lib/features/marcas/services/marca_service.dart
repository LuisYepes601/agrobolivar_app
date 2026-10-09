import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:agro_bolivar/features/dashboard/services/producto_service.dart';
import '../models/marca_model.dart';

class MarcaService {
  Future<List<Marca>> fetchMarcas({
    bool delete = false,
    String? nombre,
  }) async {
    String urlStr = '${ProductoService.baseUrl}/api/v1/marca-productos/admin?delete=$delete&size=100';

    if (nombre != null && nombre.trim().isNotEmpty) {
      urlStr += '&nomnre=${Uri.encodeComponent(nombre.trim())}';
    }

    final url = Uri.parse(urlStr);

    debugPrint('🚀 [MarcaService] Solicitando marcas a: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      debugPrint('📡 [MarcaService] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        debugPrint('✅ [MarcaService] Marcas obtenidas correctamente: ${content.length}');

        return content.map((item) => Marca.fromJson(item)).toList();
      } else {
        debugPrint('⚠️ [MarcaService] Error HTTP ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ [MarcaService] Excepción de red / conexión: $e');
      return [];
    }
  }

  /// Método para crear una nueva Marca (POST /api/v1/marca-productos/admin)
  Future<bool> crearMarca({
    required String nombre,
    String? descripcion,
  }) async {
    final url = Uri.parse('${ProductoService.baseUrl}/api/v1/marca-productos/admin');

    final bodyData = {
      'nombre': nombre.trim(),
      if (descripcion != null && descripcion.trim().isNotEmpty)
        'descripcion': descripcion.trim(),
    };

    debugPrint('🚀 [MarcaService] Creando marca en: $url');
    debugPrint('📦 [MarcaService] Body: ${json.encode(bodyData)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: json.encode(bodyData),
      );

      debugPrint('📡 [MarcaService] Status Code POST: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [MarcaService] Marca creada con éxito');
        return true;
      } else {
        debugPrint('⚠️ [MarcaService] Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [MarcaService] Excepción al crear marca: $e');
      return false;
    }
  }

  /// Método para actualizar una Marca existente (PUT /api/v1/marca-productos/admin/{id})
  Future<bool> actualizarMarca({
    required dynamic id,
    required String nombre,
    String? descripcion,
  }) async {
    final url = Uri.parse('${ProductoService.baseUrl}/api/v1/marca-productos/admin/$id');

    final bodyData = {
      'nombre': nombre.trim(),
      if (descripcion != null && descripcion.trim().isNotEmpty)
        'descripcion': descripcion.trim(),
    };

    debugPrint('🚀 [MarcaService] Actualizando marca en: $url');
    debugPrint('📦 [MarcaService] Body: ${json.encode(bodyData)}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: json.encode(bodyData),
      );

      debugPrint('📡 [MarcaService] Status Code PUT: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ [MarcaService] Marca actualizada con éxito');
        return true;
      } else {
        debugPrint('⚠️ [MarcaService] Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [MarcaService] Excepción al actualizar marca: $e');
      return false;
    }
  }
}