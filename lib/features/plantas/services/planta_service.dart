import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/planta_admin_model.dart';
import '../models/planta_detail_model.dart';
import '../models/planta_model.dart';

class PlantaService {
  static const String _baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1/plantas/admin';

  /// Crea una nueva planta (`POST /api/v1/plantas/admin`) mediante Multipart/Form-Data
  Future<bool> crearPlanta({
    required Map<String, dynamic> body,
    File? fotoPlanta,
    String fileFieldName = 'fotoPlanta',
  }) async {
    try {
      final uri = Uri.parse(_baseUrl);

      debugPrint('--> [PlantaService.crearPlanta] POST: $uri');
      debugPrint('📤 [PlantaService.crearPlanta] Body Map: ${jsonEncode(body)}');

      final request = http.MultipartRequest('POST', uri);

      // 1. Parte JSON 'body' con Content-Type: application/json (@RequestPart("body"))
      request.files.add(
        http.MultipartFile.fromString(
          'body',
          jsonEncode(body),
          contentType: MediaType('application', 'json'),
        ),
      );

      // 2. Parte de archivo 'fotoPlanta' (@RequestPart("fotoPlanta"))
      if (fotoPlanta != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            fotoPlanta.path,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Servidor no responde al crear la planta.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('<-- [PlantaService.crearPlanta] Status Code: ${response.statusCode}');
      debugPrint('📦 [PlantaService.crearPlanta] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('--> [PlantaService] Planta creada con éxito');
        return true;
      } else {
        throw Exception('Error al crear la planta (${response.statusCode}):${response.body}');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PlantaService.crearPlanta]: $e');
      rethrow;
    }
  }

  /// Obtiene la lista de plantas para administración mapeando directamente a List<PlantaAdminModel>
  Future<List<PlantaAdminModel>> fetchPlantasAdmin({
    String? nombre,
    bool? active,
    int? idEspecie,
    int? idTipo,
    int? idFamilia,
    int? idEstacionProduccion,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (nombre != null && nombre.trim().isNotEmpty) {
        queryParams['nombre'] = nombre.trim();
      }
      if (active != null) {
        queryParams['active'] = active.toString();
      }
      if (idEspecie != null) {
        queryParams['id_especie'] = idEspecie.toString();
      }
      if (idTipo != null) {
        queryParams['id_tipo'] = idTipo.toString();
      }
      if (idFamilia != null) {
        queryParams['id_familia'] = idFamilia.toString();
      }
      if (idEstacionProduccion != null) {
        queryParams['id_estacion_produccion'] = idEstacionProduccion.toString();
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

      debugPrint('--> [PlantaService.fetchPlantasAdmin] GET: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al cargar plantas de administración.');
        },
      );

      debugPrint('<-- [PlantaService.fetchPlantasAdmin] Status Code: ${response.statusCode}');
      debugPrint('📦 [PlantaService.fetchPlantasAdmin] Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> content = json['content'] ?? [];

        debugPrint('--> [PlantaService] Plantas admin obtenidas: ${content.length}');
        return content.map((item) => PlantaAdminModel.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        debugPrint('--> [PlantaService] 404 No se encontraron plantas');
        return [];
      } else {
        throw Exception('Error al obtener la lista de plantas (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PlantaService.fetchPlantasAdmin]: $e');
      rethrow;
    }
  }

  /// Obtiene el detalle completo de una planta por su ID (`/api/v1/plantas/admin/{id}`)
  Future<PlantaDetailModel> fetchPlantaAdminById(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id');

      debugPrint('--> [PlantaService.fetchPlantaAdminById] GET: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al obtener el detalle de la planta.');
        },
      );

      debugPrint('<-- [PlantaService.fetchPlantaAdminById] Status Code: ${response.statusCode}');
      debugPrint('📦 [PlantaService.fetchPlantaAdminById] Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        debugPrint('--> [PlantaService] Detalle de planta ID $id obtenido con éxito');
        return PlantaDetailModel.fromJson(json);
      } else if (response.statusCode == 404) {
        throw Exception('Planta con ID $id no encontrada.');
      } else {
        throw Exception('Error al obtener el detalle de la planta (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PlantaService.fetchPlantaAdminById]: $e');
      rethrow;
    }
  }

