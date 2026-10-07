// lib/features/rol/services/rol_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rol_model.dart';

class RolApiService {
  final String baseUrl;

  RolApiService({this.baseUrl = 'https://agro-bolivar-api-1.onrender.com'});

  Future<List<RolModel>> fetchRoles() async {
    final uri = Uri.parse('$baseUrl/api/v1/roles/admin');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);

      // Maneja si el backend retorna una lista directa [...]
      if (body is List) {
        return body.map((json) => RolModel.fromJson(json)).toList();
      }
      // Maneja si el backend retorna una respuesta paginada { "content": [...] }
      else if (body is Map<String, dynamic> && body.containsKey('content')) {
        final List<dynamic> list = body['content'];
        return list.map((json) => RolModel.fromJson(json)).toList();
      } else {
        throw Exception('Formato de respuesta no soportado');
      }
    } else {
      throw Exception('Error al obtener los roles (${response.statusCode})');
    }
  }
}