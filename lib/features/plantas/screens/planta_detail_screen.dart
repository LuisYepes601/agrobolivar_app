import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/planta_admin_model.dart';
import '../models/planta_detail_model.dart';
import 'package:agro_bolivar/features/tipo_planta/models/tipo_planta_model.dart';
import 'package:agro_bolivar/features/familia_planta/model/familia_planta_model.dart';
import 'package:agro_bolivar/features/genero_planta/models/genero_planta_model.dart';
import 'package:agro_bolivar/features/especie_planta/model/especie_planta_model.dart';
import 'package:agro_bolivar/features/ciclo_germinacion/models/ciclo_germinacion_model.dart';
import 'package:agro_bolivar/features/ciclo_produccion/models/ciclo_produccion_model.dart';

import '../services/planta_service.dart';
import 'package:agro_bolivar/features/tipo_planta/services/tipo_planta_service.dart';
import 'package:agro_bolivar/features/familia_planta/services/familia_planta_service.dart';
import 'package:agro_bolivar/features/genero_planta/services/genero_planta_service.dart';
import 'package:agro_bolivar/features/especie_planta/services/especie_planta_service.dart';
import 'package:agro_bolivar/features/ciclo_germinacion/services/ciclo_germinacion_service.dart';
import 'package:agro_bolivar/features/ciclo_produccion/services/ciclo_produccion_service.dart';

class PlantaDetailScreen extends StatefulWidget {
  final PlantaAdminModel planta;

  const PlantaDetailScreen({
    super.key,
    required this.planta,
  });

  @override
  State<PlantaDetailScreen> createState() => _PlantaDetailScreenState();
}

class _PlantaDetailScreenState extends State<PlantaDetailScreen> {
  final PlantaService _plantaService = PlantaService();
  final TipoPlantaService _tipoPlantaService = TipoPlantaService();
  final FamiliaPlantaService _familiaBotanicaService = FamiliaPlantaService();
  final GeneroPlantaService _generoPlantaService = GeneroPlantaService();
  final EspeciePlantaService _especiePlantaService = EspeciePlantaService();
  final CicloGerminacionService _cicloGerminacionService = CicloGerminacionService();
  final CicloProduccionService _cicloProduccionService = CicloProduccionService();

  late Future<PlantaDetailModel> _detailFuture;