  /// Actualiza la foto de una planta por su ID (`/api/v1/plantas/admin/{id}/foto-planta`)
  Future<bool> updateFotoPlanta({
    required int id,
    required File imageFile,
    String fieldName = 'fotoPlanta',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id/foto-planta');

      debugPrint('--> [PlantaService.updateFotoPlanta] PUT: $uri');

      final request = http.MultipartRequest('PUT', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Servidor no responde al actualizar la foto de la planta.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('<-- [PlantaService.updateFotoPlanta] Status Code: ${response.statusCode}');
      debugPrint('📦 [PlantaService.updateFotoPlanta] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('--> [PlantaService] Foto de planta ID $id actualizada con éxito');
        return true;
      } else {
        throw Exception('Error al actualizar la foto (${response.statusCode}):${response.body}');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PlantaService.updateFotoPlanta]: $e');
      rethrow;
    }
  }

  /// Actualiza los datos básicos de la planta (`/api/v1/plantas/admin/{id}/datos-basicos`)
  Future<bool> updateDatosBasicosPlanta({
    required int id,
    required String nombre,
    required String nombreCientifico,
    required String descripcion,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id/datos-basicos');
      final bodyMap = {
        'nombre': nombre,
        'nombreCientifico': nombreCientifico,
        'descripcion': descripcion,
      };

      debugPrint('--> [PlantaService.updateDatosBasicosPlanta] PUT: $uri');
      debugPrint('📤 [PlantaService.updateDatosBasicosPlanta] Payload: ${jsonEncode(bodyMap)}');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bodyMap),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al actualizar los datos básicos.');
        },
      );

