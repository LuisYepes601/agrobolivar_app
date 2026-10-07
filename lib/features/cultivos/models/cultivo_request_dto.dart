import 'dart:convert';

/// DTO para la petición (Request) de creación / actualización de Cultivo
class CultivoRequestDto {
  final String fechaInicio;
  final int idPlanta;
  final int idUser;
  final String fechaEstimadaFin;
  final double cantidadSembrada;
  final int idUnidadPeso;
  final double areaSembrada;
  final int idUnidadArea;
  final int idEstadoCultivo;
  final double cantidadDisponible;
  final double precioPorKg;
  final double cantidadDisponibleParaVenta;

  CultivoRequestDto({
    required this.fechaInicio,
    required this.idPlanta,
    required this.idUser,
    required this.fechaEstimadaFin,
    required this.cantidadSembrada,
    required this.idUnidadPeso,
    required this.areaSembrada,
    required this.idUnidadArea,
    required this.idEstadoCultivo,
    required this.cantidadDisponible,
    required this.precioPorKg,
    required this.cantidadDisponibleParaVenta,
  });

  /// Crear instancia desde un Map/JSON
  factory CultivoRequestDto.fromJson(Map<String, dynamic> json) {
    return CultivoRequestDto(
      fechaInicio: json['fechaInicio']?.toString() ?? '',
      idPlanta: _toInt(json['id_planta']),
      idUser: _toInt(json['id_user']),
      fechaEstimadaFin: json['fechaEstimadaFin']?.toString() ?? '',
      cantidadSembrada: _toDouble(json['cantidadSembrada']),
      idUnidadPeso: _toInt(json['id_unidad_peso']),
      areaSembrada: _toDouble(json['areaSembrada']),
      idUnidadArea: _toInt(json['id_unidad_area']),
      idEstadoCultivo: _toInt(json['id_estado_cultivo']),
      cantidadDisponible: _toDouble(json['cantidadDisponible']),
      precioPorKg: _toDouble(json['precioPorKg']),
      cantidadDisponibleParaVenta: _toDouble(json['cantidadDisponibleParaVenta']),
    );
  }

  /// Mapeo con los nombres exactos de claves que requiere el backend
  Map<String, dynamic> toJson() {
    return {
      'fechaInicio': fechaInicio,
      'id_planta': idPlanta,
      'id_user': idUser,
      'fechaEstimadaFin': fechaEstimadaFin,
      'cantidadSembrada': cantidadSembrada,
      'id_unidad_peso': idUnidadPeso,
      'areaSembrada': areaSembrada,
      'id_unidad_area': idUnidadArea,
      'id_estado_cultivo': idEstadoCultivo,
      'cantidadDisponible': cantidadDisponible,
      'precioPorKg': precioPorKg,
      'cantidadDisponibleParaVenta': cantidadDisponibleParaVenta,
    };
  }

  /// Serializa directamente a String JSON (ideal para pasar al campo 'body' del FormData)
  String toRawJson() => jsonEncode(toJson());

  factory CultivoRequestDto.fromRawJson(String str) =>
      CultivoRequestDto.fromJson(jsonDecode(str) as Map<String, dynamic>);

  // Métodos de conversión segura
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}