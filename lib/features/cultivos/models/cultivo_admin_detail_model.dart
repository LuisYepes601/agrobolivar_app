

class CultivoAdminDetailModel {
  final int id;
  final int idUser;
  final String nombreUsuario;
  final String nombreCultivo;
  final String? urlImgCultivo;
  final String? fechaInicio;
  final String? fechaEstimadaFin;
  final double cantidadSembrada;
  final int idUnidadPeso;
  final String unidadPeso;
  final double areaSembradaValor;
  final int idAreaSembrada;
  final String areaSembradaUnidad;
  final int idEstadoCultivo;
  final String estadoCultivo;
  final double cantidadDisponible;
  final double precioPorKg;
  final double cantidadDisponibleParaVenta;
  final String? email;
  final String? telefono;

  CultivoAdminDetailModel({
    required this.id,
    required this.idUser,
    required this.nombreUsuario,
    required this.nombreCultivo,
    this.urlImgCultivo,
    this.fechaInicio,
    this.fechaEstimadaFin,
    required this.cantidadSembrada,
    required this.idUnidadPeso,
    required this.unidadPeso,
    required this.areaSembradaValor,
    required this.idAreaSembrada,
    required this.areaSembradaUnidad,
    required this.idEstadoCultivo,
    required this.estadoCultivo,
    required this.cantidadDisponible,
    required this.precioPorKg,
    required this.cantidadDisponibleParaVenta,
    this.email,
    this.telefono,
  });

  factory CultivoAdminDetailModel.fromJson(Map<String, dynamic> json) {
    return CultivoAdminDetailModel(
      id: json['id'] ?? 0,
      idUser: json['id_user'] ?? 0,
      nombreUsuario: json['nombre_usuario'] ?? '',
      nombreCultivo: json['nombre_cultivo'] ?? '',
      urlImgCultivo: json['url_img_cultivo'],
      fechaInicio: json['fechaInicio'],
      fechaEstimadaFin: json['fechaEstimadaFin'],
      cantidadSembrada: (json['cantidadSembrada'] as num?)?.toDouble() ?? 0.0,
      idUnidadPeso: json['id_unidad_peso'] ?? 0,
      unidadPeso: json['unidad_peso'] ?? 'kg',
      areaSembradaValor: (json['area_sembrada'] as num?)?.toDouble() ?? 0.0,
      idAreaSembrada: json['id_area_sembrada'] ?? 0,
      areaSembradaUnidad: json['areaSembrada'] ?? '',
      idEstadoCultivo: json['id_estado_cultivo'] ?? 0,
      estadoCultivo: json['estado_cultivo'] ?? '',
      cantidadDisponible: (json['cantidadDisponible'] as num?)?.toDouble() ?? 0.0,
      precioPorKg: (json['precioPorKg'] as num?)?.toDouble() ?? 0.0,
      cantidadDisponibleParaVenta: (json['cantidadDisponibleParaVenta'] as num?)?.toDouble() ?? 0.0,
      email: json['email'],
      telefono: json['telefono'],
    );
  }
}