      debugPrint('<-- [PlantaService.updateDatosBasicosPlanta] Status Code: ${response.statusCode}');
      debugPrint('📦 [PlantaService.updateDatosBasicosPlanta] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('--> [PlantaService] Datos básicos de planta ID $id actualizados con éxito');
        return true;
      } else {
        throw Exception('Error al actualizar datos básicos (${response.statusCode}):${response.body}');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PlantaService.updateDatosBasicosPlanta]: $e');
      rethrow;
    }
  }

  /// Actualiza la clasificación de la planta (`/api/v1/plantas/admin/{id}/clasificacion`)
  Future<bool> updateClasificacionPlanta({
    required int id,
    int? idFamiliaBotanica,
    int? idGeneroPlanta,
    int? idEspecie,
    int? idTipoPlanta,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id/clasificacion');
      final bodyMap = {
        'idFamiliaBotanica': idFamiliaBotanica,
        'idGeneroPlanta': idGeneroPlanta,
        'idEspecie': idEspecie,
        'idTipoPlanta': idTipoPlanta,
      };

      debugPrint('--> [PlantaService.updateClasificacionPlanta] PUT: $uri');
      debugPrint('📤 [PlantaService.updateClasificacionPlanta] Payload: ${jsonEncode(bodyMap)}');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bodyMap),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al actualizar la clasificación.');
        },
      );

      debugPrint('<-- [PlantaService.updateClasificacionPlanta] Status Code: ${response.statusCode}');
      debugPrint('📦 [PlantaService.updateClasificacionPlanta] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('--> [PlantaService] Clasificación de planta ID $id actualizada con éxito');
        return true;
      } else {
        throw Exception('Error al actualizar la clasificación (${response.statusCode}):${response.body}');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PlantaService.updateClasificacionPlanta]: $e');
      rethrow;
    }
  }

  /// Actualiza los ciclos de la planta (`/api/v1/plantas/admin/{id}/ciclos`)
  Future<bool> updateCiclosPlanta({
    required int id,
    int? idCicloProduccion,
    int? idCicloGerminacion,
    int? idEstacionCultivo,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id/ciclos');
      final bodyMap = {
        'idCicloProduccion': idCicloProduccion,
        'idCicloGerminacion': idCicloGerminacion,
        'idEstacionCultivo': idEstacionCultivo,
      };

      debugPrint('--> [PlantaService.updateCiclosPlanta] PUT: $uri');
      debugPrint('📤 [PlantaService.updateCiclosPlanta] Payload: ${jsonEncode(bodyMap)}');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bodyMap),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al actualizar los ciclos.');
        },
      );

      debugPrint('<-- [PlantaService.updateCiclosPlanta] Status Code: ${response.statusCode}');
      debugPrint('📦 [PlantaService.updateCiclosPlanta] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('--> [PlantaService] Ciclos de planta ID $id actualizados con éxito');
        return true;
      } else {
        throw Exception('Error al actualizar los ciclos (${response.statusCode}):${response.body}');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PlantaService.updateCiclosPlanta]: $e');
      rethrow;
    }
  }

  /// Actualiza las condiciones climáticas de la planta (`/api/v1/plantas/admin/{id}/condiciones-climaticas`)
  Future<bool> updateCondicionesClimaticasPlanta({
    required int id,
    required double? temperaturaMinima,
    required double? temperaturaMaxima,
    required double? temperaturaIdeal,
    required double? humedadMinima,
    required double? humedadMaxima,
    required double? humedadIdeal,
    required double? horasSolaresMinimas,
    required double? horasSolaresMaximas,
    required double? horasSolaresIdeales,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id/condiciones-climaticas');
      final bodyMap = {
        'temperaturaMinima': temperaturaMinima,
        'temperaturaMaxima': temperaturaMaxima,
        'temperaturaIdeal': temperaturaIdeal,
        'humedadMinima': humedadMinima,
        'humedadMaxima': humedadMaxima,
        'humedadIdeal': humedadIdeal,
        'horasSolaresMinimas': horasSolaresMinimas,
        'horasSolaresMaximas': horasSolaresMaximas,
        'horasSolaresIdeales': horasSolaresIdeales,
      };

      debugPrint('--> [PlantaService.updateCondicionesClimaticasPlanta] PUT: $uri');
      debugPrint('📤 [PlantaService.updateCondicionesClimaticasPlanta] Payload: ${jsonEncode(bodyMap)}');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bodyMap),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al actualizar las condiciones climáticas.');
        },
      );

      debugPrint('<-- [PlantaService.updateCondicionesClimaticasPlanta] Status Code: ${response.statusCode}');
      debugPrint('📦 [PlantaService.updateCondicionesClimaticasPlanta] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('--> [PlantaService] Condiciones climáticas de planta ID $id actualizadas con éxito');
        return true;
      } else {
        throw Exception('Error al actualizar las condiciones climáticas (${response.statusCode}):${response.body}');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PlantaService.updateCondicionesClimaticasPlanta]: $e');
      rethrow;
    }
  }

  /// Actualiza las condiciones de terreno de la planta (`/api/v1/plantas/admin/{id}/condiciones-terreno`)
  Future<bool> updateCondicionesTerrenoPlanta({
    required int id,
    required double? precipitacionMinima,
    required double? precipitacionMaxima,
    required double? precipitacionIdeal,
    required double? altitudMinima,
    required double? altitudMaxima,
    required double? phSueloMinimo,
    required double? phSueloMaximo,
    required double? phSueloIdeal,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id/condiciones-terreno');
      final bodyMap = {
        'precipitacionMinima': precipitacionMinima,
        'precipitacionMaxima': precipitacionMaxima,
        'precipitacionIdeal': precipitacionIdeal,
        'altitudMinima': altitudMinima,
        'altitudMaxima': altitudMaxima,
        'phSueloMinimo': phSueloMinimo,
        'phSueloMaximo': phSueloMaximo,
        'phSueloIdeal': phSueloIdeal,
      };

      debugPrint('--> [PlantaService.updateCondicionesTerrenoPlanta] PUT: $uri');
      debugPrint('📤 [PlantaService.updateCondicionesTerrenoPlanta] Payload: ${jsonEncode(bodyMap)}');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bodyMap),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al actualizar las condiciones de terreno.');
        },
      );

      debugPrint('<-- [PlantaService.updateCondicionesTerrenoPlanta] Status Code: ${response.statusCode}');
      debugPrint('📦 [PlantaService.updateCondicionesTerrenoPlanta] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('--> [PlantaService] Condiciones de terreno de planta ID $id actualizadas con éxito');
        return true;
      } else {
        throw Exception('Error al actualizar las condiciones de terreno (${response.statusCode}):${response.body}');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PlantaService.updateCondicionesTerrenoPlanta]: $e');
      rethrow;
    }
  }

  /// Actualiza la frecuencia de riego (`/api/v1/plantas/admin/{id}/riego`)
  Future<bool> updateRiegoPlanta({
    required int id,
    required String frecuenciaRiego,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id/riego');
      final bodyMap = {
        'frecuenciaRiego': frecuenciaRiego,
      };

      debugPrint('--> [PlantaService.updateRiegoPlanta] PUT: $uri');
      debugPrint('📤 [PlantaService.updateRiegoPlanta] Payload: ${jsonEncode(bodyMap)}');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bodyMap),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al actualizar la frecuencia de riego.');
        },
      );

      debugPrint('<-- [PlantaService.updateRiegoPlanta] Status Code: ${response.statusCode}');
      debugPrint('📦 [PlantaService.updateRiegoPlanta] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('--> [PlantaService] Riego de planta ID $id actualizado con éxito');
        return true;
      } else {
        throw Exception('Error al actualizar la frecuencia de riego (${response.statusCode}):${response.body}');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PlantaService.updateRiegoPlanta]: $e');
      rethrow;
    }
  }

  /// Obtiene la lista básica de plantas desde el endpoint admin/basic
  Future<List<PlantaModel>> fetchPlantasList({int page = 0, int size = 100}) async {
    try {
      final uri = Uri.parse('$_baseUrl/basic').replace(queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      });

      debugPrint('--> [PlantaService.fetchPlantasList] GET Basic: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Servidor no responde al cargar plantas.');
        },
      );

      debugPrint('<-- [PlantaService.fetchPlantasList] Status Code: ${response.statusCode}');
      debugPrint('📦 [PlantaService.fetchPlantasList] Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> content = json['content'] ?? [];

        debugPrint('--> [PlantaService] Plantas obtenidas: ${content.length}');
        return content.map((item) => PlantaModel.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        debugPrint('--> [PlantaService] 404 No se encontraron plantas');
        return [];
      } else {
        throw Exception('Error al obtener la lista de plantas (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('x-- [EXCEPCIÓN PlantaService.fetchPlantasList]: $e');
      rethrow;
    }
  }
}