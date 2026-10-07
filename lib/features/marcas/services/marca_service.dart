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
    // Endpoint exacto provisto por Swagger: /api/v1/marca-productos/admin
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
}