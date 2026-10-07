class CultivoAdminModel {
  final int id;
  final String nombre;
  final String? email;
  final String? telefono;
  final String? urlFoto;
  final String estado;
  final double precioPorKg;

  CultivoAdminModel({
    required this.id,
    required this.nombre,
    this.email,
    this.telefono,
    this.urlFoto,
    required this.estado,
    required this.precioPorKg,
  });

  factory CultivoAdminModel.fromJson(Map<String, dynamic> json) {
    return CultivoAdminModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'],
      telefono: json['telefono'],
      urlFoto: json['urlFoto'],
      estado: json['estado'] ?? '',
      precioPorKg: (json['precioPorKg'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'urlFoto': urlFoto,
      'estado': estado,
      'precioPorKg': precioPorKg,
    };
  }
}