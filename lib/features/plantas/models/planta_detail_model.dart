class PlantaDetailModel {
  final int? id;
  final String? nombre;
  final String? nombreCientifico;
  final String? descripcion;

  // Condiciones Ambientales
  final double? temperaturaMinima;
  final double? temperaturaMaxima;
  final double? temperaturaIdeal;

  final double? humedadMinima;
  final double? humedadMaxima;
  final double? humedadIdeal;

  final double? horasSolaresMinimas;
  final double? horasSolaresMaximas;
  final double? horasSolaresIdeales;

  final double? precipitacionMinima;
  final double? precipitacionMaxima;
  final double? precipitacionIdeal;

  final double? altitudMinima;
  final double? altitudMaxima;

  final double? phSueloMinimo;
  final double? phSueloMaximo;
  final double? phSueloIdeal;

  final String? frecuenciaRiego;

  // Taxonomía y Clasificación
  final int? idFamiliaBotanica;
  final String? nombreFamiliaBotanica;

  final int? idGeneroPlanta;
  final String? nombreGenero;

  final int? idEspecie;
  final String? nombreEspecie;

  final int? idCicloProduccion;
  final String? nombreCicloProduccion;

  final int? idCicloGerminacion;
  final String? nombreCicloGerminacion;

  final int? idEstacionCultivo;
  final String? nombreEstacionCultivo;

  final int? idTipoPlanta;
  final String? nombreTipoPlanta;

  PlantaDetailModel({
    this.id,
    this.nombre,
    this.nombreCientifico,
    this.descripcion,
    this.temperaturaMinima,
    this.temperaturaMaxima,
    this.temperaturaIdeal,
    this.humedadMinima,
    this.humedadMaxima,
    this.humedadIdeal,
    this.horasSolaresMinimas,
    this.horasSolaresMaximas,
    this.horasSolaresIdeales,
    this.precipitacionMinima,
    this.precipitacionMaxima,
    this.precipitacionIdeal,
    this.altitudMinima,
    this.altitudMaxima,
    this.phSueloMinimo,
    this.phSueloMaximo,
    this.phSueloIdeal,
    this.frecuenciaRiego,
    this.idFamiliaBotanica,
    this.nombreFamiliaBotanica,
    this.idGeneroPlanta,
    this.nombreGenero,
    this.idEspecie,
    this.nombreEspecie,
    this.idCicloProduccion,
    this.nombreCicloProduccion,
    this.idCicloGerminacion,
    this.nombreCicloGerminacion,
    this.idEstacionCultivo,
    this.nombreEstacionCultivo,
    this.idTipoPlanta,
    this.nombreTipoPlanta,
  });

  factory PlantaDetailModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic val) => (val as num?)?.toDouble();
    int? _toInt(dynamic val) => (val as num?)?.toInt();

    return PlantaDetailModel(
      id: _toInt(json['id']),
      nombre: json['nombre'] as String?,
      nombreCientifico: json['nombre_cientifico'] as String?,
      descripcion: json['descripcion'] as String?,

      temperaturaMinima: _toDouble(json['temperaturaMinima']),
      temperaturaMaxima: _toDouble(json['temperaturaMaxima']),
      temperaturaIdeal: _toDouble(json['temperaturaIdeal']),

      humedadMinima: _toDouble(json['humedadMinima']),
      humedadMaxima: _toDouble(json['humedadMaxima']),
      humedadIdeal: _toDouble(json['humedadIdeal']),

      horasSolaresMinimas: _toDouble(json['horasSolaresMinimas']),
      horasSolaresMaximas: _toDouble(json['horasSolaresMaximas']),
      horasSolaresIdeales: _toDouble(json['horasSolaresIdeales']),

      precipitacionMinima: _toDouble(json['precipitacionMinima']),
      precipitacionMaxima: _toDouble(json['precipitacionMaxima']),
      precipitacionIdeal: _toDouble(json['precipitacionIdeal']),

      altitudMinima: _toDouble(json['altitudMinima']),
      altitudMaxima: _toDouble(json['altitudMaxima']),

      phSueloMinimo: _toDouble(json['phSueloMinimo']),
      phSueloMaximo: _toDouble(json['phSueloMaximo']),
      phSueloIdeal: _toDouble(json['phSueloIdeal']),

      frecuenciaRiego: json['frecuenciaRiego'] as String?,

      idFamiliaBotanica: _toInt(json['id_familia_botanica']),
      nombreFamiliaBotanica: json['nombre_familia_botanica'] as String?,

      idGeneroPlanta: _toInt(json['id_genero_planta']),
      nombreGenero: json['nombre_genero'] as String?,

      idEspecie: _toInt(json['id_especie']),
      nombreEspecie: json['nombre_especie'] as String?,

      idCicloProduccion: _toInt(json['id_ciclo_produccion']),
      nombreCicloProduccion: json['nombre_ciclo_produccion'] as String?,

      idCicloGerminacion: _toInt(json['id_ciclo_germinacion']),
      nombreCicloGerminacion: json['nombre_ciclo_germinacion'] as String?,

      idEstacionCultivo: _toInt(json['id_estacion_cultivo']),
      nombreEstacionCultivo: json['nombre_estacion_cultivo'] as String?,

      idTipoPlanta: _toInt(json['id_tipo_planta']),
      nombreTipoPlanta: json['nombre_tipo_planta'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nombre_cientifico': nombreCientifico,
      'descripcion': descripcion,
      'temperaturaMinima': temperaturaMinima,
      'temperaturaMaxima': temperaturaMaxima,
      'temperaturaIdeal': temperaturaIdeal,
      'humedadMinima': humedadMinima,
      'humedadMaxima': humedadMaxima,
      'humedadIdeal': humedadIdeal,
      'horasSolaresMinimas': horasSolaresMinimas,
      'horasSolaresMaximas': horasSolaresMaximas,
      'horasSolaresIdeales': horasSolaresIdeales,
      'precipitacionMinima': precipitacionMinima,
      'precipitacionMaxima': precipitacionMaxima,
      'precipitacionIdeal': precipitacionIdeal,
      'altitudMinima': altitudMinima,
      'altitudMaxima': altitudMaxima,
      'phSueloMinimo': phSueloMinimo,
      'phSueloMaximo': phSueloMaximo,
      'phSueloIdeal': phSueloIdeal,
      'frecuenciaRiego': frecuenciaRiego,
      'id_familia_botanica': idFamiliaBotanica,
      'nombre_familia_botanica': nombreFamiliaBotanica,
      'id_genero_planta': idGeneroPlanta,
      'nombre_genero': nombreGenero,
      'id_especie': idEspecie,
      'nombre_especie': nombreEspecie,
      'id_ciclo_produccion': idCicloProduccion,
      'nombre_ciclo_produccion': nombreCicloProduccion,
      'id_ciclo_germinacion': idCicloGerminacion,
      'nombre_ciclo_germinacion': nombreCicloGerminacion,
      'id_estacion_cultivo': idEstacionCultivo,
      'nombre_estacion_cultivo': nombreEstacionCultivo,
      'id_tipo_planta': idTipoPlanta,
      'nombre_tipo_planta': nombreTipoPlanta,
    };
  }
}