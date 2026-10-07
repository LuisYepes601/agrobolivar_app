class UnidadArea {
  final int id;
  final String nombre;
  final String? descripcion;
  final DateTime? createAt;
  final DateTime? updateAt;

  UnidadArea({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.createAt,
    this.updateAt,
  });

  factory UnidadArea.fromJson(Map<String, dynamic> json) {
    return UnidadArea(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      createAt: json['createAt'] != null ? DateTime.tryParse(json['createAt']) : null,
      updateAt: json['updateAt'] != null ? DateTime.tryParse(json['updateAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      if (createAt != null) 'createAt': createAt!.toIso8601String(),
      if (updateAt != null) 'updateAt': updateAt!.toIso8601String(),
    };
  }
}

class PaginatedUnidadArea {
  final List<UnidadArea> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final int numberOfElements;
  final bool empty;

  PaginatedUnidadArea({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.numberOfElements,
    required this.empty,
  });

  factory PaginatedUnidadArea.fromJson(Map<String, dynamic> json) {
    var list = json['content'] as List? ?? [];
    List<UnidadArea> contentList = list.map((i) => UnidadArea.fromJson(i)).toList();

    return PaginatedUnidadArea(
      content: contentList,
      pageNumber: json['pageNumber'] ?? json['number'] ?? 0,
      pageSize: json['pageSize'] ?? json['size'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? true,
    );
  }
}