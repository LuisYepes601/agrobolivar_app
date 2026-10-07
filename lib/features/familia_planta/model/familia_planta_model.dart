class FamiliaPlantaModel {
  final int id;
  final String nombre;
  final String? descripcion;

  FamiliaPlantaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory FamiliaPlantaModel.fromJson(Map<String, dynamic> json) {
    return FamiliaPlantaModel(
      id: json['id'] is String
          ? int.parse(json['id'])
          : (json['id'] as int? ?? 0),
      nombre: json['nombre'] as String? ?? json['nombreFamilia'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
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