class CicloGerminacionModel {
  final int id;
  final String nombre;
  final String? descripcion;

  CicloGerminacionModel({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory CicloGerminacionModel.fromJson(Map<String, dynamic> json) {
    return CicloGerminacionModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}