class RegisterRequestModel {
  final String primerNombre;
  final String? segundoNombre;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String email;
  final int idRol;
  final int idTipoDoc;
  final String contrasenia;
  final String numDocumento;
  final String? telefono;

  RegisterRequestModel({
    required this.primerNombre,
    this.segundoNombre,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.email,
    required this.idRol,
    required this.idTipoDoc,
    required this.contrasenia,
    required this.numDocumento,
    this.telefono,
  });

  Map<String, dynamic> toJson() {
    return {
      'primerNombre': primerNombre,
      'segundoNombre': segundoNombre ?? '',
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno ?? '',
      'email': email,
      'id_rol': idRol,
      'id_tipo_doc': idTipoDoc,
      'contrasenia': contrasenia,
      'numDocumento': numDocumento,
      'telefono': telefono ?? '',
    };
  }
}