class EstacionCultivoModel {
  final int? id;
  final String? nombre;
  final String? descripcion;

  EstacionCultivoModel({
    this.id,
    this.nombre,
    this.descripcion,
  });

  factory EstacionCultivoModel.fromJson(Map<String, dynamic> json) {
    return EstacionCultivoModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      nombre: json['nombre']?.toString() ?? json['estacion']?.toString(),
      descripcion: json['descripcion']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }
}