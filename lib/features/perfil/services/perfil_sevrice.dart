import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:agro_bolivar/features/auth/services/auth_local_service.dart';
import '../models/usuario_model.dart';
import '../models/informacion_personal_dto_req.dart';

class PerfilService {
  // URL base de producción en Render
  static const String _baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1/usuarios';

  final AuthLocalService _authLocalService = AuthLocalService();

  /// Obtiene los datos del usuario logueado extrayendo el ID desde LocalStorage
  Future<UsuarioModel> obtenerUsuarioActual() async {
    final dynamic rawId = await _authLocalService.getUserId();

    if (rawId == null || rawId.toString() == 'null' || rawId.toString().trim().isEmpty) {
      throw Exception('No se encontró un ID de usuario válido en el almacenamiento local.');
    }

    final int? id = rawId is int ? rawId : int.tryParse(rawId.toString());
    if (id == null) {
      throw Exception('El ID de usuario no es un número entero válido: $rawId');
    }

    return obtenerUsuarioPorId(id);
  }

  /// GET: Consulta la información de un usuario según su ID
  Future<UsuarioModel> obtenerUsuarioPorId(int id) async {
    final url = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http.get(
        url,
        headers: const {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return UsuarioModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else {
        throw Exception(
          'Error al obtener perfil (${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión con el servidor: $e');
    }
  }

  /// PUT: Actualiza la información personal del usuario utilizando InformacionPersonalDtoReq
  /// Endpoint: /api/v1/usuarios/{id}/informacion-personal
  Future<UsuarioModel> actualizarInformacionPersonal({
    required int idUsuario,
    required InformacionPersonalDtoReq dto,
  }) async {
    final url = Uri.parse('$_baseUrl/$idUsuario/informacion-personal');

    try {
      final response = await http.put(
        url,
        headers: const {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode(dto.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String bodyText = utf8.decode(response.bodyBytes).trim();

        // Si el cuerpo está vacío, reconsultamos el usuario directamente por su ID
        if (bodyText.isEmpty) {
          return await obtenerUsuarioPorId(idUsuario);
        }

        try {
          final Map<String, dynamic> data = json.decode(bodyText);
          return UsuarioModel.fromJson(data);
        } catch (e) {
          debugPrint('⚠️ [ACTUALIZAR PERFIL] Error al parsear JSON recibido ($e). Reconsultando por GET...');
          return await obtenerUsuarioPorId(idUsuario);
        }
      } else {
        throw Exception(
          'Error al actualizar información personal (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al actualizar información personal: $e');
    }
  }

  /// PUT: Actualiza el modelo completo de usuario utilizando UsuarioModel.toJson()
  Future<UsuarioModel> actualizarUsuario(int id, UsuarioModel usuario) async {
    final url = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http.put(
        url,
        headers: const {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: usuario.toRawJson(),
      );

      if (response.statusCode == 200) {
        final String bodyText = utf8.decode(response.bodyBytes).trim();
        if (bodyText.isEmpty) {
          return await obtenerUsuarioPorId(id);
        }

        try {
          final Map<String, dynamic> data = json.decode(bodyText);
          return UsuarioModel.fromJson(data);
        } catch (e) {
          return await obtenerUsuarioPorId(id);
        }
      } else {
        throw Exception('Error al actualizar información (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar: $e');
    }
  }

  /// PATCH: Actualiza únicamente los nombres y apellidos del usuario
  Future<UsuarioModel> actualizarNombres({
    required int id,
    required String primerNombre,
    String? segundoNombre,
    required String apellidoPaterno,
    String? apellidoMaterno,
  }) async {
    final url = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http.patch(
        url,
        headers: const {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: json.encode({
          'primerNombre': primerNombre,
          'segundoNombre': segundoNombre,
          'apellidoPaterno': apellidoPaterno,
          'apellidoMaterno': apellidoMaterno,
        }),
      );

      if (response.statusCode == 200) {
        final String bodyText = utf8.decode(response.bodyBytes).trim();
        if (bodyText.isEmpty) {
          return await obtenerUsuarioPorId(id);
        }

        try {
          final Map<String, dynamic> data = json.decode(bodyText);
          return UsuarioModel.fromJson(data);
        } catch (e) {
          return await obtenerUsuarioPorId(id);
        }
      } else {
        throw Exception('Error al actualizar el nombre (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar el nombre: $e');
    }
  }

  /// POST / PUT: Sube y actualiza la foto de perfil mediante Multipart (FormData)
  /// RequestPart: 'foto'
  /// Endpoint: /api/v1/usuarios/{id}/foto-perfil
  Future<UsuarioModel> actualizarFotoPerfil({
    required int id,
    required File fotoFile,
  }) async {
    final url = Uri.parse('$_baseUrl/$id/foto-perfil');

    debugPrint('--------------------------------------------------');
    debugPrint('📸 [PETICIÓN FOTO] URL: $url');
    debugPrint('📸 [PETICIÓN FOTO] Ruta de archivo: ${fotoFile.path}');
    debugPrint('📸 [PETICIÓN FOTO] ¿Existe el archivo?: ${await fotoFile.exists()}');
    debugPrint('📸 [PETICIÓN FOTO] Tamaño: ${await fotoFile.length()} bytes');
    debugPrint('--------------------------------------------------');

    try {
      final request = http.MultipartRequest('PUT', url);

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          fotoFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('--------------------------------------------------');
      debugPrint('📥 [RESPUESTA FOTO] Código HTTP: ${response.statusCode}');
      debugPrint('📥 [RESPUESTA FOTO] Respuesta Servidor: ${response.body}');
      debugPrint('--------------------------------------------------');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
          if (data.containsKey('id') && data['id'] != null) {
            return UsuarioModel.fromJson(data);
          }
        } catch (e) {
          debugPrint('⚠️ [FOTO] No se parseó directamente el JSON devuelto ($e). Reconsultando perfil por ID...');
        }

        return await obtenerUsuarioPorId(id);
      } else {
        throw Exception(
          'Error al actualizar foto (${response.statusCode}): ${response.body.isNotEmpty ? response.body : response.reasonPhrase}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [EXCEPCIÓN FOTO] Error: $e');
      debugPrint('❌ [EXCEPCIÓN FOTO] StackTrace: $stackTrace');
      throw Exception('Error al subir la foto de perfil: $e');
    }
  }
}