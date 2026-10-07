import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agro_bolivar/features/categorias/models/categoria_model.dart';
import 'package:agro_bolivar/features/categorias/services/categoria_service.dart';
import 'package:agro_bolivar/features/marcas/models/marca_model.dart';
import 'package:agro_bolivar/features/marcas/services/marca_service.dart';
import 'package:agro_bolivar/features/unidades_peso/models/unidad_peso_model.dart';
import 'package:agro_bolivar/features/unidades_peso/services/unidad_peso_service.dart';
import '../services/producto_service.dart';

class CrearProductoScreen extends StatefulWidget {
  const CrearProductoScreen({super.key});

  @override
  State<CrearProductoScreen> createState() => _CrearProductoScreenState();
}

class _CrearProductoScreenState extends State<CrearProductoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _productoService = ProductoService();
  final _categoriaService = CategoriaService();
  final _marcaService = MarcaService();
  final _unidadPesoService = UnidadPesoService();

  List<Categoria> _categorias = [];
  List<Marca> _marcas = [];
  List<UnidadPeso> _unidadesPeso = [];

  int? _idCategoriaSeleccionada;
  int? _idMarcaSeleccionada;
  int? _idUnidadPesoSeleccionada;

  bool _isLoading = true;
  bool _isSaving = false;

  // Controladores
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _precioCtrl = TextEditingController();
  final TextEditingController _pesoCtrl = TextEditingController();
  final TextEditingController _cantActualCtrl = TextEditingController();
  final TextEditingController _cantMinCtrl = TextEditingController();
  final TextEditingController _cantMaxCtrl = TextEditingController();

  // Switches Seguridad
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

  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarCombos();
  }

  Future<void> _cargarCombos() async {
    try {
      final results = await Future.wait([
        _categoriaService.fetchCategorias().catchError((_) => <Categoria>[]),
        _marcaService.fetchMarcas().catchError((_) => <Marca>[]),
        _unidadPesoService.fetchUnidadesPesoList().catchError((_) => <UnidadPeso>[]),
      ]);

      if (mounted) {
        setState(() {
          _categorias = results[0] as List<Categoria>;
          _marcas = results[1] as List<Marca>;
          _unidadesPeso = results[2] as List<UnidadPeso>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
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

  Future<void> _seleccionarImagen() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imagenSeleccionada = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al acceder a la galería')),
      );
    }
  }

  Future<void> _guardarProducto() async {
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
      "cantidadMinima": int.tryParse(_cantMinCtrl.text) ?? 0,
      "cantidadMax": int.tryParse(_cantMaxCtrl.text) ?? 0,
      "cantActual": int.tryParse(_cantActualCtrl.text) ?? 0,
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

    final exito = await _productoService.crearProducto(
      productoData: bodyData,
      fotoProducto: _imagenSeleccionada,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (exito) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear el producto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Crear Producto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E4D2B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading || _isSaving
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E4D2B)))
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSelectorImagen(),
              const SizedBox(height: 16),
              _buildCamposGenerales(),
              const SizedBox(height: 16),
              _buildCamposInventario(),
              const SizedBox(height: 16),
              _buildCamposSeguridad(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _guardarProducto,
                  child: const Text('Guardar Producto', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorImagen() {
    return GestureDetector(
      onTap: _seleccionarImagen,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _imagenSeleccionada != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(_imagenSeleccionada!, fit: BoxFit.cover),
        )
            : const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 40, color: Color(0xFF1E4D2B)),
            SizedBox(height: 8),
            Text('Añadir Imagen del Producto', style: TextStyle(color: Color(0xFF1E4D2B), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildCamposGenerales() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _idCategoriaSeleccionada,
              decoration: const InputDecoration(labelText: 'Categoría *'),
              items: _categorias.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
              onChanged: (v) => setState(() => _idCategoriaSeleccionada = v),
              validator: (v) => v == null ? 'Seleccione una categoría' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _idMarcaSeleccionada,
              decoration: const InputDecoration(labelText: 'Marca *'),
              items: _marcas.map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre))).toList(),
              onChanged: (v) => setState(() => _idMarcaSeleccionada = v),
              validator: (v) => v == null ? 'Seleccione una marca' : null,
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
        ),
      ),
    );
  }

  Widget _buildCamposInventario() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextFormField(controller: _cantActualCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock Actual'))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _cantMinCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cant. Mínima'))),
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
        ),
      ),
    );
  }

  Widget _buildCamposSeguridad() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información de Seguridad', style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(title: const Text('Tóxico'), value: _esToxico, onChanged: (v) => setState(() => _esToxico = v)),
            SwitchListTile(title: const Text('Corrosivo'), value: _esCorrosivo, onChanged: (v) => setState(() => _esCorrosivo = v)),
            SwitchListTile(title: const Text('Inflamable'), value: _esInflamable, onChanged: (v) => setState(() => _esInflamable = v)),
            SwitchListTile(title: const Text('Peligroso'), value: _esPeligroso, onChanged: (v) => setState(() => _esPeligroso = v)),
            SwitchListTile(title: const Text('Requiere EPP'), value: _requiereEPP, onChanged: (v) => setState(() => _requiereEPP = v)),
            SwitchListTile(title: const Text('Manejo Especial'), value: _requiereManejoEspecial, onChanged: (v) => setState(() => _requiereManejoEspecial = v)),
            TextFormField(controller: _secPrecaucionesCtrl, decoration: const InputDecoration(labelText: 'Precauciones')),
            const SizedBox(height: 8),
            TextFormField(controller: _secAdvertenciasCtrl, decoration: const InputDecoration(labelText: 'Advertencias')),
          ],
        ),
      ),
    );
  }
}