  bool _isUploadingImage = false;
  File? _localSelectedImage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    setState(() {
      _detailFuture = _plantaService.fetchPlantaAdminById(widget.planta.id!);
    });
  }

  /// Estilo unificado y limpio para todos los campos de texto
  InputDecoration _buildInputDecoration({
    required String labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E4D2B), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Future<void> _pickAndUploadFoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);

      setState(() {
        _isUploadingImage = true;
      });

      final success = await _plantaService.updateFotoPlanta(
        id: widget.planta.id!,
        imageFile: imageFile,
      );

      if (success && mounted) {
        setState(() {
          _localSelectedImage = imageFile;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto actualizada correctamente'),
            backgroundColor: Color(0xFF1E4D2B),
          ),
        );

        _loadDetail();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la foto: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  /// Diálogo 1: Editar Datos Básicos
  Future<void> _showEditDatosBasicosDialog({
    required String currentNombre,
    required String currentNombreCientifico,
    required String currentDescripcion,
  }) async {
    final nombreController = TextEditingController(text: currentNombre);
    final cientificoController = TextEditingController(
      text: currentNombreCientifico == 'Sin nombre científico especificado' ? '' : currentNombreCientifico,
    );
    final descripcionController = TextEditingController(
      text: currentDescripcion == 'Esta variedad no cuenta con una descripción detallada registrada.' ? '' : currentDescripcion,
    );
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              title: const Text(
                'Editar Datos Básicos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: nombreController,
                          decoration: _buildInputDecoration(
                            labelText: 'Nombre común',
                            hintText: 'Ej: Tomate',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Ingresa el nombre común';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: cientificoController,
                          decoration: _buildInputDecoration(
                            labelText: 'Nombre científico',
                            hintText: 'Ej: Solanum lycopersicum',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: descripcionController,
                          maxLines: 3,
                          decoration: _buildInputDecoration(
                            labelText: 'Descripción',
                            hintText: 'Ej: Planta herbácea cultivada por su fruto...',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                    if (!formKey.currentState!.validate()) return;

                    setDialogState(() {
                      isSaving = true;
                    });

                    try {
                      final success = await _plantaService.updateDatosBasicosPlanta(
                        id: widget.planta.id!,
                        nombre: nombreController.text.trim(),
                        nombreCientifico: cientificoController.text.trim(),
                        descripcion: descripcionController.text.trim(),
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Datos básicos actualizados correctamente'),
                            backgroundColor: Color(0xFF1E4D2B),
                          ),
                        );
                        _loadDetail();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar los datos básicos: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setDialogState(() {
                          isSaving = false;
                        });
                      }
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    nombreController.dispose();
    cientificoController.dispose();
    descripcionController.dispose();
  }

  /// Diálogo 2: Editar Condiciones Climáticas
  Future<void> _showEditCondicionesClimaticasDialog(PlantaDetailModel detail) async {
    final tempMinCtrl = TextEditingController(text: detail.temperaturaMinima?.toString() ?? '');
    final tempMaxCtrl = TextEditingController(text: detail.temperaturaMaxima?.toString() ?? '');
    final tempIdealCtrl = TextEditingController(text: detail.temperaturaIdeal?.toString() ?? '');

    final humMinCtrl = TextEditingController(text: detail.humedadMinima?.toString() ?? '');
    final humMaxCtrl = TextEditingController(text: detail.humedadMaxima?.toString() ?? '');
    final humIdealCtrl = TextEditingController(text: detail.humedadIdeal?.toString() ?? '');

    final solMinCtrl = TextEditingController(text: detail.horasSolaresMinimas?.toString() ?? '');
    final solMaxCtrl = TextEditingController(text: detail.horasSolaresMaximas?.toString() ?? '');
    final solIdealCtrl = TextEditingController(text: detail.horasSolaresIdeales?.toString() ?? '');

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              title: const Text(
                'Condiciones Climáticas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Temperatura (°C)',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E4D2B)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: tempMinCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Mínima'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: tempMaxCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Máxima'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: tempIdealCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _buildInputDecoration(labelText: 'Ideal'),
                        ),

                        const SizedBox(height: 18),
                        const Text(
                          'Humedad (%)',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E4D2B)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: humMinCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Mínima'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: humMaxCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Máxima'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: humIdealCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _buildInputDecoration(labelText: 'Ideal'),
                        ),

                        const SizedBox(height: 18),
                        const Text(
                          'Horas Solares (h/día)',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E4D2B)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: solMinCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Mínimas'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: solMaxCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Máximas'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: solIdealCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _buildInputDecoration(labelText: 'Ideales'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                    if (!formKey.currentState!.validate()) return;

                    setDialogState(() {
                      isSaving = true;
                    });

                    try {
                      final success = await _plantaService.updateCondicionesClimaticasPlanta(
                        id: widget.planta.id!,
                        temperaturaMinima: double.tryParse(tempMinCtrl.text.trim()),
                        temperaturaMaxima: double.tryParse(tempMaxCtrl.text.trim()),
                        temperaturaIdeal: double.tryParse(tempIdealCtrl.text.trim()),
                        humedadMinima: double.tryParse(humMinCtrl.text.trim()),
                        humedadMaxima: double.tryParse(humMaxCtrl.text.trim()),
                        humedadIdeal: double.tryParse(humIdealCtrl.text.trim()),
                        horasSolaresMinimas: double.tryParse(solMinCtrl.text.trim()),
                        horasSolaresMaximas: double.tryParse(solMaxCtrl.text.trim()),
                        horasSolaresIdeales: double.tryParse(solIdealCtrl.text.trim()),
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Condiciones climáticas actualizadas correctamente'),
                            backgroundColor: Color(0xFF1E4D2B),
                          ),
                        );
                        _loadDetail();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar condiciones climáticas: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setDialogState(() {
                          isSaving = false;
                        });
                      }
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    tempMinCtrl.dispose();
    tempMaxCtrl.dispose();
    tempIdealCtrl.dispose();
    humMinCtrl.dispose();
    humMaxCtrl.dispose();
    humIdealCtrl.dispose();
    solMinCtrl.dispose();
    solMaxCtrl.dispose();
    solIdealCtrl.dispose();
  }

  /// Diálogo 3: Editar Condiciones de Terreno
  Future<void> _showEditCondicionesTerrenoDialog(PlantaDetailModel detail) async {
    final precMinCtrl = TextEditingController(text: detail.precipitacionMinima?.toString() ?? '');
    final precMaxCtrl = TextEditingController(text: detail.precipitacionMaxima?.toString() ?? '');
    final precIdealCtrl = TextEditingController(text: detail.precipitacionIdeal?.toString() ?? '');

    final altMinCtrl = TextEditingController(text: detail.altitudMinima?.toString() ?? '');
    final altMaxCtrl = TextEditingController(text: detail.altitudMaxima?.toString() ?? '');

    final phMinCtrl = TextEditingController(text: detail.phSueloMinimo?.toString() ?? '');
    final phMaxCtrl = TextEditingController(text: detail.phSueloMaximo?.toString() ?? '');
    final phIdealCtrl = TextEditingController(text: detail.phSueloIdeal?.toString() ?? '');

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              title: const Text(
                'Condiciones de Terreno',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Precipitación (mm)',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E4D2B)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: precMinCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Mínima'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: precMaxCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Máxima'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: precIdealCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _buildInputDecoration(labelText: 'Ideal'),
                        ),

                        const SizedBox(height: 18),
                        const Text(
                          'Altitud (m.s.n.m.)',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E4D2B)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: altMinCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Mínima'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: altMaxCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Máxima'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        const Text(
                          'pH del Suelo',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E4D2B)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: phMinCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Mínimo'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: phMaxCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _buildInputDecoration(labelText: 'Máximo'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: phIdealCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _buildInputDecoration(labelText: 'Ideal'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                    if (!formKey.currentState!.validate()) return;

                    setDialogState(() {
                      isSaving = true;
                    });

                    try {
                      final success = await _plantaService.updateCondicionesTerrenoPlanta(
                        id: widget.planta.id!,
                        precipitacionMinima: double.tryParse(precMinCtrl.text.trim()),
                        precipitacionMaxima: double.tryParse(precMaxCtrl.text.trim()),
                        precipitacionIdeal: double.tryParse(precIdealCtrl.text.trim()),
                        altitudMinima: double.tryParse(altMinCtrl.text.trim()),
                        altitudMaxima: double.tryParse(altMaxCtrl.text.trim()),
                        phSueloMinimo: double.tryParse(phMinCtrl.text.trim()),
                        phSueloMaximo: double.tryParse(phMaxCtrl.text.trim()),
                        phSueloIdeal: double.tryParse(phIdealCtrl.text.trim()),
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Condiciones de terreno actualizadas correctamente'),
                            backgroundColor: Color(0xFF1E4D2B),
                          ),
                        );
                        _loadDetail();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar las condiciones de terreno: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setDialogState(() {
                          isSaving = false;
                        });
                      }
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    precMinCtrl.dispose();
    precMaxCtrl.dispose();
    precIdealCtrl.dispose();
    altMinCtrl.dispose();
    altMaxCtrl.dispose();
    phMinCtrl.dispose();
    phMaxCtrl.dispose();
    phIdealCtrl.dispose();
  }

  /// Diálogo 4: Editar Frecuencia de Riego
  Future<void> _showEditRiegoDialog(String currentRiego) async {
    final controller = TextEditingController(
      text: currentRiego == 'No especificada' ? '' : currentRiego,
    );
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              title: const Text(
                'Frecuencia de Riego',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: TextFormField(
                      controller: controller,
                      decoration: _buildInputDecoration(
                        labelText: 'Frecuencia de riego',
                        hintText: 'Ej: Cada 2 días',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingresa la frecuencia de riego';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                    if (!formKey.currentState!.validate()) return;

                    setDialogState(() {
                      isSaving = true;
                    });

                    try {
                      final success = await _plantaService.updateRiegoPlanta(
                        id: widget.planta.id!,
                        frecuenciaRiego: controller.text.trim(),
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Frecuencia de riego actualizada correctamente'),
                            backgroundColor: Color(0xFF1E4D2B),
                          ),
                        );
                        _loadDetail();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar el riego: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setDialogState(() {
                          isSaving = false;
                        });
                      }
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  /// Diálogo 5: Editar Ciclos de Cultivo y Producción
  Future<void> _showEditCiclosDialog(PlantaDetailModel detail) async {
    int? selectedCicloGerminacionId = detail.idCicloGerminacion;
    int? selectedCicloProduccionId = detail.idCicloProduccion;
    final estacionCultivoCtrl = TextEditingController(text: detail.idEstacionCultivo?.toString() ?? '');

    final ciclosGerminacionFuture = _cicloGerminacionService.getCiclosGerminacion();
    final ciclosProduccionFuture = _cicloProduccionService.getCiclosProduccion();

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              title: const Text(
                'Editar Ciclos de Cultivo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),

                        // Dropdown dinámico Ciclo de Germinación
                        FutureBuilder<List<CicloGerminacionModel>>(
                          future: ciclosGerminacionFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF1E4D2B),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Error al cargar ciclos de germinación',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              );
                            }

                            final ciclosList = snapshot.data ?? [];
                            final hasValidSelection = ciclosList.any((c) => c.id == selectedCicloGerminacionId);

                            return DropdownButtonFormField<int>(
                              value: hasValidSelection ? selectedCicloGerminacionId : null,
                              isExpanded: true,
                              decoration: _buildInputDecoration(
                                labelText: 'Ciclo de Germinación',
                                hintText: 'Selecciona un ciclo',
                              ),
                              items: ciclosList.map((ciclo) {
                                return DropdownMenuItem<int>(
                                  value: ciclo.id,
                                  child: Text(
                                    ciclo.nombre.isNotEmpty ? ciclo.nombre : 'Ciclo #${ciclo.id}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setDialogState(() {
                                  selectedCicloGerminacionId = newValue;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Dropdown dinámico Ciclo de Producción
                        FutureBuilder<List<CicloProduccionModel>>(
                          future: ciclosProduccionFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF1E4D2B),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Error al cargar ciclos de producción',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              );
                            }

                            final ciclosList = snapshot.data ?? [];
                            final hasValidSelection = ciclosList.any((c) => c.id == selectedCicloProduccionId);

                            return DropdownButtonFormField<int>(
                              value: hasValidSelection ? selectedCicloProduccionId : null,
                              isExpanded: true,
                              decoration: _buildInputDecoration(
                                labelText: 'Ciclo de Producción',
                                hintText: 'Selecciona un ciclo',
                              ),
                              items: ciclosList.map((ciclo) {
                                final nombreMostrar = (ciclo.nombre != null && ciclo.nombre!.isNotEmpty)
                                    ? ciclo.nombre!
                                    : 'Ciclo #${ciclo.id}';
                                return DropdownMenuItem<int>(
                                  value: ciclo.id,
                                  child: Text(
                                    nombreMostrar,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setDialogState(() {
                                  selectedCicloProduccionId = newValue;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: estacionCultivoCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration(
                            labelText: 'ID Estación Cultivo',
                            hintText: 'Ej: 1',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                    if (!formKey.currentState!.validate()) return;

                    setDialogState(() {
                      isSaving = true;
                    });

                    try {
                      final success = await _plantaService.updateCiclosPlanta(
                        id: widget.planta.id!,
                        idCicloGerminacion: selectedCicloGerminacionId,
                        idCicloProduccion: selectedCicloProduccionId,
                        idEstacionCultivo: int.tryParse(estacionCultivoCtrl.text.trim()),
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ciclos actualizados correctamente'),
                            backgroundColor: Color(0xFF1E4D2B),
                          ),
                        );
                        _loadDetail();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar los ciclos: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setDialogState(() {
                          isSaving = false;
                        });
                      }
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    estacionCultivoCtrl.dispose();
  }

  /// Diálogo 6: Editar Taxonomía y Clasificación
  Future<void> _showEditClasificacionDialog(PlantaDetailModel detail) async {
    int? selectedTipoPlantaId = detail.idTipoPlanta ?? widget.planta.idTipo;
    int? selectedFamiliaBotanicaId = detail.idFamiliaBotanica ?? widget.planta.idFamilia;
    int? selectedGeneroPlantaId = detail.idGeneroPlanta ?? widget.planta.idGenero;
    int? selectedEspecieId = detail.idEspecie ?? widget.planta.idEspecie;

    final tiposPlantaFuture = _tipoPlantaService.fetchTiposPlanta();
    final familiasBotanicasFuture = _familiaBotanicaService.fetchFamilias();
    final generosPlantaFuture = _generoPlantaService.fetchGeneros();
    final especiesPlantaFuture = _especiePlantaService.fetchEspecies();

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              title: const Text(
                'Editar Clasificación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),

                        // Dropdown Tipo de Planta
                        FutureBuilder<List<TipoPlantaModel>>(
                          future: tiposPlantaFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF1E4D2B),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Error al cargar tipos de planta',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              );
                            }

                            final tiposList = snapshot.data ?? [];
                            final hasValidSelection = tiposList.any((t) => t.id == selectedTipoPlantaId);

                            return DropdownButtonFormField<int>(
                              value: hasValidSelection ? selectedTipoPlantaId : null,
                              isExpanded: true,
                              decoration: _buildInputDecoration(
                                labelText: 'Tipo de Planta',
                                hintText: 'Selecciona un tipo',
                              ),
                              items: tiposList.map((tipo) {
                                return DropdownMenuItem<int>(
                                  value: tipo.id,
                                  child: Text(
                                    tipo.nombre ?? 'Sin nombre',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setDialogState(() {
                                  selectedTipoPlantaId = newValue;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Dropdown Familia Botánica
                        FutureBuilder<List<FamiliaPlantaModel>>(
                          future: familiasBotanicasFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF1E4D2B),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Error al cargar familias botánicas',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              );
                            }

                            final familiasList = snapshot.data ?? [];
                            final hasValidSelection = familiasList.any((f) => f.id == selectedFamiliaBotanicaId);

                            return DropdownButtonFormField<int>(
                              value: hasValidSelection ? selectedFamiliaBotanicaId : null,
                              isExpanded: true,
                              decoration: _buildInputDecoration(
                                labelText: 'Familia Botánica',
                                hintText: 'Selecciona una familia',
                              ),
                              items: familiasList.map((familia) {
                                return DropdownMenuItem<int>(
                                  value: familia.id,
                                  child: Text(
                                    familia.nombre ?? 'Sin nombre',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setDialogState(() {
                                  selectedFamiliaBotanicaId = newValue;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Dropdown Género de Planta
                        FutureBuilder<List<GeneroPlantaModel>>(
                          future: generosPlantaFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF1E4D2B),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Error al cargar géneros de planta',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              );
                            }

                            final generosList = snapshot.data ?? [];
                            final hasValidSelection = generosList.any((g) => g.id == selectedGeneroPlantaId);

                            return DropdownButtonFormField<int>(
                              value: hasValidSelection ? selectedGeneroPlantaId : null,
                              isExpanded: true,
                              decoration: _buildInputDecoration(
                                labelText: 'Género de Planta',
                                hintText: 'Selecciona un género',
                              ),
                              items: generosList.map((genero) {
                                return DropdownMenuItem<int>(
                                  value: genero.id,
                                  child: Text(
                                    genero.nombre ?? 'Sin nombre',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setDialogState(() {
                                  selectedGeneroPlantaId = newValue;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Dropdown Especie de Planta
                        FutureBuilder<List<EspeciePlantaModel>>(
                          future: especiesPlantaFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF1E4D2B),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Error al cargar especies de planta',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                                ),
                              );
                            }

                            final especiesList = snapshot.data ?? [];
                            final hasValidSelection = especiesList.any((e) => e.id == selectedEspecieId);

                            return DropdownButtonFormField<int>(
                              value: hasValidSelection ? selectedEspecieId : null,
                              isExpanded: true,
                              decoration: _buildInputDecoration(
                                labelText: 'Especie de Planta',
                                hintText: 'Selecciona una especie',
                              ),
                              items: especiesList.map((especie) {
                                return DropdownMenuItem<int>(
                                  value: especie.id,
                                  child: Text(
                                    especie.nombre ?? 'Sin nombre',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setDialogState(() {
                                  selectedEspecieId = newValue;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                    if (!formKey.currentState!.validate()) return;

                    setDialogState(() {
                      isSaving = true;
                    });

                    try {
                      final success = await _plantaService.updateClasificacionPlanta(
                        id: widget.planta.id!,
                        idTipoPlanta: selectedTipoPlantaId,
                        idFamiliaBotanica: selectedFamiliaBotanicaId,
                        idGeneroPlanta: selectedGeneroPlantaId,
                        idEspecie: selectedEspecieId,
                      );

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Clasificación actualizada correctamente'),
                            backgroundColor: Color(0xFF1E4D2B),
                          ),
                        );
                        _loadDetail();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al actualizar la clasificación: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setDialogState(() {
                          isSaving = false;
                        });
                      }
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cambiar Foto de la Planta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF1F5F9),
                  child: Icon(Icons.photo_library_outlined, color: Color(0xFF1E4D2B)),
                ),
                title: const Text('Seleccionar de la Galería', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadFoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF1F5F9),
                  child: Icon(Icons.camera_alt_outlined, color: Color(0xFF1E4D2B)),
                ),
                title: const Text('Tomar Foto con la Cámara', style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadFoto(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _sanitize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  String _formatNum(double? val, {String unit = ''}) {
    if (val == null) return 'N/A';
    final formatted = val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
    return unit.isNotEmpty ? '$formatted $unit' : formatted;
  }

  String _formatRange(double? min, double? max, {String unit = ''}) {
    if (min == null && max == null) return 'N/A';
    final minStr = min != null ? (min % 1 == 0 ? min.toInt().toString() : min.toStringAsFixed(1)) : '?';
    final maxStr = max != null ? (max % 1 == 0 ? max.toInt().toString() : max.toStringAsFixed(1)) : '?';
    return '$minStr - $maxStr${unit.isNotEmpty ? ' $unit' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E4D2B);
    const backgroundColor = Color(0xFFF8FAFC);
    final hasImg = widget.planta.img != null && widget.planta.img!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            backgroundColor: primaryColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.35),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_localSelectedImage != null)
                    Image.file(
                      _localSelectedImage!,
                      fit: BoxFit.cover,
                    )
                  else if (hasImg)
                    Hero(
                      tag: 'planta-img-${widget.planta.id}',
                      child: Image.network(
                        widget.planta.img!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildHeaderPlaceholder(),
                      ),
                    )
                  else
                    _buildHeaderPlaceholder(),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  if (_isUploadingImage)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 12),
                            Text(
                              'Actualizando foto...',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Positioned(
                    top: 48,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.45),
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                        tooltip: 'Editar Foto',
                        onPressed: _isUploadingImage ? null : _showImageSourceModal,
                      ),
                    ),
                  ),

                  if (_sanitize(widget.planta.nombreTipo) != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          _sanitize(widget.planta.nombreTipo)!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: FutureBuilder<PlantaDetailModel>(
              future: _detailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60.0),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Error al cargar los detalles completos de la planta.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadDetail,
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }

                final detail = snapshot.data!;

                final nombreLimpio = _sanitize(detail.nombre) ?? widget.planta.nombre;
                final cientificoLimpio = _sanitize(detail.nombreCientifico) ?? _sanitize(widget.planta.nombreCientifico);
                final descripcionLimpia = _sanitize(detail.descripcion) ?? _sanitize(widget.planta.descripcion);

                final tipoLimpio = _sanitize(detail.nombreTipoPlanta) ?? _sanitize(widget.planta.nombreTipo);
                final familiaLimpia = _sanitize(detail.nombreFamiliaBotanica) ?? _sanitize(widget.planta.nombreFamilia);
                final generoLimpio = _sanitize(detail.nombreGenero) ?? _sanitize(widget.planta.nombreGenero);
                final especieLimpia = _sanitize(detail.nombreEspecie) ?? _sanitize(widget.planta.nombreEspecie);
                final riegoLimpio = _sanitize(detail.frecuenciaRiego) ?? 'No especificada';

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nombreLimpio,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cientificoLimpio ?? 'Sin nombre científico especificado',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontStyle: cientificoLimpio != null ? FontStyle.italic : FontStyle.normal,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: primaryColor),
                            tooltip: 'Editar Datos Básicos',
                            onPressed: () => _showEditDatosBasicosDialog(
                              currentNombre: nombreLimpio,
                              currentNombreCientifico: cientificoLimpio ?? '',
                              currentDescripcion: descripcionLimpia ?? '',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickStat('Temp. Ideal', _formatNum(detail.temperaturaIdeal, unit: '°C'), Icons.thermostat_outlined),
                            Container(height: 30, width: 1, color: const Color(0xFFE2E8F0)),
                            _buildQuickStat('Humedad Ideal', _formatNum(detail.humedadIdeal, unit: '%'), Icons.water_drop_outlined),
                            Container(height: 30, width: 1, color: const Color(0xFFE2E8F0)),
                            _buildQuickStat('pH Ideal', _formatNum(detail.phSueloIdeal), Icons.science_outlined),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Descripción general',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          descripcionLimpia ?? 'Esta variedad no cuenta con una descripción detallada registrada.',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.6),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Condiciones Climáticas',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: primaryColor, size: 20),
                            tooltip: 'Editar Condiciones Climáticas',
                            onPressed: () => _showEditCondicionesClimaticasDialog(detail),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildDataRow(
                              icon: Icons.thermostat_outlined,
                              title: 'Rango de Temperatura',
                              subtitle: '${_formatRange(detail.temperaturaMinima, detail.temperaturaMaxima, unit: '°C')} (Ideal: ${_formatNum(detail.temperaturaIdeal, unit: '°C')})',
                            ),
                            _buildDataRow(
                              icon: Icons.water_drop_outlined,
                              title: 'Rango de Humedad',
                              subtitle: '${_formatRange(detail.humedadMinima, detail.humedadMaxima, unit: '%')} (Ideal: ${_formatNum(detail.humedadIdeal, unit: '%')})',
                            ),
                            _buildDataRow(
                              icon: Icons.wb_sunny_outlined,
                              title: 'Horas Solares',
                              subtitle: '${_formatRange(detail.horasSolaresMinimas, detail.horasSolaresMaximas, unit: 'h/día')} (Ideal: ${_formatNum(detail.horasSolaresIdeales, unit: 'h')})',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Condiciones de Terreno',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: primaryColor, size: 20),
                            tooltip: 'Editar Condiciones de Terreno',
                            onPressed: () => _showEditCondicionesTerrenoDialog(detail),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildDataRow(
                              icon: Icons.cloud_outlined,
                              title: 'Precipitación',
                              subtitle: '${_formatRange(detail.precipitacionMinima, detail.precipitacionMaxima, unit: 'mm')} (Ideal: ${_formatNum(detail.precipitacionIdeal, unit: 'mm')})',
                            ),
                            _buildDataRow(
                              icon: Icons.terrain_outlined,
                              title: 'Altitud Recomendada',
                              subtitle: _formatRange(detail.altitudMinima, detail.altitudMaxima, unit: 'm.s.n.m.'),
                            ),
                            _buildDataRow(
                              icon: Icons.science_outlined,
                              title: 'Rango pH de Suelo',
                              subtitle: '${_formatRange(detail.phSueloMinimo, detail.phSueloMaximo)} (Ideal: ${_formatNum(detail.phSueloIdeal)})',
                            ),
                            _buildDataRow(
                              icon: Icons.invert_colors_outlined,
                              title: 'Frecuencia de Riego',
                              subtitle: riegoLimpio,
                              isLast: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined, color: primaryColor, size: 20),
                                tooltip: 'Editar Frecuencia de Riego',
                                onPressed: () => _showEditRiegoDialog(riegoLimpio),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ciclos de Cultivo y Producción',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: primaryColor, size: 20),
                            tooltip: 'Editar Ciclos',
                            onPressed: () => _showEditCiclosDialog(detail),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildDataRow(
                              icon: Icons.published_with_changes_outlined,
                              title: 'Ciclo de Germinación',
                              subtitle: _sanitize(detail.nombreCicloGerminacion) ?? 'No especificado',
                            ),
                            _buildDataRow(
                              icon: Icons.autorenew_outlined,
                              title: 'Ciclo de Producción',
                              subtitle: _sanitize(detail.nombreCicloProduccion) ?? 'No especificado',
                            ),
                            _buildDataRow(
                              icon: Icons.calendar_month_outlined,
                              title: 'Estación de Cultivo',
                              subtitle: _sanitize(detail.nombreEstacionCultivo) ?? 'No especificada',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Taxonomía y Clasificación',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: primaryColor, size: 20),
                            tooltip: 'Editar Clasificación',
                            onPressed: () => _showEditClasificacionDialog(detail),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildDataRow(
                              icon: Icons.category_outlined,
                              title: 'Tipo de Planta',
                              subtitle: tipoLimpio ?? 'No asignado',
                            ),
                            _buildDataRow(
                              icon: Icons.account_tree_outlined,
                              title: 'Familia Botánica',
                              subtitle: familiaLimpia ?? 'No asignado',
                            ),
                            _buildDataRow(
                              icon: Icons.nature_outlined,
                              title: 'Género',
                              subtitle: generoLimpio ?? 'No asignado',
                            ),
                            _buildDataRow(
                              icon: Icons.spa_outlined,
                              title: 'Especie',
                              subtitle: especieLimpia ?? 'No asignado',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPlaceholder() {
    return Container(
      color: const Color(0xFF1E4D2B).withOpacity(0.85),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          size: 80,
          color: Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    const primaryColor = Color(0xFF1E4D2B);

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLast = false,
    Widget? trailing,
  }) {
    const primaryColor = Color(0xFF1E4D2B);

    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}