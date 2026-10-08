class InformacionPersonalDtoReq {
  final String primerNombre;
  final String? segundoNombre;
  final String email;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String numDocumento;
  final String telefono;
  final int idTipoDoc;

  InformacionPersonalDtoReq({
    required this.primerNombre,
    this.segundoNombre,
    required this.email,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.numDocumento,
    required this.telefono,
    required this.idTipoDoc,
  });

  /// Converte a instância para um Map JSON com as chaves exatas esperadas pelo backend
  Map<String, dynamic> toJson() {
    return {
      'primerNombre': primerNombre,
      'segundoNombre': segundoNombre,
      'email': email,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'numDocumento': numDocumento,
      'telefono': telefono,
      'id_tipo_doc': idTipoDoc,
    };
  }

  /// Cria uma instância a partir de um Map JSON
  factory InformacionPersonalDtoReq.fromJson(Map<String, dynamic> json) {
    return InformacionPersonalDtoReq(
      primerNombre: json['primerNombre'] as String? ?? '',
      segundoNombre: json['segundoNombre'] as String?,
      email: json['email'] as String? ?? '',
      apellidoPaterno: json['apellidoPaterno'] as String? ?? '',
      apellidoMaterno: json['apellidoMaterno'] as String? ?? '',
      numDocumento: json['numDocumento'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      idTipoDoc: (json['id_tipo_doc'] as num?)?.toInt() ?? 0,
    );
  }

  /// Permite criar uma nova instância atualizando campos específicos
  InformacionPersonalDtoReq copyWith({
    String? primerNombre,
    String? segundoNombre,
    String? email,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? numDocumento,
    String? telefono,
    int? idTipoDoc,
  }) {
    return InformacionPersonalDtoReq(
      primerNombre: primerNombre ?? this.primerNombre,
      segundoNombre: segundoNombre ?? this.segundoNombre,
      email: email ?? this.email,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      numDocumento: numDocumento ?? this.numDocumento,
      telefono: telefono ?? this.telefono,
      idTipoDoc: idTipoDoc ?? this.idTipoDoc,
    );
  }
}