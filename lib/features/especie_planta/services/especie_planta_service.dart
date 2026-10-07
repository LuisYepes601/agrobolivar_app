import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agro_bolivar/features/especie_planta/model/especie_planta_model.dart';

class EspeciePlantaService {
  final String baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1/especies-plantas/admin';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Obtiene la lista de especies de planta con impresión de logs en consola
  Future<List<EspeciePlantaModel>> fetchEspecies({String? nombre}) async {
    final queryParams = <String, String>{};
    if (nombre != null && nombre.isNotEmpty) queryParams['nombre'] = nombre;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    print('================ [EspeciePlantaService] ================');
    print('🌐 REQUEST URL: $uri');
    print('🔑 HEADERS: $_headers');

    try {
      final response = await http.get(uri, headers: _headers);

      print('📊 STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');
      print('======================================================');

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        List<dynamic> listData = [];

        if (decodedData is List) {
          listData = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          // Soporte si la respuesta es paginada ({ "content": [...] } o { "data": [...] })
          listData = decodedData['content'] ?? decodedData['data'] ?? [];
        }

        final especies = listData.map((json) => EspeciePlantaModel.fromJson(json)).toList();
        print('✅ ESPECIES OBTENIDAS CON ÉXITO: ${especies.length} elementos.');
        return especies;
      } else {
        throw Exception(
            'Error al cargar especies. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN CAPTURADA: $e');
      print('📍 STACKTRACE:\n$stackTrace');
      print('======================================================');
      rethrow;
    }
  }

  /// Obtiene una especie por su ID
  Future<EspeciePlantaModel> getEspecieById(int id) async {
    final url = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return EspeciePlantaModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Especie no encontrada ID: $id');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Crea una nueva especie de planta
  Future<EspeciePlantaModel> createEspecie(EspeciePlantaModel especie) async {
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(especie.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return EspeciePlantaModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear la especie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al enviar datos: $e');
    }
  }

  /// Actualiza una especie existente
  Future<EspeciePlantaModel> updateEspecie(int id, EspeciePlantaModel especie) async {
    final url = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(especie.toJson()),
      );

      if (response.statusCode == 200) {
        return EspeciePlantaModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al actualizar la especie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar datos: $e');
    }
  }

  /// Elimina una especie por ID
  Future<bool> deleteEspecie(int id) async {
    final url = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.delete(url, headers: _headers);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error al eliminar especie: $e');
    }
  }
}