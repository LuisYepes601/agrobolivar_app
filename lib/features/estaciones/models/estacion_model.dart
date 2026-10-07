class EstacionModel {
  final int id;
  final String nombre;
  final bool estado;

  EstacionModel({
    required this.id,
    required this.nombre,
    required this.estado,
  });

  factory EstacionModel.fromJson(Map<String, dynamic> json) {
    return EstacionModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] as int? ?? 0),
      nombre: json['nombre'] as String? ?? '',
      estado: json['estado'] as bool? ?? json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'estado': estado,
    };
  }
}