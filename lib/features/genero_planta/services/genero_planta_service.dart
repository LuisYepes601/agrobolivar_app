import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/genero_planta_model.dart';

class GeneroPlantaService {
  final String baseUrl = 'https://agro-bolivar-api-1.onrender.com/api/v1/genero-plantas/admin';

  Future<List<GeneroPlantaModel>> fetchGeneros() async {
    final url = Uri.parse(baseUrl);

    print('================ [GeneroPlantaService] ================');
    print('🌐 REQUEST URL: $url');

    try {
      final response = await http.get(url);

      print('📊 STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE BODY: ${response.body}');
      print('==================================================');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        return content.map((e) => GeneroPlantaModel.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar géneros de planta: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR EN [GeneroPlantaService]: $e');
      print('==================================================');
      rethrow;
    }
  }
}