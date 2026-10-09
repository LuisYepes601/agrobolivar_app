// lib/features/rol/services/rol_api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
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

      if (body is List) {
        return body.map((json) => RolModel.fromJson(json)).toList();
      } else if (body is Map<String, dynamic> && body.containsKey('content')) {
        final List<dynamic> list = body['content'];
        return list.map((json) => RolModel.fromJson(json)).toList();
      } else {
        throw Exception('Formato de respuesta no soportado');
      }
    } else {
      throw Exception('Error al obtener los roles (${response.statusCode})');
    }
  }

  /// Crear un nuevo rol (POST /api/v1/roles/admin)
  Future<RolModel> crearRol(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/api/v1/roles/admin');

    try {
      if (kDebugMode) {
        print('--> POST: $uri');
        print('Body: ${jsonEncode(data)}');
      }

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 35));

      if (kDebugMode) {
        print('<-- Status Code: ${response.statusCode}');
        print('<-- Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> json = jsonDecode(decodedBody);
        return RolModel.fromJson(json);
      } else {
        throw Exception('Error al crear el rol (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al crear rol: $e');
    }
  }

  /// Actualizar un rol existente (PUT /api/v1/roles/admin/{id})
  Future<RolModel> actualizarRol(
      dynamic id,
      Map<String, dynamic> data,
      ) async {
    final uri = Uri.parse('$baseUrl/api/v1/roles/admin/$id');

    try {
      if (kDebugMode) {
        print('--> PUT: $uri');
        print('Body: ${jsonEncode(data)}');
      }

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 35));

      if (kDebugMode) {
        print('<-- Status Code: ${response.statusCode}');
        print('<-- Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.trim().isNotEmpty) {
          final decodedBody = utf8.decode(response.bodyBytes);
          final dynamic json = jsonDecode(decodedBody);
          if (json is Map<String, dynamic> && json.containsKey('id') && json['id'] != null) {
            return RolModel.fromJson(json);
          }
        }

        // Si la respuesta del servidor no retorna un cuerpo con 'id',
        // se construye el modelo manteniendo el ID enviado en la petición.
        final parsedId = id is int ? id : int.tryParse(id.toString()) ?? 0;
        return RolModel(
          id: parsedId,
          nombre: data['nombre']?.toString() ?? '',
          descripcion: data['descripcion']?.toString(),
        );
      } else {
        throw Exception('Error al actualizar el rol (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar rol: $e');
    }
  }
}