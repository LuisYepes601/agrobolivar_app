import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/producto_model.dart';
import '../models/producto_detalle_model.dart';
import '../models/informacion_seguridad_model.dart';

class ProductosPageResponse {
  final List<Producto> productos;
  final int currentPage;
  final int totalPages;
  final int totalElements;

  ProductosPageResponse({
    required this.productos,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
  });
}

class ProductoService {
  static String get baseUrl {
  
    return 'https://agro-bolivar-api-1.onrender.com';
  }

  // 1. Obtener lista paginada y filtrada del catálogo general (Tienda)
  Future<ProductosPageResponse> fetchProductos({
    int page = 0,
    int size = 10,
    String? nombre,
    int? idCat,
    int? idMarca,
    double? precioMin,
    double? precioMax,
    String? sort,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };

    if (nombre != null && nombre.trim().isNotEmpty) {
      queryParams['nombre'] = nombre.trim();
    }
    if (idCat != null) {
      queryParams['id_cat'] = idCat.toString();
    }
    if (idMarca != null) {
      queryParams['id_marca'] = idMarca.toString();
    }
    if (precioMin != null) {
      queryParams['precio_min'] = precioMin.toString();
    }
    if (precioMax != null) {
      queryParams['precio_max'] = precioMax.toString();
    }
    if (sort != null && sort.trim().isNotEmpty) {
      queryParams['sort'] = sort.trim();
    }

    final url = Uri.parse('$baseUrl/api/v1/productos').replace(
      queryParameters: queryParams,
    );

    debugPrint('🚀 Solicitando productos generales a: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> content = body['content'] ?? [];

        final productos = content.map((item) => Producto.fromJson(item)).toList();

        return ProductosPageResponse(
          productos: productos,
          currentPage: body['pageNumber'] ?? body['number'] ?? page,
          totalPages: body['totalPages'] ?? 1,
          totalElements: body['totalElements'] ?? productos.length,
        );
      } else {
        throw Exception('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error en fetchProductos: $e');
      rethrow;
    }
  }

  // 2. Obtener lista paginada y filtrada de mis productos por ID de usuario
  Future<ProductosPageResponse> fetchMisProductos(
      int userId, {
        int page = 0,
        int size = 10,
        String? nombre,
        int? idCat,
        int? idMarca,
        double? precioMin,
        double? precioMax,
        String? sort,
      }) async {
    final Map<String, String> queryParams = {
      'id_user': userId.toString(),
      'page': page.toString(),
      'size': size.toString(),
    };

    if (nombre != null && nombre.trim().isNotEmpty) {
      queryParams['nombre'] = nombre.trim();
    }
    if (idCat != null) {
      queryParams['id_cat'] = idCat.toString();
    }
    if (idMarca != null) {
      queryParams['id_marca'] = idMarca.toString();
    }
    if (precioMin != null) {
      queryParams['precio_min'] = precioMin.toString();
    }
    if (precioMax != null) {
      queryParams['precio_max'] = precioMax.toString();
    }
    if (sort != null && sort.trim().isNotEmpty) {
      queryParams['sort'] = sort.trim();
    }

    final url = Uri.parse('$baseUrl/api/v1/productos').replace(
      queryParameters: queryParams,
    );

    debugPrint('🚀 Solicitando lista de productos a: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> content = body['content'] ?? [];

        final productos = content.map((item) => Producto.fromJson(item)).toList();

        return ProductosPageResponse(
          productos: productos,
          currentPage: body['pageNumber'] ?? body['number'] ?? page,
          totalPages: body['totalPages'] ?? 1,
          totalElements: body['totalElements'] ?? productos.length,
        );
      } else {
        throw Exception('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error en fetchMisProductos: $e');
      rethrow;
    }
  }

  // 3. Obtener un producto individual por ID
  Future<ProductoDetalle> fetchProductoById(int id) async {
    final url = Uri.parse('$baseUrl/api/v1/productos/$id');
    debugPrint('🚀 Solicitando detalle de producto $id a: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return ProductoDetalle.fromJson(body);
      } else {
        throw Exception('Error al obtener el producto $id: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error en fetchProductoById: $e');
      rethrow;
    }
  }

  // 4. Obtener información de seguridad por ID de producto
  Future<InformacionSeguridad?> fetchInformacionSeguridadByProductoId(int productoId) async {
    final url = Uri.parse('$baseUrl/api/v1/informaciones-seguridad/admin/$productoId/producto');
    debugPrint('🚀 Solicitando seguridad del producto $productoId a: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return InformacionSeguridad.fromJson(body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ Sin información de seguridad o error para el producto $productoId: $e');
      return null;
    }
  }

  // 5. Actualizar producto (PUT multipart/form-data)
  Future<bool> actualizarProducto({
    required int idProducto,
    required Map<String, dynamic> productoData,
    File? fotoProducto,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/productos/$idProducto');
    debugPrint('🚀 Actualizando producto $idProducto en: $url');

    try {
      final request = http.MultipartRequest('PUT', url);

      request.files.add(
        http.MultipartFile.fromString(
          'body',
          jsonEncode(productoData),
          contentType: MediaType('application', 'json'),
        ),
      );

      if (fotoProducto != null && await fotoProducto.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'fotoProducto',
            fotoProducto.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Producto actualizado con éxito');
        return true;
      } else {
        debugPrint('❌ Error al actualizar producto (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Excepción en actualizarProducto: $e');
      rethrow;
    }
  }

  // 6. Crear producto (POST multipart/form-data)
  Future<bool> crearProducto({
    required Map<String, dynamic> productoData,
    File? fotoProducto,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/productos');
    debugPrint('🚀 Creando nuevo producto en: $url');

    try {
      final request = http.MultipartRequest('POST', url);

      request.files.add(
        http.MultipartFile.fromString(
          'body',
          jsonEncode(productoData),
          contentType: MediaType('application', 'json'),
        ),
      );

      if (fotoProducto != null && await fotoProducto.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'fotoProducto',
            fotoProducto.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Producto creado con éxito');
        return true;
      } else {
        debugPrint('❌ Error al crear producto (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Excepción en crearProducto: $e');
      rethrow;
    }
  }
}