import 'dart:convert';

class CreateEstadoCultivoModel {
  final String nombre;
  final String? descripcion;

  CreateEstadoCultivoModel({
    required this.nombre,
    this.descripcion,
  });

  /// Convierte la instancia a un Map (JSON) para enviar en el body HTTP
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }

  /// Crea una instancia a partir de un Map
  factory CreateEstadoCultivoModel.fromJson(Map<String, dynamic> json) {
    return CreateEstadoCultivoModel(
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
    );
  }

  /// Helper para convertir la instancia directamente a un String JSON
  String toRawJson() => json.encode(toJson());

  /// Helper para instanciar desde un String JSON
  factory CreateEstadoCultivoModel.fromRawJson(String str) =>
      CreateEstadoCultivoModel.fromJson(json.decode(str) as Map<String, dynamic>);
}