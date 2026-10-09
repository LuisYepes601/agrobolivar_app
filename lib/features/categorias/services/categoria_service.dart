import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:agro_bolivar/features/dashboard/services/producto_service.dart';
import '../models/categoria_model.dart';

class CategoriaService {
  // --- GET: Listar Categorías ---
  Future<List<Categoria>> fetchCategorias({bool delete = false}) async {
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
        final List<dynamic> content = data['content'] ?? [];
        debugPrint('✅ Categorías obtenidas: ${content.length}');

        return content.map((item) => Categoria.fromJson(item)).toList();
      } else {
        debugPrint('⚠️ Error HTTP ${response.statusCode}:${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Excepción al conectar con categorías: $e');
      return [];
    }
  }

  // --- POST: Crear Nueva Categoría ---
  Future<bool> crearCategoria({
    required String nombre,
    String? descripcion,
  }) async {
    final url = Uri.parse('${ProductoService.baseUrl}/api/v1/categoria-producto/admin');

    debugPrint('🚀 Creando categoría en: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: json.encode({
          'nombre': nombre,
          'descripcion': descripcion,
        }),
      );

      debugPrint('📡 Status Code Crear Categoría: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Categoría creada exitosamente');
        return true;
      } else {
        debugPrint('⚠️ Error al crear categoría ${response.statusCode}:${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Excepción al crear categoría: $e');
      return false;
    }
  }

  // --- PUT: Actualizar Categoría por ID (/api/v1/categoria-producto/admin/{id}) ---
  Future<bool> actualizarCategoria({
    required dynamic id,
    required String nombre,
    String? descripcion,
  }) async {
    final url = Uri.parse('${ProductoService.baseUrl}/api/v1/categoria-producto/admin/$id');

    debugPrint('🚀 Actualizando categoría ID $id en:$url');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: json.encode({
          'nombre': nombre,
          'descripcion': descripcion,
        }),
      );

      debugPrint('📡 Status Code Actualizar Categoría: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Categoría actualizada exitosamente');
        return true;
      } else {
        debugPrint('⚠️ Error al actualizar categoría ${response.statusCode}:${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Excepción al actualizar categoría: $e');
      return false;
    }
  }

  // Alias compatible por si lo llamas como `editarCategoria` en lugar de `actualizarCategoria`
  Future<bool> editarCategoria({
    required dynamic id,
    required String nombre,
    String? descripcion,
  }) =>
      actualizarCategoria(id: id, nombre: nombre, descripcion: descripcion);

  // --- DELETE: Eliminar Categoría por ID ---
  Future<bool> eliminarCategoria(dynamic id) async {
    final url = Uri.parse('${ProductoService.baseUrl}/api/v1/categoria-producto/admin/$id');

    debugPrint('🚀 Eliminando categoría ID $id en:$url');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      debugPrint('📡 Status Code Eliminar Categoría: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Categoría eliminada exitosamente');
        return true;
      } else {
        debugPrint('⚠️ Error al eliminar categoría ${response.statusCode}:${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Excepción al eliminar categoría: $e');
      return false;
    }
  }
}