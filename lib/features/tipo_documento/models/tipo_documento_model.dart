class TipoDocumentoModel {
  final int id;
  final String nombre;
  final String? descripcion;

  TipoDocumentoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory TipoDocumentoModel.fromJson(Map<String, dynamic> json) {
    return TipoDocumentoModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }
}

class PaginatedTipoDocumentoResponse {
  final List<TipoDocumentoModel> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final int numberOfElements;
  final bool empty;

  PaginatedTipoDocumentoResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.numberOfElements,
    required this.empty,
  });

  factory PaginatedTipoDocumentoResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedTipoDocumentoResponse(
      content: (json['content'] as List<dynamic>?)
          ?.map((item) => TipoDocumentoModel.fromJson(item))
          .toList() ??
          [],
      pageNumber: json['pageNumber'] ?? json['number'] ?? 0,
      pageSize: json['pageSize'] ?? json['size'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? true,
    );
  }
}