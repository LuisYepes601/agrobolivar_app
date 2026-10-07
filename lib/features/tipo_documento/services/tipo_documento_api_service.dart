// lib/features/tipo_documento/services/tipo_documento_api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/tipo_documento_model.dart';

class TipoDocumentoApiService {
  final String baseUrl;

  TipoDocumentoApiService({
    this.baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1',
  });

  /// Consume GET /api/v1/tipo-documentos/admin y retorna directamente List<TipoDocumentoModel>
  Future<List<TipoDocumentoModel>> fetchTiposDocumento({
    String? nombre,
    bool? active,
    int page = 0,
    int size = 50,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };

    if (nombre != null && nombre.trim().isNotEmpty) {
      queryParams['nombre'] = nombre.trim();
    }

    if (active != null) {
      queryParams['active'] = active.toString();
    }

    final uri = Uri.parse('$baseUrl/tipo-documentos/admin').replace(
      queryParameters: queryParams,
    );

    try {
      if (kDebugMode) {
        print('--> GET: $uri');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 35));

      if (kDebugMode) {
        print('<-- Status Code: ${response.statusCode}');
        print('<-- Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final paginatedResponse = PaginatedTipoDocumentoResponse.fromJson(data);
        return paginatedResponse.content; // Extrae y retorna directamente la lista
      } else {
        throw Exception('Error al obtener tipos de documento (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al cargar tipos de documento: $e');
    }
  }

  /// Método para obtener la respuesta con metadatos de paginación si se requiere en tablas/grillas
  Future<PaginatedTipoDocumentoResponse> fetchTiposDocumentoPaginado({
    String? nombre,
    bool? active,
    int page = 0,
    int size = 10,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };

    if (nombre != null && nombre.trim().isNotEmpty) {
      queryParams['nombre'] = nombre.trim();
    }

    if (active != null) {
      queryParams['active'] = active.toString();
    }

    final uri = Uri.parse('$baseUrl/tipo-documentos/admin').replace(
      queryParameters: queryParams,
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 35));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PaginatedTipoDocumentoResponse.fromJson(data);
      } else {
        throw Exception('Error al obtener tipos de documento (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al cargar tipos de documento: $e');
    }
  }
}