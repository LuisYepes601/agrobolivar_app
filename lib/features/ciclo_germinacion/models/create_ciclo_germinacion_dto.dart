// lib/features/ciclo_germinacion/models/create_ciclo_germinacion_dto.dart

class CreateCicloGerminacionDto {
  final String nombre;
  final int? diasMinimos;
  final int? diasMaximos;
  final String? descripcion;

  CreateCicloGerminacionDto({
    required this.nombre,
    this.diasMinimos,
    this.diasMaximos,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (diasMinimos != null) 'diasMinimos': diasMinimos,
      if (diasMaximos != null) 'diasMaximos': diasMaximos,
      if (descripcion != null && descripcion!.trim().isNotEmpty)
        'descripcion': descripcion!.trim(),
    };
  }

  factory CreateCicloGerminacionDto.fromJson(Map<String, dynamic> json) {
    return CreateCicloGerminacionDto(
      nombre: json['nombre'] as String? ?? '',
      diasMinimos: json['diasMinimos'] != null
          ? int.tryParse(json['diasMinimos'].toString())
          : null,
      diasMaximos: json['diasMaximos'] != null
          ? int.tryParse(json['diasMaximos'].toString())
          : null,
      descripcion: json['descripcion'] as String?,
    );
  }
}