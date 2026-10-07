import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/producto_detalle_model.dart';
import '../models/informacion_seguridad_model.dart';
import '../services/producto_service.dart';

import 'package:agro_bolivar/features/categorias/models/categoria_model.dart';
import 'package:agro_bolivar/features/categorias/services/categoria_service.dart';
import 'package:agro_bolivar/features/marcas/models/marca_model.dart';
import 'package:agro_bolivar/features/marcas/services/marca_service.dart';
import 'package:agro_bolivar/features/unidades_peso/models/unidad_peso_model.dart';
import 'package:agro_bolivar/features/unidades_peso/services/unidad_peso_service.dart';

class DetalleProductoScreen extends StatefulWidget {
  final int productoId;
  final bool esTienda; // 👈 Oculta el botón de edición y muestra WhatsApp solo si es true

  const DetalleProductoScreen({
    super.key,
    required this.productoId,
    this.esTienda = false, // 👈 Valor por defecto en false
  });

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  // Servicios
  final _productoService = ProductoService();
  final _categoriaService = CategoriaService();
  final _marcaService = MarcaService();
  final _unidadPesoService = UnidadPesoService();

  final _formKey = GlobalKey<FormState>();

  ProductoDetalle? _producto;
  InformacionSeguridad? _infoSeguridad;

  // Listas con tipo fuertemente tipado
  List<Categoria> _categorias = [];
  List<Marca> _marcas = [];
  List<UnidadPeso> _unidadesPeso = [];

  // IDs seleccionados para los Dropdowns
  int? _idCategoriaSeleccionada;
  int? _idMarcaSeleccionada;
  int? _idUnidadPesoSeleccionada;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _esModoEdicion = false;
  String? _errorMessage;

  // Controladores de Texto
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _precioCtrl = TextEditingController();
  final TextEditingController _pesoCtrl = TextEditingController();
  final TextEditingController _cantActualCtrl = TextEditingController();
  final TextEditingController _cantMinCtrl = TextEditingController();
  final TextEditingController _cantMaxCtrl = TextEditingController();

  // Switches e Inputs de Seguridad
  bool _esToxico = false;
  bool _esCorrosivo = false;
  bool _esInflamable = false;
  bool _esPeligroso = false;
  bool _requiereEPP = false;
  bool _requiereManejoEspecial = false;

  final TextEditingController _secDescripcionCtrl = TextEditingController();
  final TextEditingController _secPrecaucionesCtrl = TextEditingController();
  final TextEditingController _secAdvertenciasCtrl = TextEditingController();
  final TextEditingController _secManejoCtrl = TextEditingController();
  final TextEditingController _secAlmacenamientoCtrl = TextEditingController();

