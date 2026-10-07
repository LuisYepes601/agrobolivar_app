import 'dart:convert';

class PlantaModel {
  final int id;
  final String nombre;

  PlantaModel({
    required this.id,
    required this.nombre,
  });

  factory PlantaModel.fromJson(Map<String, dynamic> json) {
    return PlantaModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id'].toString()) ?? 0),
      nombre: json['nombre'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }

  factory PlantaModel.fromRawJson(String str) => PlantaModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}