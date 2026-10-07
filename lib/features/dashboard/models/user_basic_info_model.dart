class UserBasicInfo {
  final String nombre;
  final String rol;
  final String? fotoPerfil;

  UserBasicInfo({
    required this.nombre,
    required this.rol,
    this.fotoPerfil,
  });

  factory UserBasicInfo.fromJson(Map<String, dynamic> json) {
    return UserBasicInfo(
      nombre: json['nombre'] ?? '',
      rol: json['rol'] ?? '',
      fotoPerfil: json['fotoPerfil'],
    );
  }
}