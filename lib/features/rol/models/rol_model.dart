// lib/features/rol/models/rol_model.dart

class RolModel {
  final int id;
  final String nombre;
  final String? descripcion;

  RolModel({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory RolModel.fromJson(Map<String, dynamic> json) {
    return RolModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String? ?? '',
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