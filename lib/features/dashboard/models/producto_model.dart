class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precioUnidad;
  final int idCategoria;
  final String categoria;
  final String? imgProducto;
  final String? telefono;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioUnidad,
    required this.idCategoria,
    required this.categoria,
    this.imgProducto,
    this.telefono,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precioUnidad: (json['precioUnidad'] as num?)?.toDouble() ?? 0.0,
      idCategoria: json['id_categoria'] ?? 0,
      categoria: json['categoria'] ?? '',
      // Se mapea exactamente la clave que envía la API: imgProdcuto
      imgProducto: json['imgProdcuto'],
      telefono: json['telefono'],
    );
  }
}