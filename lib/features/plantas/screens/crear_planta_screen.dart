import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agro_bolivar/features/ciclo_germinacion/models/ciclo_germinacion_model.dart';
import 'package:agro_bolivar/features/ciclo_germinacion/services/ciclo_germinacion_service.dart';
import 'package:agro_bolivar/features/ciclo_produccion/models/ciclo_produccion_model.dart';
import 'package:agro_bolivar/features/ciclo_produccion/services/ciclo_produccion_service.dart';
import 'package:agro_bolivar/features/especie_planta/model/especie_planta_model.dart';
import 'package:agro_bolivar/features/especie_planta/services/especie_planta_service.dart';
import 'package:agro_bolivar/features/estaciones/models/estacion_model.dart';
import 'package:agro_bolivar/features/estaciones/services/estacion_service.dart';
import 'package:agro_bolivar/features/familia_planta/model/familia_planta_model.dart';
import 'package:agro_bolivar/features/familia_planta/services/familia_planta_service.dart';
import 'package:agro_bolivar/features/genero_planta/models/genero_planta_model.dart';
import 'package:agro_bolivar/features/genero_planta/services/genero_planta_service.dart';
import 'package:agro_bolivar/features/tipo_planta/models/tipo_planta_model.dart';
import 'package:agro_bolivar/features/tipo_planta/services/tipo_planta_service.dart';
import '../services/planta_service.dart';

class CrearPlantaScreen extends StatefulWidget {
  const CrearPlantaScreen({super.key});

  @override
  State<CrearPlantaScreen> createState() => _CrearPlantaScreenState();
}

class _CrearPlantaScreenState extends State<CrearPlantaScreen> {
  final _formKey = GlobalKey<FormState>();
  final PlantaService _plantaService = PlantaService();

  // Servicios
  final EspeciePlantaService _especiePlantaService = EspeciePlantaService();
  final EstacionService _estacionService = EstacionService();
  final TipoPlantaService _tipoPlantaService = TipoPlantaService();
  final FamiliaPlantaService _familiaPlantaService = FamiliaPlantaService();
  final GeneroPlantaService _generoPlantaService = GeneroPlantaService();
  final CicloProduccionService _cicloProduccionService = CicloProduccionService();
  final CicloGerminacionService _cicloGerminacionService = CicloGerminacionService();

  // Controladores de Texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nombreCientificoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  // Clima
  final TextEditingController _tempMinController = TextEditingController();
  final TextEditingController _tempMaxController = TextEditingController();
  final TextEditingController _tempIdealController = TextEditingController();
  final TextEditingController _humMinController = TextEditingController();
  final TextEditingController _humMaxController = TextEditingController();
  final TextEditingController _humIdealController = TextEditingController();
  final TextEditingController _horasSolMinController = TextEditingController();
  final TextEditingController _horasSolMaxController = TextEditingController();
  final TextEditingController _horasSolIdealController = TextEditingController();

  // Terreno y Riego
  final TextEditingController _precipMinController = TextEditingController();
  final TextEditingController _precipMaxController = TextEditingController();
  final TextEditingController _precipIdealController = TextEditingController();
  final TextEditingController _altitudMinController = TextEditingController();
  final TextEditingController _altitudMaxController = TextEditingController();
  final TextEditingController _phMinController = TextEditingController();
  final TextEditingController _phMaxController = TextEditingController();
  final TextEditingController _phIdealController = TextEditingController();
  final TextEditingController _frecuenciaRiegoController = TextEditingController();

  // IDs Seleccionados
  int? _idFamiliaBotanica;
  int? _idGeneroPlanta;
  int? _idEspecie;
  int? _idCicloProduccion;
  int? _idCicloGerminacion;
  int? _idEstacionCultivo;
  int? _idTipoPlanta;

  // Listas de datos remotos
  List<FamiliaPlantaModel> _familias = [];
  List<TipoPlantaModel> _tipos = [];
  List<EspeciePlantaModel> _especies = [];
  List<EstacionModel> _estaciones = [];
  List<GeneroPlantaModel> _generos = [];
  List<CicloProduccionModel> _ciclosProduccion = [];
  List<CicloGerminacionModel> _ciclosGerminacion = [];

