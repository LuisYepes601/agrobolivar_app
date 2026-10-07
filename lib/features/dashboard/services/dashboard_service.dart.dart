import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_basic_info_model.dart';

class DashboardService {
  // Solo la IP y puerto base
  static String get baseUrl {

    return 'https://agro-bolivar-api-1.onrender.com';
  }

  Future<UserBasicInfo> fetchBasicUserInfo(int userId) async {
    // Definimos la ruta única completa aquí
    final url = Uri.parse('$baseUrl/api/v1/dashboard/$userId/data-basic-user-home');

    debugPrint('🚀 Solicitando a la URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserBasicInfo.fromJson(data);
      } else {
        throw Exception('Error al cargar datos del usuario: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en la llamada a la API: $e');
      rethrow;
    }
  }
}