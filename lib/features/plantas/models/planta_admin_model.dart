class PlantaAdminModel {
  final int id;
  final String nombre;
  final String? nombreCientifico;
  final String? descripcion;
  final String? img;
  final int? idFamilia;
  final String? nombreFamilia;
  final int? idGenero;
  final String? nombreGenero;
  final int? idEspecie;
  final String? nombreEspecie;
  final int? idTipo;
  final String? nombreTipo;

  PlantaAdminModel({
    required this.id,
    required this.nombre,
    this.nombreCientifico,
    this.descripcion,
    this.img,
    this.idFamilia,
    this.nombreFamilia,
    this.idGenero,
    this.nombreGenero,
    this.idEspecie,
    this.nombreEspecie,
    this.idTipo,
    this.nombreTipo,
  });

  factory PlantaAdminModel.fromJson(Map<String, dynamic> json) {
    return PlantaAdminModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      nombreCientifico: json['nombreCientifico'] as String?,
      descripcion: json['descripcion'] as String?,
      img: json['img'] as String?,
      idFamilia: json['idFamilia'] as int?,
      nombreFamilia: json['nombreFamilia'] as String?,
      idGenero: json['idGenero'] as int?,
      nombreGenero: json['nombreGenero'] as String?,
      idEspecie: json['idEspecie'] as int?,
      nombreEspecie: json['nombreEspecie'] as String?,
      idTipo: json['idTipo'] as int?,
      nombreTipo: json['nombreTipo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nombreCientifico': nombreCientifico,
      'descripcion': descripcion,
      'img': img,
      'idFamilia': idFamilia,
      'nombreFamilia': nombreFamilia,
      'idGenero': idGenero,
      'nombreGenero': nombreGenero,
      'idEspecie': idEspecie,
      'nombreEspecie': nombreEspecie,
      'idTipo': idTipo,
      'nombreTipo': nombreTipo,
    };
  }
}