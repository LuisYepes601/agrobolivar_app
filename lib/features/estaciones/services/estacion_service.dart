import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estacion_model.dart';

class EstacionService {
  final String baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1/estacion-cultivos/admin';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Obtiene la lista de estaciones de cultivo
  Future<List<EstacionModel>> fetchEstaciones({String? nombre}) async {
    final queryParams = <String, String>{};
    if (nombre != null && nombre.trim().isNotEmpty) {
      queryParams['nombre'] = nombre.trim();
    }

    final uri = Uri.parse(baseUrl).replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    print('================ [EstacionService] ================');
    print('🌐 REQUEST URL: $uri');

    try {
      final response = await http.get(uri, headers: _headers);

      print('📊 STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');
      print('==================================================');

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        List<dynamic> listData = [];

        if (decodedData is List) {
          listData = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          listData = decodedData['content'] ?? decodedData['data'] ?? [];
        }

        return listData.map((json) => EstacionModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar estaciones. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPCIÓN EN EstacionService: $e');
      print('📍 STACKTRACE:\n$stackTrace');
      print('==================================================');
      rethrow;
    }
  }
}