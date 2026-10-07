class ProductoDetalle {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precioUnidad;
  final String categoria;
  final String? imgProducto;
  final String marcaProducto;
  final String unidadPeso;
  final double peso;
  final double cantidadMinima;
  final double cantidadMax;
  final double cantActual;

  ProductoDetalle({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precioUnidad,
    required this.categoria,
    this.imgProducto,
    required this.marcaProducto,
    required this.unidadPeso,
    required this.peso,
    required this.cantidadMinima,
    required this.cantidadMax,
    required this.cantActual,
  });

  factory ProductoDetalle.fromJson(Map<String, dynamic> json) {
    return ProductoDetalle(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precioUnidad: (json['precioUnidad'] as num?)?.toDouble() ?? 0.0,
      categoria: json['categoria'] ?? '',
      // Soporta tanto 'imgProdcuto' (del JSON de la API) como 'imgProducto'
      imgProducto: json['imgProdcuto'] ?? json['imgProducto'],
      marcaProducto: json['marcaProducto'] ?? '',
      unidadPeso: json['unidadPeso'] ?? '',
      peso: (json['peso'] as num?)?.toDouble() ?? 0.0,
      cantidadMinima: (json['cantidadMinima'] as num?)?.toDouble() ?? 0.0,
      cantidadMax: (json['cantidadMax'] as num?)?.toDouble() ?? 0.0,
      cantActual: (json['cantActual'] as num?)?.toDouble() ?? 0.0,
    );
  }
}