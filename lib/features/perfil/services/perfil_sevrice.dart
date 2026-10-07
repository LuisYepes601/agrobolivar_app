import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agro_bolivar/features/auth/services/auth_local_service.dart';
import '../models/usuario_model.dart';

class UsuarioService {
  // URL base de producción en Render
  static const String _baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1/usuarios';

  final AuthLocalService _authLocalService = AuthLocalService();

  /// Obtiene los datos del usuario logueado extrayendo el ID desde LocalStorage
  Future<UsuarioModel> obtenerUsuarioActual() async {
    final dynamic rawId = await _authLocalService.getUserId();

    if (rawId == null) {
      throw Exception('No se encontró un ID de usuario registrado en el almacenamiento local.');
    }

    final int id = rawId is int ? rawId : int.parse(rawId.toString());
    return obtenerUsuarioPorId(id);
  }

  /// GET: https://agro-bolivar-api-1.onrender.com/api/v1/usuarios/{id}
  /// Consulta la información de un usuario según su ID sin requerir token
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

  /// PUT: https://agro-bolivar-api-1.onrender.com/api/v1/usuarios/{id}
  /// Actualiza los datos del usuario por su ID sin token
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
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return UsuarioModel.fromJson(data);
      } else {
        throw Exception('Error al actualizar información (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar: $e');
    }
  }
}