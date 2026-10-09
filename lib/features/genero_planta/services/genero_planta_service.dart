// lib/features/genero_planta/services/genero_planta_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/genero_planta_model.dart';

class GeneroPlantaService {
  final String baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1/genero-plantas/admin';

  /// Obtiene el listado de géneros de planta
  Future<List<GeneroPlantaModel>> fetchGeneros() async {
    final url = Uri.parse(baseUrl);

    print('================ [GeneroPlantaService] ================');
    print('🌐 REQUEST URL: $url');

    try {
      final response = await http.get(url);

      print('📊 STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');
      print('==================================================');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        return content.map((e) => GeneroPlantaModel.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar géneros de planta: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR EN [GeneroPlantaService]: $e');
      print('==================================================');
      rethrow;
    }
  }

  /// Crea un nuevo género de planta (POST /api/v1/genero-plantas/admin)
  Future<bool> crearGeneroPlanta(Map<String, dynamic> data) async {
    final url = Uri.parse(baseUrl);

    print('🚀 [GeneroPlantaService] Creando género en: $url');
    print('📦 Body: ${json.encode(data)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: json.encode(data),
      );

      print('📡 Status Code POST: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Género de planta creado con éxito');
        return true;
      } else {
        print('⚠️ Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Excepción al crear género de planta: $e');
      return false;
    }
  }

  /// Actualiza un género de planta existente (PUT /api/v1/genero-plantas/admin/{id})
  Future<bool> actualizarGeneroPlanta(dynamic id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$id');

    print('🚀 [GeneroPlantaService] Actualizando género en: $url');
    print('📦 Body: ${json.encode(data)}');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: json.encode(data),
      );

      print('📡 Status Code PUT: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Género de planta actualizado con éxito');
        return true;
      } else {
        print('⚠️ Error HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Excepción al actualizar género de planta: $e');
      return false;
    }
  }
}