  File? _nuevaImagen;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarProducto();
  }

  void _poblarControladores() {
    if (_producto == null) return;

    _nombreCtrl.text = _producto!.nombre;
    _descripcionCtrl.text = _producto!.descripcion ?? '';
    _precioCtrl.text = _producto!.precioUnidad.toString();
    _pesoCtrl.text = _producto!.peso.toString();
    _cantActualCtrl.text = _producto!.cantActual.toInt().toString();
    _cantMinCtrl.text = _producto!.cantidadMinima.toInt().toString();
    _cantMaxCtrl.text = _producto!.cantidadMax.toInt().toString();

    _idCategoriaSeleccionada = _obtenerIdCategoriaActual();
    _idMarcaSeleccionada = _obtenerIdMarcaActual();
    _idUnidadPesoSeleccionada = _obtenerIdUnidadPesoActual();

    if (_infoSeguridad != null) {
      _esToxico = _infoSeguridad!.esToxico;
      _esCorrosivo = _infoSeguridad!.esCorrosivo;
      _esInflamable = _infoSeguridad!.esInflamable;
      _esPeligroso = _infoSeguridad!.esPeligroso;
      _requiereEPP = _infoSeguridad!.requiereEquipoProteccion;
      _requiereManejoEspecial = _infoSeguridad!.requiereManejoEspecial;

      _secDescripcionCtrl.text = _infoSeguridad!.descripcion ?? '';
      _secPrecaucionesCtrl.text = _infoSeguridad!.precauciones ?? '';
      _secAdvertenciasCtrl.text = _infoSeguridad!.advertencias ?? '';
      _secManejoCtrl.text = _infoSeguridad!.instruccionesManejo ?? '';
      _secAlmacenamientoCtrl.text = _infoSeguridad!.instruccionesAlmacenamiento ?? '';
    } else {
      _esToxico = false;
      _esCorrosivo = false;
      _esInflamable = false;
      _esPeligroso = false;
      _requiereEPP = false;
      _requiereManejoEspecial = false;

      _secDescripcionCtrl.clear();
      _secPrecaucionesCtrl.clear();
      _secAdvertenciasCtrl.clear();
      _secManejoCtrl.clear();
      _secAlmacenamientoCtrl.clear();
    }
  }

  int? _obtenerIdCategoriaActual() {
    if (_producto == null || _categorias.isEmpty) return null;
    try {
      final coincidencia = _categorias.firstWhere(
            (c) => c.nombre.trim().toLowerCase() == _producto!.categoria.trim().toLowerCase(),
      );
      return coincidencia.id;
    } catch (_) {
      return null;
    }
  }

  int? _obtenerIdMarcaActual() {
    if (_producto == null || _marcas.isEmpty) return null;
    try {
      final coincidencia = _marcas.firstWhere(
            (m) => m.nombre.trim().toLowerCase() == _producto!.marcaProducto.trim().toLowerCase(),
      );
      return coincidencia.id;
    } catch (_) {
      return null;
    }
  }

  int? _obtenerIdUnidadPesoActual() {
    if (_producto == null || _unidadesPeso.isEmpty) return null;
    try {
      final coincidencia = _unidadesPeso.firstWhere(
            (u) => u.nombre.trim().toLowerCase() == _producto!.unidadPeso.trim().toLowerCase(),
      );
      return coincidencia.id;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _pesoCtrl.dispose();
    _cantActualCtrl.dispose();
    _cantMinCtrl.dispose();
    _cantMaxCtrl.dispose();

    _secDescripcionCtrl.dispose();
    _secPrecaucionesCtrl.dispose();
    _secAdvertenciasCtrl.dispose();
    _secManejoCtrl.dispose();
    _secAlmacenamientoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarProducto() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _productoService.fetchProductoById(widget.productoId),
        _productoService
            .fetchInformacionSeguridadByProductoId(widget.productoId)
            .catchError((_) => null),
        _categoriaService.fetchCategorias().catchError((_) => <Categoria>[]),
        _marcaService.fetchMarcas().catchError((_) => <Marca>[]),
        _unidadPesoService.fetchUnidadesPesoList().catchError((_) => <UnidadPeso>[]),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('El servidor tardó demasiado en responder.'),
      );

      if (mounted) {
        _producto = results[0] as ProductoDetalle;
        _infoSeguridad = results[1] as InformacionSeguridad?;
        _categorias = (results[2] as List<Categoria>?) ?? [];
        _marcas = (results[3] as List<Marca>?) ?? [];
        _unidadesPeso = (results[4] as List<UnidadPeso>?) ?? [];
        _poblarControladores();
      }
    } catch (e) {
      if (mounted) {
        _errorMessage = 'No se pudo cargar el producto: ${e.toString().replaceAll('Exception: ', '')}';
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarModalExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4D2B).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF1E4D2B),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '¡Producto Actualizado!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los cambios han sido guardados exitosamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E4D2B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<int> _obtenerUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final dynamic val = prefs.get('id_user') ??
        prefs.get('userId') ??
        prefs.get('user_id') ??
        prefs.get('idUser') ??
        prefs.get('id');

    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 1;
    return 1;
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final int userId = await _obtenerUserId();

    final Map<String, dynamic> bodyData = {
      "nombre": _nombreCtrl.text.trim(),
      "descripcion": _descripcionCtrl.text.trim(),
      "precioUnidad": double.tryParse(_precioCtrl.text) ?? 0.0,
      "id_categoria_producto": _idCategoriaSeleccionada ?? 1,
      "id_unidad_peso": _idUnidadPesoSeleccionada ?? 1,
      "id_marca_producto": _idMarcaSeleccionada ?? 1,
      "id_user": userId,
      "peso": double.tryParse(_pesoCtrl.text) ?? 0.0,
      "cantidadMinima": double.tryParse(_cantMinCtrl.text) ?? 0,
      "cantidadMax": double.tryParse(_cantMaxCtrl.text) ?? 0,
      "cantActual": double.tryParse(_cantActualCtrl.text) ?? 0,
      "informacionSeguridadDtoReq": {
        "esToxico": _esToxico,
        "esCorrosivo": _esCorrosivo,
        "esInflamable": _esInflamable,
        "esPeligroso": _esPeligroso,
        "requiereEquipoProteccion": _requiereEPP,
        "requiereManejoEspecial": _requiereManejoEspecial,
        "descripcion": _secDescripcionCtrl.text.trim(),
        "precauciones": _secPrecaucionesCtrl.text.trim(),
        "advertencias": _secAdvertenciasCtrl.text.trim(),
        "instruccionesManejo": _secManejoCtrl.text.trim(),
        "instruccionesAlmacenamiento": _secAlmacenamientoCtrl.text.trim(),
      }
    };

    try {
      final exito = await _productoService.actualizarProducto(
        idProducto: widget.productoId,
        productoData: bodyData,
        fotoProducto: _nuevaImagen,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (exito) {
          setState(() {
            _esModoEdicion = false;
            _nuevaImagen = null;
          });
          await _cargarProducto();
          _mostrarModalExito();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar los cambios'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _nuevaImagen = File(pickedFile.path);
      });
    }
  }

  Future<void> _abrirWhatsApp(BuildContext context, String productoNombre) async {
    const telefonoWhatsApp = '573000000000'; // 👈 Reemplaza por tu número de contacto

    final mensaje = Uri.encodeComponent('¡Hola! Me interesa comprar "$productoNombre" que vi en AgroBolívar.');
    final uri = Uri.parse('https://wa.me/$telefonoWhatsApp?text=$mensaje');

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al redirigir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _esModoEdicion ? 'Editar Producto' : (_producto?.nombre ?? 'Detalle del Producto'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E4D2B),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          // 👈 Si esTienda es true, se oculta toda la lógica de edición
          if (!widget.esTienda && _producto != null && !_isLoading && !_isSaving)
            if (_esModoEdicion) ...[
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Cancelar',
                onPressed: () {
                  setState(() {
                    _esModoEdicion = false;
                    _nuevaImagen = null;
                    _poblarControladores();
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                tooltip: 'Guardar',
                onPressed: _guardarCambios,
              ),
            ] else
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'Editar Producto',
                onPressed: () {
                  setState(() {
                    _esModoEdicion = true;
                  });
                },
              ),
        ],
      ),
      body: (_isLoading || _isSaving)
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E4D2B)))
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _cargarProducto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E4D2B),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Reintentar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      )
          : Form(
        key: _formKey,
        child: RefreshIndicator(
          onRefresh: _cargarProducto,
          color: const Color(0xFF1E4D2B),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagen(_producto!.imgProducto),
                const SizedBox(height: 16),
                _buildCardInfoGeneral(_producto!),
                const SizedBox(height: 16),
                _buildCardInventario(_producto!),
                const SizedBox(height: 16),
                _buildCardSeguridad(_infoSeguridad),
              ],
            ),
          ),
        ),
      ),

      // ---------------------------------------------------------------------
      // BOTÓN DE COMPRA (SOLO VISIBLE SI ES VISTA TIENDA, NO SE EDITANDO Y HAY PRODUCTO)
      // ---------------------------------------------------------------------
      bottomNavigationBar: (widget.esTienda && !_isLoading && !_isSaving && _errorMessage == null && _producto != null && !_esModoEdicion)
          ? Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // Verde oficial WhatsApp
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _abrirWhatsApp(context, _producto!.nombre),
              icon: const Icon(Icons.chat_bubble_rounded, size: 20),
              label: const Text(
                'Comprar por WhatsApp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildImagen(String? urlImagen) {
    final bool hasImage = urlImagen != null && urlImagen.isNotEmpty;

    return Center(
      child: GestureDetector(
        onTap: _esModoEdicion ? _seleccionarImagen : null,
        child: Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _esModoEdicion ? const Color(0xFF1E4D2B) : Colors.grey.shade200,
              width: _esModoEdicion ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _nuevaImagen != null
                    ? Image.file(_nuevaImagen!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                    : hasImage
                    ? Image.network(
                  urlImagen,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.grass, size: 80, color: Color(0xFF1E4D2B)),
                  ),
                )
                    : const Center(
                  child: Icon(Icons.grass, size: 80, color: Color(0xFF1E4D2B)),
                ),
              ),
              if (_esModoEdicion)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.white, size: 36),
                        SizedBox(height: 4),
                        Text('Cambiar Imagen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardInfoGeneral(ProductoDetalle p) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_esModoEdicion) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4D2B).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      p.categoria.isNotEmpty ? p.categoria : 'General',
                      style: const TextStyle(
                        color: Color(0xFF1E4D2B),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '\$${p.precioUnidad.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                p.nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (p.marcaProducto.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Marca: ${p.marcaProducto}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
              if (p.descripcion != null && p.descripcion!.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Descripción:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 4),
                Text(
                  p.descripcion!,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4),
                ),
              ],
            ] else ...[
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del producto *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                value: _idCategoriaSeleccionada,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Categoría *'),
                hint: const Text('Seleccionar Categoría'),
                items: _categorias.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat.id,
                    child: Text(cat.nombre, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _idCategoriaSeleccionada = val);
                },
                validator: (v) => v == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                value: _idMarcaSeleccionada,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Marca *'),
                hint: const Text('Seleccionar Marca'),
                items: _marcas.map((m) {
                  return DropdownMenuItem<int>(
                    value: m.id,
                    child: Text(m.nombre, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _idMarcaSeleccionada = val);
                },
                validator: (v) => v == null ? 'Selecciona una marca' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _precioCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio por unidad *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardInventario(ProductoDetalle p) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Color(0xFF1E4D2B), size: 20),
                SizedBox(width: 8),
                Text(
                  'Inventario y Especificaciones',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const Divider(height: 20),
            if (!_esModoEdicion) ...[
              _buildFilaDato('Stock Actual', '${p.cantActual.toInt()} unidades'),
              _buildFilaDato('Cantidad Mínima', '${p.cantidadMinima.toInt()} unidades'),
              _buildFilaDato('Cantidad Máxima', '${p.cantidadMax.toInt()} unidades'),
              if (p.peso > 0 || p.unidadPeso.isNotEmpty)
                _buildFilaDato('Peso', '${p.peso} ${p.unidadPeso}'.trim()),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cantActualCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock Actual'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _cantMinCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cant. Mínima'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cantMaxCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cant. Máxima'),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pesoCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Peso'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _idUnidadPesoSeleccionada,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Unidad de Peso'),
                      hint: const Text('Unidad'),
                      items: _unidadesPeso.map((u) {
                        return DropdownMenuItem<int>(
                          value: u.id,
                          child: Text(u.nombre, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _idUnidadPesoSeleccionada = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardSeguridad(InformacionSeguridad? s) {
    final bool tieneAlertas = s != null &&
        (s.esToxico ||
            s.esCorrosivo ||
            s.esInflamable ||
            s.esPeligroso ||
            s.requiereEquipoProteccion ||
            s.requiereManejoEspecial);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (tieneAlertas ? Colors.amber.shade50 : const Color(0xFF1E4D2B).withOpacity(0.08)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: tieneAlertas ? const Color(0xFFD97706) : const Color(0xFF1E4D2B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Información de Riesgo y Seguridad',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (!_esModoEdicion) ...[
              if (s != null) ...[
                if (tieneAlertas) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (s.esToxico) _buildBadgeRiesgo('Tóxico', Icons.coronavirus_outlined, Colors.red.shade700),
                      if (s.esCorrosivo) _buildBadgeRiesgo('Corrosivo', Icons.science_outlined, Colors.purple.shade700),
                      if (s.esInflamable) _buildBadgeRiesgo('Inflamable', Icons.local_fire_department_outlined, Colors.orange.shade800),
                      if (s.esPeligroso) _buildBadgeRiesgo('Peligroso', Icons.warning_amber_rounded, Colors.amber.shade900),
                      if (s.requiereEquipoProteccion) _buildBadgeRiesgo('Requiere EPP', Icons.health_and_safety_outlined, Colors.blue.shade700),
                      if (s.requiereManejoEspecial) _buildBadgeRiesgo('Manejo Especial', Icons.pan_tool_outlined, Colors.brown.shade700),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                if (s.descripcion != null && s.descripcion!.trim().isNotEmpty) ...[
                  Text(s.descripcion!, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 12),
                ],
                if (s.advertencias != null && s.advertencias!.trim().isNotEmpty)
                  _buildCalloutBox(
                    titulo: 'Advertencias',
                    contenido: s.advertencias!,
                    icono: Icons.error_outline_rounded,
                    colorBase: Colors.red.shade700,
                    fondo: Colors.red.shade50,
                  ),
                if (s.precauciones != null && s.precauciones!.trim().isNotEmpty)
                  _buildCalloutBox(
                    titulo: 'Precauciones',
                    contenido: s.precauciones!,
                    icono: Icons.report_problem_outlined,
                    colorBase: Colors.amber.shade900,
                    fondo: Colors.amber.shade50,
                  ),
                if (s.instruccionesManejo != null && s.instruccionesManejo!.trim().isNotEmpty)
                  _buildCalloutBox(
                    titulo: 'Instrucciones de Manejo',
                    contenido: s.instruccionesManejo!,
                    icono: Icons.front_hand_outlined,
                    colorBase: Colors.blue.shade800,
                    fondo: Colors.blue.shade50,
                  ),
                if (s.instruccionesAlmacenamiento != null && s.instruccionesAlmacenamiento!.trim().isNotEmpty)
                  _buildCalloutBox(
                    titulo: 'Almacenamiento',
                    contenido: s.instruccionesAlmacenamiento!,
                    icono: Icons.inventory_2_outlined,
                    colorBase: const Color(0xFF334155),
                    fondo: const Color(0xFFF1F5F9),
                  ),
              ],
            ] else ...[
              SwitchListTile(
                title: const Text('Tóxico'),
                value: _esToxico,
                onChanged: (v) => setState(() => _esToxico = v),
              ),
              SwitchListTile(
                title: const Text('Corrosivo'),
                value: _esCorrosivo,
                onChanged: (v) => setState(() => _esCorrosivo = v),
              ),
              SwitchListTile(
                title: const Text('Inflamable'),
                value: _esInflamable,
                onChanged: (v) => setState(() => _esInflamable = v),
              ),
              SwitchListTile(
                title: const Text('Peligroso'),
                value: _esPeligroso,
                onChanged: (v) => setState(() => _esPeligroso = v),
              ),
              SwitchListTile(
                title: const Text('Requiere EPP'),
                value: _requiereEPP,
                onChanged: (v) => setState(() => _requiereEPP = v),
              ),
              SwitchListTile(
                title: const Text('Manejo Especial'),
                value: _requiereManejoEspecial,
                onChanged: (v) => setState(() => _requiereManejoEspecial = v),
              ),
              const Divider(),
              TextFormField(
                controller: _secAdvertenciasCtrl,
                decoration: const InputDecoration(labelText: 'Advertencias'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _secPrecaucionesCtrl,
                decoration: const InputDecoration(labelText: 'Precauciones'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _secAlmacenamientoCtrl,
                decoration: const InputDecoration(labelText: 'Instrucciones de Almacenamiento'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeRiesgo(String texto, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalloutBox({
    required String titulo,
    required String contenido,
    required IconData icono,
    required Color colorBase,
    required Color fondo,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorBase.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: colorBase),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: colorBase,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contenido,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaDato(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}