  bool _isLoadingDropdowns = true;
  bool _isSaving = false;
  File? _fotoPlanta;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarDatosDropdowns();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nombreCientificoController.dispose();
    _descripcionController.dispose();
    _tempMinController.dispose();
    _tempMaxController.dispose();
    _tempIdealController.dispose();
    _humMinController.dispose();
    _humMaxController.dispose();
    _humIdealController.dispose();
    _horasSolMinController.dispose();
    _horasSolMaxController.dispose();
    _horasSolIdealController.dispose();
    _precipMinController.dispose();
    _precipMaxController.dispose();
    _precipIdealController.dispose();
    _altitudMinController.dispose();
    _altitudMaxController.dispose();
    _phMinController.dispose();
    _phMaxController.dispose();
    _phIdealController.dispose();
    _frecuenciaRiegoController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosDropdowns() async {
    try {
      final resultados = await Future.wait([
        _familiaPlantaService.fetchFamilias(),
        _tipoPlantaService.fetchTiposPlanta(),
        _especiePlantaService.fetchEspecies(),
        _estacionService.fetchEstaciones(),
        _generoPlantaService.fetchGeneros(),
        _cicloProduccionService.getCiclosProduccion(),
        _cicloGerminacionService.getCiclosGerminacion(),
      ]);

      if (mounted) {
        setState(() {
          _familias = resultados[0] as List<FamiliaPlantaModel>;
          _tipos = resultados[1] as List<TipoPlantaModel>;
          _especies = resultados[2] as List<EspeciePlantaModel>;
          _estaciones = resultados[3] as List<EstacionModel>;
          _generos = resultados[4] as List<GeneroPlantaModel>;
          _ciclosProduccion = resultados[5] as List<CicloProduccionModel>;
          _ciclosGerminacion = resultados[6] as List<CicloGerminacionModel>;
          _isLoadingDropdowns = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingDropdowns = false);
      }
    }
  }

  Future<void> _seleccionarFoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF1E4D2B)),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _obtenerImagen(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF1E4D2B)),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _obtenerImagen(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _obtenerImagen(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _fotoPlanta = File(pickedFile.path);
      });
    }
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  Future<void> _guardarPlanta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> body = {
        'idFamiliaBotanica': _idFamiliaBotanica,
        'idGeneroPlanta': _idGeneroPlanta,
        'idEspecie': _idEspecie,
        'idCicloProduccion': _idCicloProduccion,
        'idCicloGerminacion': _idCicloGerminacion,
        'idEstacionCultivo': _idEstacionCultivo,
        'idTipoPlanta': _idTipoPlanta,
        'nombre': _nombreController.text.trim(),
        'nombreCientifico': _nombreCientificoController.text.trim().isEmpty
            ? null
            : _nombreCientificoController.text.trim(),
        'descripcion': _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        'temperaturaMinima': _parseDouble(_tempMinController.text),
        'temperaturaMaxima': _parseDouble(_tempMaxController.text),
        'temperaturaIdeal': _parseDouble(_tempIdealController.text),
        'humedadMinima': _parseDouble(_humMinController.text),
        'humedadMaxima': _parseDouble(_humMaxController.text),
        'humedadIdeal': _parseDouble(_humIdealController.text),
        'horasSolaresMinimas': _parseDouble(_horasSolMinController.text),
        'horasSolaresMaximas': _parseDouble(_horasSolMaxController.text),
        'horasSolaresIdeales': _parseDouble(_horasSolIdealController.text),
        'precipitacionMinima': _parseDouble(_precipMinController.text),
        'precipitacionMaxima': _parseDouble(_precipMaxController.text),
        'precipitacionIdeal': _parseDouble(_precipIdealController.text),
        'altitudMinima': _parseDouble(_altitudMinController.text),
        'altitudMaxima': _parseDouble(_altitudMaxController.text),
        'phSueloMinimo': _parseDouble(_phMinController.text),
        'phSueloMaximo': _parseDouble(_phMaxController.text),
        'phSueloIdeal': _parseDouble(_phIdealController.text),
        'frecuenciaRiego': _frecuenciaRiegoController.text.trim().isEmpty
            ? null
            : _frecuenciaRiegoController.text.trim(),
      };

      final bool exitoso = await _plantaService.crearPlanta(
        body: body,
        fotoPlanta: _fotoPlanta,
      );

      if (mounted && exitoso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Planta registrada exitosamente'),
            backgroundColor: Color(0xFF1E4D2B),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E4D2B);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Nueva Planta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingDropdowns
          ? const Center(
        child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2.5),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Cuadro ilustrativo grande para imagen
              _buildImageCard(),

              // 1. Información General
              _buildCardSection(
                title: 'Información General',
                children: [
                  _buildInputField(
                    controller: _nombreController,
                    label: 'Nombre de la planta *',
                    validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Ingresa el nombre' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildInputField(
                    controller: _nombreCientificoController,
                    label: 'Nombre científico',
                  ),
                  const SizedBox(height: 14),
                  _buildInputField(
                    controller: _descripcionController,
                    label: 'Descripción',
                    maxLines: 3,
                  ),
                ],
              ),

              // 2. Clasificación y Taxonomía
              _buildCardSection(
                title: 'Clasificación y Taxonomía',
                children: [
                  _buildDropdown<int?>(
                    label: 'Familia Botánica',
                    value: _idFamiliaBotanica,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin especificar')),
                      ..._familias.map((f) => DropdownMenuItem(value: f.id, child: Text(f.nombre ?? ''))),
                    ],
                    onChanged: (val) => setState(() => _idFamiliaBotanica = val),
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown<int?>(
                    label: 'Género de Planta',
                    value: _idGeneroPlanta,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin especificar')),
                      ..._generos.map((g) => DropdownMenuItem(value: g.id, child: Text(g.nombre ?? ''))),
                    ],
                    onChanged: (val) => setState(() => _idGeneroPlanta = val),
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown<int?>(
                    label: 'Tipo de Planta',
                    value: _idTipoPlanta,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin especificar')),
                      ..._tipos.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nombre ?? ''))),
                    ],
                    onChanged: (val) => setState(() => _idTipoPlanta = val),
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown<int?>(
                    label: 'Especie',
                    value: _idEspecie,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin especificar')),
                      ..._especies.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre ?? ''))),
                    ],
                    onChanged: (val) => setState(() => _idEspecie = val),
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown<int?>(
                    label: 'Estación de Cultivo',
                    value: _idEstacionCultivo,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin especificar')),
                      ..._estaciones.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre ?? ''))),
                    ],
                    onChanged: (val) => setState(() => _idEstacionCultivo = val),
                  ),
                ],
              ),

              // 3. Ciclos de Desarrollo
              _buildCardSection(
                title: 'Ciclos de Desarrollo',
                children: [
                  _buildDropdown<int?>(
                    label: 'Ciclo de Producción',
                    value: _idCicloProduccion,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin especificar')),
                      ..._ciclosProduccion.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre ?? ''))),
                    ],
                    onChanged: (val) => setState(() => _idCicloProduccion = val),
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown<int?>(
                    label: 'Ciclo de Germinación',
                    value: _idCicloGerminacion,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin especificar')),
                      ..._ciclosGerminacion.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre ?? ''))),
                    ],
                    onChanged: (val) => setState(() => _idCicloGerminacion = val),
                  ),
                ],
              ),

              // 4. Condiciones Climáticas
              _buildCardSection(
                title: 'Condiciones Climáticas',
                children: [
                  _buildTripleGroup(
                    groupLabel: 'Temperatura',
                    unit: '°C',
                    cMin: _tempMinController,
                    cMax: _tempMaxController,
                    cIdeal: _tempIdealController,
                  ),
                  const SizedBox(height: 16),
                  _buildTripleGroup(
                    groupLabel: 'Humedad',
                    unit: '%',
                    cMin: _humMinController,
                    cMax: _humMaxController,
                    cIdeal: _humIdealController,
                  ),
                  const SizedBox(height: 16),
                  _buildTripleGroup(
                    groupLabel: 'Horas de Sol',
                    unit: 'hrs/día',
                    cMin: _horasSolMinController,
                    cMax: _horasSolMaxController,
                    cIdeal: _horasSolIdealController,
                  ),
                ],
              ),

              // 5. Terreno y Riego
              _buildCardSection(
                title: 'Terreno y Riego',
                children: [
                  _buildTripleGroup(
                    groupLabel: 'Precipitación',
                    unit: 'mm',
                    cMin: _precipMinController,
                    cMax: _precipMaxController,
                    cIdeal: _precipIdealController,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Altitud (m.s.n.m)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildSubInputField(label: 'Mínima', controller: _altitudMinController)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildSubInputField(label: 'Máxima', controller: _altitudMaxController)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTripleGroup(
                    groupLabel: 'pH del Suelo',
                    unit: '',
                    cMin: _phMinController,
                    cMax: _phMaxController,
                    cIdeal: _phIdealController,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _frecuenciaRiegoController,
                    label: 'Frecuencia de Riego',
                    hint: 'Ejemplo: Cada 2 días',
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _guardarPlanta,
                  child: _isSaving
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                      : const Text(
                    'Guardar Planta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Cuadro ilustrativo de imagen
  Widget _buildImageCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 155,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        image: _fotoPlanta != null
            ? DecorationImage(
          image: FileImage(_fotoPlanta!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _seleccionarFoto,
          child: _fotoPlanta == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E4D2B).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  size: 30,
                  color: Color(0xFF1E4D2B),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Subir Foto de Planta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Toca para seleccionar desde la galería o cámara',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          )
              : Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Cambiar foto',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Tarjeta contenedora blanca limpia (sin ícono de sección)
  Widget _buildCardSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // Campo de entrada estándar
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E4D2B), width: 1.5),
        ),
      ),
    );
  }

  // Selector desplegable sin icono recargado
  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E4D2B), width: 1.5),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
      dropdownColor: Colors.white,
    );
  }

  // Agrupador para valores triples (Mínima, Máxima, Ideal)
  Widget _buildTripleGroup({
    required String groupLabel,
    required String unit,
    required TextEditingController cMin,
    required TextEditingController cMax,
    required TextEditingController cIdeal,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unit.isNotEmpty ? '$groupLabel ($unit)' : groupLabel,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildSubInputField(label: 'Mínima', controller: cMin)),
            const SizedBox(width: 8),
            Expanded(child: _buildSubInputField(label: 'Máxima', controller: cMax)),
            const SizedBox(width: 8),
            Expanded(child: _buildSubInputField(label: 'Ideal', controller: cIdeal)),
          ],
        ),
      ],
    );
  }

  // Subcampo numérico para triples
  Widget _buildSubInputField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E4D2B), width: 1.5),
        ),
      ),
    );
  }
}