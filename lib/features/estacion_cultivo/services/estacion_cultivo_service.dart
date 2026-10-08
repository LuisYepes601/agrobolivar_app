import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estacion_cultivo_model.dart';

class EstacionCultivoService {
  final String baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1';

  Future<List<EstacionCultivoModel>> getEstacionesCultivoAdmin({int page = 0, int size = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estacion-cultivos/admin?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));

        List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          // ✅ Incluimos 'content' para dar soporte a las respuestas paginadas de Spring Boot
          list = decoded['content'] ?? decoded['data'] ?? decoded['results'] ?? [];
        } else {
          list = [];
        }

        return list.map((json) => EstacionCultivoModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener estaciones de cultivo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al cargar estaciones de cultivo: $e');
    }
  }
}