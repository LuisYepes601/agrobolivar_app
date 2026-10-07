import 'dart:convert';

class CultivoUpdateDto {
  final String? fechaInicio;
  final int? idPlanta;
  final int? idUser;
  final String? fechaEstimadaFin;
  final double? cantidadSembrada;
  final int? idUnidadPeso;
  final double? areaSembrada;
  final int? idUnidadArea;
  final int? idEstadoCultivo;
  final double? cantidadDisponible;
  final double? precioPorKg;
  final double? cantidadDisponibleParaVenta;

  CultivoUpdateDto({
    this.fechaInicio,
    this.idPlanta,
    this.idUser,
    this.fechaEstimadaFin,
    this.cantidadSembrada,
    this.idUnidadPeso,
    this.areaSembrada,
    this.idUnidadArea,
    this.idEstadoCultivo,
    this.cantidadDisponible,
    this.precioPorKg,
    this.cantidadDisponibleParaVenta,
  });

  factory CultivoUpdateDto.fromJson(Map<String, dynamic> json) => CultivoUpdateDto(
    fechaInicio: json['fechaInicio'] as String?,
    idPlanta: json['id_planta'] as int?,
    idUser: json['id_user'] as int?,
    fechaEstimadaFin: json['fechaEstimadaFin'] as String?,
    cantidadSembrada: (json['cantidadSembrada'] as num?)?.toDouble(),
    idUnidadPeso: json['id_unidad_peso'] as int?,
    areaSembrada: (json['areaSembrada'] as num?)?.toDouble(),
    idUnidadArea: json['id_unidad_area'] as int?,
    idEstadoCultivo: json['id_estado_cultivo'] as int?,
    cantidadDisponible: (json['cantidadDisponible'] as num?)?.toDouble(),
    precioPorKg: (json['precioPorKg'] as num?)?.toDouble(),
    cantidadDisponibleParaVenta: (json['cantidadDisponibleParaVenta'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    if (fechaInicio != null) 'fechaInicio': fechaInicio,
    if (idPlanta != null) 'id_planta': idPlanta,
    if (idUser != null) 'id_user': idUser,
    if (fechaEstimadaFin != null) 'fechaEstimadaFin': fechaEstimadaFin,
    if (cantidadSembrada != null) 'cantidadSembrada': cantidadSembrada,
    if (idUnidadPeso != null) 'id_unidad_peso': idUnidadPeso,
    if (areaSembrada != null) 'areaSembrada': areaSembrada,
    if (idUnidadArea != null) 'id_unidad_area': idUnidadArea,
    if (idEstadoCultivo != null) 'id_estado_cultivo': idEstadoCultivo,
    if (cantidadDisponible != null) 'cantidadDisponible': cantidadDisponible,
    if (precioPorKg != null) 'precioPorKg': precioPorKg,
    if (cantidadDisponibleParaVenta != null)
      'cantidadDisponibleParaVenta': cantidadDisponibleParaVenta,
  };

  String toRawJson() => jsonEncode(toJson());
}