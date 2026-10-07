class CicloProduccionModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final bool? active;

  CicloProduccionModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.active,
  });

  factory CicloProduccionModel.fromJson(Map<String, dynamic> json) {
    return CicloProduccionModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ??
          json['nombreCicloProduccion']?.toString() ??
          json['nombre_ciclo_produccion']?.toString() ??
          '',
      descripcion: json['descripcion']?.toString(),
      active: json['active'] is bool ? json['active'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (active != null) 'active': active,
    };
  }

  @override
  String toString() => 'CicloProduccionModel(id: $id, nombre: $nombre)';
}