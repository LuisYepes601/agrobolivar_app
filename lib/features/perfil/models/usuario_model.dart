import 'dart:convert';

class UsuarioModel {
  final int id;
  final String primerNombre;
  final String? segundoNombre;
  final String email;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String? rol;
  final String? tipoDocumento;
  final bool estado;
  final String? imgUser;
  final String? numDocumento;
  final String? telefono;

  UsuarioModel({
    required this.id,
    required this.primerNombre,
    this.segundoNombre,
    required this.email,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    this.rol,
    this.tipoDocumento,
    this.estado = true,
    this.imgUser,
    this.numDocumento,
    this.telefono,
  });

  /// Propiedad calculada para obtener el nombre completo formateado
  String get nombreCompleto {
    final nombres = [
      primerNombre,
      if (segundoNombre != null && segundoNombre!.trim().isNotEmpty) segundoNombre,
      apellidoPaterno,
      if (apellidoMaterno != null && apellidoMaterno!.trim().isNotEmpty) apellidoMaterno,
    ];
    return nombres.join(' ');
  }

  /// Propiedad calculada para mostrar Nombre y Primer Apellido
  String get nombreCorto {
    return '$primerNombre $apellidoPaterno';
  }

  /// Factory constructor para mapear el JSON que devuelve la API de Spring Boot
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      primerNombre: json['primerNombre'] ?? '',
      segundoNombre: json['segundoNombre'],
      email: json['email'] ?? '',
      apellidoPaterno: json['apellidoPaterno'] ?? '',
      apellidoMaterno: json['apellidoMaterno'],
      rol: json['rol'],
      tipoDocumento: json['tipoDocumento'],
      estado: json['estado'] ?? false,
      imgUser: json['imgUser'],
      numDocumento: json['numDocumento'],
      telefono: json['telefono'],
    );
  }

  /// Método para convertir el objeto a JSON en caso de enviar actualizaciones
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'primerNombre': primerNombre,
      'segundoNombre': segundoNombre,
      'email': email,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'rol': rol,
      'tipoDocumento': tipoDocumento,
      'estado': estado,
      'imgUser': imgUser,
      'numDocumento': numDocumento,
      'telefono': telefono,
    };
  }

  /// Helper para decodificar desde String JSON directamente
  factory UsuarioModel.fromRawJson(String str) =>
      UsuarioModel.fromJson(json.decode(str));

  /// Helper para codificar a String JSON
  String toRawJson() => json.encode(toJson());
}