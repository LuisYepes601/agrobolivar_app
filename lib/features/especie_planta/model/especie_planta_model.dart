class EspeciePlantaModel {
  final int id;
  final String nombre;
  final String? descripcion;

  EspeciePlantaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory EspeciePlantaModel.fromJson(Map<String, dynamic> json) {
    return EspeciePlantaModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nombre: json['nombre']?.toString().trim() ?? '',
      descripcion: json['descripcion']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  EspeciePlantaModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
  }) {
    return EspeciePlantaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}