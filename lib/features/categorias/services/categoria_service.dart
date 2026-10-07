import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:agro_bolivar/features/dashboard/services/producto_service.dart';
import '../models/categoria_model.dart';

class CategoriaService {
  Future<List<Categoria>> fetchCategorias({bool delete = false}) async {
    // Apuntamos exactamente al endpoint /api/v1/categoria-producto/admin
    final url = Uri.parse(
      '${ProductoService.baseUrl}/api/v1/categoria-producto/admin?delete=$delete&size=100',
    );

    debugPrint('🚀 Solicitando categorías a: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      debugPrint('📡 Status Code Categorías: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Mapea la lista 'content' recibida del Pageable de Spring Boot
        final List<dynamic> content = data['content'] ?? [];
        debugPrint('✅ Categorías obtenidas: ${content.length}');

        return content.map((item) => Categoria.fromJson(item)).toList();
      } else {
        debugPrint('⚠️ Error HTTP ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Excepción al conectar con categorías: $e');
      return [];
    }
  }
}