import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/services/auth_local_service.dart';
import '../models/cultivo_request_dto.dart';
import '../services/cultivo_api_service.dart';

// Importaciones de módulos
import 'package:agro_bolivar/features/unidades_peso/services/unidad_peso_service.dart';
import 'package:agro_bolivar/features/unidades_peso/models/unidad_peso_model.dart';
import 'package:agro_bolivar/features/estado_cultivo/services/estado_cultivo_service.dart';
import 'package:agro_bolivar/features/estado_cultivo/models/estado_cultivo_model.dart';
import 'package:agro_bolivar/features/unidades_area/services/unidad_area_service.dart';
import 'package:agro_bolivar/features/unidades_area/models/unidad_area_model.dart';
import 'package:agro_bolivar/features/plantas/services/planta_service.dart';
import 'package:agro_bolivar/features/plantas/models/planta_model.dart';

class AdminCultivoCreateScreen extends StatefulWidget {
  const AdminCultivoCreateScreen({super.key});

  @override
  State<AdminCultivoCreateScreen> createState() => _AdminCultivoCreateScreenState();
}

class _AdminCultivoCreateScreenState extends State<AdminCultivoCreateScreen> {
  static const primaryGreen = Color(0xFF1E4D2B);
  static const backgroundColor = Color(0xFFF1F5F9);

  final _formKey = GlobalKey<FormState>();
  final CultivoApiService _cultivoService = CultivoApiService();
  final AuthLocalService _authLocalService = AuthLocalService();
  final UnidadPesoService _unidadPesoService = UnidadPesoService();
  final EstadoCultivoService _estadoCultivoService = EstadoCultivoService();
  final UnidadAreaService _unidadAreaService = UnidadAreaService();
  final PlantaService _plantaService = PlantaService();
  final ImagePicker _picker = ImagePicker();

  // Controladores de texto
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();
  final TextEditingController _cantidadSembradaController = TextEditingController();
  final TextEditingController _areaSembradaController = TextEditingController();
  final TextEditingController _cantidadDisponibleController = TextEditingController();
  final TextEditingController _precioPorKgController = TextEditingController();
  final TextEditingController _cantDispVentaController = TextEditingController();

  // Variables para Unidad de Peso
  List<UnidadPeso> _unidadesPeso = [];
  bool _isLoadingUnidadesPeso = true;
  int? _selectedUnidadPesoId;

  // Variables para Estado del Cultivo
  List<EstadoCultivo> _estadosCultivo = [];
  bool _isLoadingEstados = true;
  int? _selectedEstadoCultivoId;

  // Variables para Unidad de Área
  List<UnidadArea> _unidadesArea = [];
  bool _isLoadingUnidadesArea = true;
  int? _selectedUnidadAreaId;

