import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/auth_model/auth_response_model.dart';
import '../models/auth_model/login_request_model.dart';
import '../models/auth_model/register_request_model.dart';

class AuthApiService {
  final String baseUrl;

  AuthApiService({
    this.baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1',
  });

  /// Método de inicio de sesión
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final url = Uri.parse('$baseUrl/auth');

    try {
      final bodyJson = jsonEncode(request.toJson());

      // Imprimir petición para comparar con Postman
      if (kDebugMode) {
        print('--> POST: $url');
        print('--> Body: $bodyJson');
      }

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: bodyJson,
      )
          .timeout(const Duration(seconds: 35)); // Tiempo de espera para servidores Render

      if (kDebugMode) {
        print('<-- Status Code: ${response.statusCode}');
        print('<-- Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponseModel.fromJson(data);
      } else {
        // Manejo seguro si la respuesta no es un JSON válido
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Credenciales incorrectas');
        } catch (_) {
          throw Exception(
            'Error del servidor (${response.statusCode}): ${response.body}',
          );
        }
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  /// Método de registro de nuevos usuarios (POST /api/v1/usuarios)
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final url = Uri.parse('$baseUrl/usuarios');

    try {
      final bodyJson = jsonEncode(request.toJson());

      if (kDebugMode) {
        print('--> POST Register: $url');
        print('--> Body: $bodyJson');
      }

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: bodyJson,
      )
          .timeout(const Duration(seconds: 35));

      if (kDebugMode) {
        print('<-- Status Code: ${response.statusCode}');
        print('<-- Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponseModel.fromJson(data);
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Error al registrar el usuario');
        } catch (_) {
          throw Exception(
            'Error del servidor (${response.statusCode}): ${response.body}',
          );
        }
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}