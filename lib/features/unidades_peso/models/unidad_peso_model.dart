class UnidadPeso {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? createAt;
  final String? updateAt;

  UnidadPeso({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.createAt,
    this.updateAt,
  });

  factory UnidadPeso.fromJson(Map<String, dynamic> json) {
    return UnidadPeso(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      createAt: json['createAt'],
      updateAt: json['updateAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'createAt': createAt,
      'updateAt': updateAt,
    };
  }
}

/// Respuesta paginada según el JSON de Swagger
class PaginatedUnidadesPeso {
  final List<UnidadPeso> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;

  PaginatedUnidadesPeso({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
  });

  factory PaginatedUnidadesPeso.fromJson(Map<String, dynamic> json) {
    final List rawList = json['content'] ?? [];
    final items = rawList.map((item) => UnidadPeso.fromJson(item)).toList();

    return PaginatedUnidadesPeso(
      content: items,
      pageNumber: json['pageNumber'] ?? json['number'] ?? 0,
      pageSize: json['pageSize'] ?? json['size'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}