  // Variables para Planta
  List<PlantaModel> _plantas = [];
  bool _isLoadingPlantas = true;
  int? _selectedPlantaId;

  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUnidadesPeso();
    _loadEstadosCultivo();
    _loadUnidadesArea();
    _loadPlantas();
  }

  Future<void> _loadUnidadesPeso() async {
    try {
      final lista = await _unidadPesoService.fetchUnidadesPesoList();
      if (mounted) {
        setState(() {
          _unidadesPeso = lista;
          _isLoadingUnidadesPeso = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar unidades de peso: $e');
      if (mounted) setState(() => _isLoadingUnidadesPeso = false);
    }
  }

  Future<void> _loadEstadosCultivo() async {
    try {
      final lista = await _estadoCultivoService.fetchEstadoCultivosList();
      if (mounted) {
        setState(() {
          _estadosCultivo = lista;
          _isLoadingEstados = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar estados de cultivo: $e');
      if (mounted) setState(() => _isLoadingEstados = false);
    }
  }

  Future<void> _loadUnidadesArea() async {
    try {
      final lista = await _unidadAreaService.fetchUnidadesAreaList();
      if (mounted) {
        setState(() {
          _unidadesArea = lista;
          _isLoadingUnidadesArea = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar unidades de área: $e');
      if (mounted) setState(() => _isLoadingUnidadesArea = false);
    }
  }

  Future<void> _loadPlantas() async {
    try {
      final lista = await _plantaService.fetchPlantasList();
      if (mounted) {
        setState(() {
          _plantas = lista;
          _isLoadingPlantas = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar plantas: $e');
      if (mounted) setState(() => _isLoadingPlantas = false);
    }
  }

  @override
  void dispose() {
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _cantidadSembradaController.dispose();
    _areaSembradaController.dispose();
    _cantidadDisponibleController.dispose();
    _precioPorKgController.dispose();
    _cantDispVentaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryGreen),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPlantaId == null) {
      _showErrorSnackBar('Por favor, selecciona una planta');
      return;
    }
    if (_selectedEstadoCultivoId == null) {
      _showErrorSnackBar('Por favor, selecciona un estado de cultivo');
      return;
    }
    if (_selectedUnidadPesoId == null) {
      _showErrorSnackBar('Por favor, selecciona una unidad de peso');
      return;
    }
    if (_selectedUnidadAreaId == null) {
      _showErrorSnackBar('Por favor, selecciona una unidad de área');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userIdString = await _authLocalService.getUserId();
      final int userId = userIdString != null ? (int.tryParse(userIdString) ?? 0) : 0;

      final dto = CultivoRequestDto(
        fechaInicio: _fechaInicioController.text.trim(),
        idPlanta: _selectedPlantaId ?? 0,
        idUser: userId,
        fechaEstimadaFin: _fechaFinController.text.trim(),
        cantidadSembrada: double.tryParse(_cantidadSembradaController.text.trim()) ?? 0.0,
        idUnidadPeso: _selectedUnidadPesoId ?? 0,
        areaSembrada: double.tryParse(_areaSembradaController.text.trim()) ?? 0.0,
        idUnidadArea: _selectedUnidadAreaId ?? 0,
        idEstadoCultivo: _selectedEstadoCultivoId ?? 0,
        cantidadDisponible: double.tryParse(_cantidadDisponibleController.text.trim()) ?? 0.0,
        precioPorKg: double.tryParse(_precioPorKgController.text.trim()) ?? 0.0,
        cantidadDisponibleParaVenta: double.tryParse(_cantDispVentaController.text.trim()) ?? 0.0,
      );

      await _cultivoService.createCultivo(
        cultivoDto: dto,
        fotoCultivo: _selectedImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cultivo registrado exitosamente'), backgroundColor: primaryGreen),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Crear Nuevo Cultivo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // CARD 1: Foto
              _buildCardSection(
                children: [
                  _buildSectionHeader('Foto del Cultivo', Icons.camera_alt_outlined),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_a_photo_outlined, size: 28, color: primaryGreen),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Seleccionar Foto del Cultivo',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // CARD 2: Información General (Planta, Estado y Fechas)
              _buildCardSection(
                children: [
                  _buildSectionHeader('Información General', Icons.eco_outlined),
                  const SizedBox(height: 12),
                  _buildPlantaDropdown(),
                  const SizedBox(height: 12),
                  _buildEstadoCultivoDropdown(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDateField('Fecha Inicio', _fechaInicioController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDateField('Fecha Est. Fin', _fechaFinController)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // CARD 3: Métricas de Siembra y Área
              _buildCardSection(
                children: [
                  _buildSectionHeader('Siembra y Terreno', Icons.square_foot_outlined),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTextField('Cant. Sembrada', _cantidadSembradaController, isDouble: true, icon: Icons.grass),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _buildUnidadPesoDropdown(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTextField('Área Sembrada', _areaSembradaController, isDouble: true, icon: Icons.aspect_ratio),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _buildUnidadAreaDropdown(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // CARD 4: Disponibilidad y Precio
              _buildCardSection(
                children: [
                  _buildSectionHeader('Disponibilidad y Precio', Icons.inventory_2_outlined),
                  const SizedBox(height: 12),
                  _buildTextField('Cantidad Disponible Total', _cantidadDisponibleController, isDouble: true, icon: Icons.inventory),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('Disp. Venta', _cantDispVentaController, isDouble: true, icon: Icons.storefront),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('Precio / Kg', _precioPorKgController, isDouble: true, icon: Icons.attach_money),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botón Guardar
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : const Text(
                  'Guardar Cultivo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers de Diseño para Secciones ---

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
      ],
    );
  }

  Widget _buildCardSection({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // --- Dropdowns ---

  Widget _buildPlantaDropdown() {
    return _buildDropdownContainer(
      isLoading: _isLoadingPlantas,
      child: DropdownButtonFormField<int>(
        value: _selectedPlantaId,
        isExpanded: true,
        decoration: _getInputDecoration('Planta', icon: Icons.eco),
        items: _plantas.map((planta) {
          return DropdownMenuItem<int>(
            value: planta.id,
            child: Text(planta.nombre, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedPlantaId = val),
        validator: (v) => v == null ? 'Requerido' : null,
      ),
    );
  }

  Widget _buildEstadoCultivoDropdown() {
    return _buildDropdownContainer(
      isLoading: _isLoadingEstados,
      child: DropdownButtonFormField<int>(
        value: _selectedEstadoCultivoId,
        isExpanded: true,
        decoration: _getInputDecoration('Estado Cultivo', icon: Icons.flag),
        items: _estadosCultivo.map((estado) {
          return DropdownMenuItem<int>(
            value: estado.id,
            child: Text(estado.nombre, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedEstadoCultivoId = val),
        validator: (v) => v == null ? 'Requerido' : null,
      ),
    );
  }

  Widget _buildUnidadPesoDropdown() {
    return _buildDropdownContainer(
      isLoading: _isLoadingUnidadesPeso,
      child: DropdownButtonFormField<int>(
        value: _selectedUnidadPesoId,
        isExpanded: true,
        decoration: _getInputDecoration('Unidad'),
        items: _unidadesPeso.map((u) {
          return DropdownMenuItem<int>(
            value: u.id,
            child: Text(u.nombre, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedUnidadPesoId = val),
        validator: (v) => v == null ? 'Requerido' : null,
      ),
    );
  }

  Widget _buildUnidadAreaDropdown() {
    return _buildDropdownContainer(
      isLoading: _isLoadingUnidadesArea,
      child: DropdownButtonFormField<int>(
        value: _selectedUnidadAreaId,
        isExpanded: true,
        decoration: _getInputDecoration('Unidad'),
        items: _unidadesArea.map((a) {
          return DropdownMenuItem<int>(
            value: a.id,
            child: Text(a.nombre, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedUnidadAreaId = val),
        validator: (v) => v == null ? 'Requerido' : null,
      ),
    );
  }

  Widget _buildDropdownContainer({required bool isLoading, required Widget child}) {
    if (isLoading) {
      return Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: primaryGreen),
          ),
        ),
      );
    }
    return child;
  }

  // --- Campos de Texto y Fechas ---

  Widget _buildTextField(String label, TextEditingController controller, {bool isDouble = false, IconData? icon}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
      decoration: _getInputDecoration(label, icon: icon),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        if (double.tryParse(v) == null) return 'Inválido';
        return null;
      },
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(controller),
      decoration: _getInputDecoration(label, icon: Icons.calendar_today_outlined),
      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
    );
  }

  InputDecoration _getInputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
      prefixIcon: icon != null ? Icon(icon, size: 18, color: primaryGreen) : null,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen, width: 1.5)),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: primaryGreen),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: primaryGreen),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}