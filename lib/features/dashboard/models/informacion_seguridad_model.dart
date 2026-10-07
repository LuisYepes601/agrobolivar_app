class InformacionSeguridad {
  final int? id;
  final bool esToxico;
  final String? descripcion;
  final bool esCorrosivo;
  final bool esInflamable;
  final bool esPeligroso;
  final bool requiereEquipoProteccion;
  final bool requiereManejoEspecial;
  final String? precauciones;
  final String? advertencias;
  final String? instruccionesManejo;
  final String? instruccionesAlmacenamiento;

  InformacionSeguridad({
    this.id,
    required this.esToxico,
    this.descripcion,
    required this.esCorrosivo,
    required this.esInflamable,
    required this.esPeligroso,
    required this.requiereEquipoProteccion,
    required this.requiereManejoEspecial,
    this.precauciones,
    this.advertencias,
    this.instruccionesManejo,
    this.instruccionesAlmacenamiento,
  });

  factory InformacionSeguridad.fromJson(Map<String, dynamic> json) {
    return InformacionSeguridad(
      id: json['id'],
      esToxico: json['esToxico'] ?? false,
      descripcion: json['descripcion'],
      esCorrosivo: json['esCorrosivo'] ?? false,
      esInflamable: json['esInflamable'] ?? false,
      esPeligroso: json['esPeligroso'] ?? false,
      requiereEquipoProteccion: json['requiereEquipoProteccion'] ?? false,
      requiereManejoEspecial: json['requiereManejoEspecial'] ?? false,
      precauciones: json['precauciones'],
      advertencias: json['advertencias'],
      instruccionesManejo: json['instruccionesManejo'],
      instruccionesAlmacenamiento: json['instruccionesAlmacenamiento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "esToxico": esToxico,
      "descripcion": descripcion,
      "esCorrosivo": esCorrosivo,
      "esInflamable": esInflamable,
      "esPeligroso": esPeligroso,
      "requiereEquipoProteccion": requiereEquipoProteccion,
      "requiereManejoEspecial": requiereManejoEspecial,
      "precauciones": precauciones,
      "advertencias": advertencias,
      "instruccionesManejo": instruccionesManejo,
      "instruccionesAlmacenamiento": instruccionesAlmacenamiento,
    };
  }
}