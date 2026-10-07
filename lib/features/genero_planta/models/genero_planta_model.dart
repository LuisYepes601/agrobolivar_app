class GeneroPlantaModel {
  final int? id;
  final String? nombre;
  final String? descripcion;

  GeneroPlantaModel({
    this.id,
    this.nombre,
    this.descripcion,
  });

  factory GeneroPlantaModel.fromJson(Map<String, dynamic> json) {
    return GeneroPlantaModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      nombre: json['nombre'] as String?,
      descripcion: json['descripcion'] as String?,
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