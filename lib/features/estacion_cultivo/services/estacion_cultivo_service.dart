import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estacion_cultivo_model.dart';

class EstacionCultivoService {
  // URL base actualizada al servidor en Render
  final String baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1';

  Future<List<EstacionCultivoModel>> getEstacionesCultivoAdmin() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estacion-cultivos/admin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));

        // Manejo flexible por si la API responde una lista directa [...] o una envoltura { "data": [...] } / { "results": [...] }
        List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          list = decoded['data'] ?? decoded['results'] ?? [];
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