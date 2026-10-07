import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../auth/services/auth_local_service.dart';
import '../models/cultivo_admin_model.dart';
import '../models/cultivo_admin_detail_model.dart';
import '../models/cultivo_request_dto.dart';
import '../models/cultivo_update_dto.dart';

class CultivoApiService {
  static const String baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1/cultivos/admin';
  final AuthLocalService _authLocalService = AuthLocalService();

  /// NVO MÉTODO: Obtiene la lista general de todos los cultivos (Sin pasar id_usuario)
  Future<List<CultivoAdminModel>> getCultivosGeneral({
    String? nombre,
    bool? estado,
    bool? active,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        if (nombre != null && nombre.isNotEmpty) 'nombre': nombre,
        if (estado != null) 'estado': estado.toString(),
        if (active != null) 'active': active.toString(),
        'page': page.toString(),
        'size': size.toString(),
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      debugPrint('--> [HTTP GET General] Solicitando URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('x-- [HTTP TIMEOUT] Tiempo agotado al esperar al servidor.');
          throw Exception('Servidor no responde a tiempo. Intenta de nuevo.');
        },
      );

      debugPrint('<-- [HTTP ${response.statusCode}] Respuesta recibida');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> content = json['content'] ?? [];

        debugPrint('--> [CultivoApiService] Cultivos generales cargados: ${content.length}');
        return content.map((item) => CultivoAdminModel.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        debugPrint('--> [HTTP 404] No se encontraron cultivos. Retornando lista vacía.');
        return [];
      } else {
        debugPrint('x-- [HTTP ERROR ${response.statusCode}] Detalle: ${response.body}');
        throw Exception('Error al obtener la lista general de cultivos (${response.statusCode})');
      }
    } catch (e, stack) {
      debugPrint('x-- [EXCEPCIÓN HTTP General]: $e');
      debugPrint('x-- STACKTRACE: $stack');
      rethrow;
    }
  }

  /// Obtiene los cultivos propios del usuario en el panel de administración (Sí envía id_usuario)
  Future<List<CultivoAdminModel>> getCultivosAdmin({
    String? nombre,
    bool? estado,
    bool? active,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final userId = await _authLocalService.getUserId();
      debugPrint('--> [CultivoApiService] User ID obtenido: $userId');

      final queryParams = <String, String>{
        if (userId != null) 'id_usuario': userId.toString(),
        if (nombre != null && nombre.isNotEmpty) 'nombre': nombre,
        if (estado != null) 'estado': estado.toString(),
        if (active != null) 'active': active.toString(),
        'page': page.toString(),
        'size': size.toString(),
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      debugPrint('--> [HTTP GET] Solicitando URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('x-- [HTTP TIMEOUT] Tiempo agotado al esperar al servidor.');
          throw Exception('Servidor no responde a tiempo. Intenta de nuevo.');
        },
      );

      debugPrint('<-- [HTTP ${response.statusCode}] Respuesta recibida');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> content = json['content'] ?? [];

        debugPrint('--> [CultivoApiService] Registros cargados: ${content.length}');
        return content.map((item) => CultivoAdminModel.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        debugPrint('--> [HTTP 404] No se encontraron cultivos. Retornando lista vacía.');
        return [];
      } else {
        debugPrint('x-- [HTTP ERROR ${response.statusCode}] Detalle: ${response.body}');
        throw Exception('Error al obtener la lista de cultivos (${response.statusCode})');
      }
    } catch (e, stack) {
      debugPrint('x-- [EXCEPCIÓN HTTP]: $e');
      debugPrint('x-- STACKTRACE: $stack');
      rethrow;
    }
  }

  /// Obtiene los detalles de un cultivo específico por su ID
  Future<CultivoAdminDetailModel> getCultivoAdminById(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/$id');
      debugPrint('--> [HTTP GET Detalle] Solicitando cultivo ID: $id ($uri)');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('x-- [HTTP TIMEOUT] Tiempo agotado al obtener el detalle.');
          throw Exception('Servidor no responde a tiempo. Intenta de nuevo.');
        },
      );

      debugPrint('<-- [HTTP ${response.statusCode}] Detalle recibido');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return CultivoAdminDetailModel.fromJson(json);
      } else {
        debugPrint('x-- [HTTP ERROR ${response.statusCode}] Detalle: ${response.body}');
        throw Exception('Error al obtener detalles del cultivo (${response.statusCode})');
      }
    } catch (e, stack) {
      debugPrint('x-- [EXCEPCIÓN HTTP Detalle]: $e');
      debugPrint('x-- STACKTRACE: $stack');
      rethrow;
    }
  }

  /// Crear un nuevo cultivo mediante FormData (multipart/form-data)
  Future<CultivoAdminModel> createCultivo({
    required CultivoRequestDto cultivoDto,
    dynamic fotoCultivo,
  }) async {
    final uri = Uri.parse(baseUrl);
    debugPrint('--> [HTTP POST FormData] Solicitando: $uri');

    var request = http.MultipartRequest('POST', uri);
    final String bodyJson = cultivoDto.toRawJson();

    request.files.add(
      http.MultipartFile.fromString(
        'body',
        bodyJson,
        contentType: MediaType('application', 'json'),
      ),
    );
    debugPrint('--> [FormData JSON Part] cuerpo adjuntado correctamente');

    if (fotoCultivo != null) {
      if (fotoCultivo is File && await fotoCultivo.exists()) {
        final multipartFile = await http.MultipartFile.fromPath(
          'fotoCultivo',
          fotoCultivo.path,
        );
        request.files.add(multipartFile);
        debugPrint('--> [FormData File] fotoCultivo adjuntado desde archivo: ${fotoCultivo.path}');
      } else if (fotoCultivo is String && fotoCultivo.isNotEmpty) {
        request.fields['fotoCultivo'] = fotoCultivo;
        debugPrint('--> [FormData Field] fotoCultivo: $fotoCultivo');
      }
    }

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('<-- [HTTP ${response.statusCode}] Respuesta POST');
      debugPrint('<-- [HTTP BODY] ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return CultivoAdminModel.fromJson(json);
      } else {
        throw Exception('Error al registrar cultivo (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN POST FormData]: $e');
      rethrow;
    }
  }

  /// Actualizar la foto de un cultivo mediante PUT multipart/form-data
  Future<bool> actualizarFotoCultivo(int id, File foto) async {
    final uri = Uri.parse('$baseUrl/$id/foto-cultivo');
    debugPrint('--> [HTTP PUT FormData Foto] Solicitando: $uri');

    var request = http.MultipartRequest('PUT', uri);

    if (await foto.exists()) {
      final multipartFile = await http.MultipartFile.fromPath(
        'foto',
        foto.path,
      );
      request.files.add(multipartFile);
      debugPrint('--> [FormData File] foto adjuntada desde: ${foto.path}');
    } else {
      throw Exception('El archivo de imagen especificado no existe.');
    }

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('<-- [HTTP ${response.statusCode}] Respuesta PUT foto');
      debugPrint('<-- [HTTP BODY] ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al actualizar la foto (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PUT Foto]: $e');
      rethrow;
    }
  }

  /// Actualizar un cultivo existente usando CultivoUpdateDto
  Future<CultivoAdminDetailModel> updateCultivo(int id, CultivoUpdateDto updateDto) async {
    final uri = Uri.parse('$baseUrl/$id');
    debugPrint('--> [HTTP PUT] Actualizando cultivo ID: $id ($uri)');
    debugPrint('--> [HTTP BODY] ${updateDto.toRawJson()}');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: updateDto.toRawJson(),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('x-- [HTTP TIMEOUT] Tiempo agotado al actualizar el cultivo.');
          throw Exception('Servidor no responde a tiempo. Intenta de nuevo.');
        },
      );

      debugPrint('<-- [HTTP ${response.statusCode}] Respuesta PUT cultivo');
      debugPrint('<-- [HTTP BODY] ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return CultivoAdminDetailModel.fromJson(json);
      } else {
        throw Exception('Error al actualizar el cultivo (${response.statusCode}): ${response.body}');
      }
    } catch (e, stack) {
      debugPrint('x-- [EXCEPCIÓN PUT Cultivo]: $e');
      debugPrint('x-- STACKTRACE: $stack');
      rethrow;
    }
  }

  /// Alias para mantener compatibilidad
  Future<CultivoAdminDetailModel> actualizarCultivo(int id, CultivoUpdateDto updateDto) {
    return updateCultivo(id, updateDto);
  }

  /// Eliminar un cultivo
  Future<void> deleteCultivo(int id) async {
    debugPrint('--> [HTTP DELETE] Eliminando cultivo ID: $id');

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    debugPrint('<-- [HTTP ${response.statusCode}]');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar el cultivo (${response.statusCode})');
    }
  }
}