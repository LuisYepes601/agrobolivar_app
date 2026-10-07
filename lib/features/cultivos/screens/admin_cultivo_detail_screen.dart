import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:agro_bolivar/features/cultivos/models/cultivo_admin_model.dart';
import 'package:agro_bolivar/features/cultivos/models/cultivo_admin_detail_model.dart';
import 'package:agro_bolivar/features/cultivos/models/cultivo_update_dto.dart';
import 'package:agro_bolivar/features/cultivos/services/cultivo_api_service.dart';
import 'package:agro_bolivar/features/plantas/models/planta_model.dart';
import 'package:agro_bolivar/features/plantas/services/planta_service.dart';
import 'package:agro_bolivar/features/estado_cultivo/models/estado_cultivo_model.dart';
import 'package:agro_bolivar/features/estado_cultivo/services/estado_cultivo_service.dart';
import 'package:agro_bolivar/features/unidades_peso/models/unidad_peso_model.dart';
import 'package:agro_bolivar/features/unidades_peso/services/unidad_peso_service.dart';
import 'package:agro_bolivar/features/unidades_area/models/unidad_area_model.dart';
import 'package:agro_bolivar/features/unidades_area/services/unidad_area_service.dart';

class AdminCultivoDetailScreen extends StatefulWidget {
  final CultivoAdminModel? cultivo;
  final int? cultivoId;
  final bool esEditable;

  const AdminCultivoDetailScreen({
    super.key,
    this.cultivo,
    this.cultivoId,
    this.esEditable = true,
  }) : assert(cultivo != null || cultivoId != null, 'Debes proporcionar un cultivo o un cultivoId');

  @override
  State<AdminCultivoDetailScreen> createState() => _AdminCultivoDetailScreenState();
}

class _AdminCultivoDetailScreenState extends State<AdminCultivoDetailScreen> {
  static const primaryColor = Color(0xFF166534);
  static const backgroundColor = Color(0xFFF8FAFC);
  static const cardColor = Colors.white;
  static const textColorDark = Color(0xFF0F172A);
  static const textColorMuted = Color(0xFF64748B);
  static const borderColor = Color(0xFFE2E8F0);
  static const dividerColor = Color(0xFFF1F5F9);

  final CultivoApiService _apiService = CultivoApiService();
  final PlantaService _plantaService = PlantaService();
  final EstadoCultivoService _estadoCultivoService = EstadoCultivoService();
  final UnidadPesoService _unidadPesoService = UnidadPesoService();
  final UnidadAreaService _unidadAreaService = UnidadAreaService();
  final ImagePicker _picker = ImagePicker();

  late Future<CultivoAdminDetailModel> _futureDetail;
  late Future<List<PlantaModel>> _futurePlantas;
  late Future<List<EstadoCultivo>> _futureEstados;
  late Future<List<UnidadPeso>> _futureUnidadesPeso;
  late Future<List<UnidadArea>> _futureUnidadesArea;

  bool _isUploadingPhoto = false;
  bool _isSavingData = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final id = widget.cultivoId ?? widget.cultivo!.id;
    _futureDetail = _apiService.getCultivoAdminById(id);
    _futurePlantas = _plantaService.fetchPlantasList();
    _futureEstados = _estadoCultivoService.fetchEstadoCultivosList();
    _futureUnidadesPeso = _unidadPesoService.fetchUnidadesPesoList();
    _futureUnidadesArea = _unidadAreaService.fetchUnidadesAreaList();
  }

  void _reload() {
    setState(() {
      _loadData();
    });
  }

  String _formatNum(double? val) {
    if (val == null) return '0';
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }

  Future<void> _abrirWhatsApp(String telefono, String nombreCultivo) async {
    String cleanPhone = telefono.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length == 10) {
      cleanPhone = '57$cleanPhone';
    }

    final mensaje = Uri.encodeComponent('Hola, estoy interesado en tu cultivo de $nombreCultivo publicado en AgroBolívar.');
    final Uri waUri = Uri.parse('https://api.whatsapp.com/send?phone=$cleanPhone&text=$mensaje');

    try {
      if (await canLaunchUrl(waUri)) {
        await launchUrl(waUri, mode: LaunchMode.externalApplication);
      } else {
        final Uri appUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$mensaje');
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir WhatsApp para el número: $telefono'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  int _resolverIdPlanta(String? nombre, List<PlantaModel> plantas) {
    if (plantas.isEmpty) return 1;
    if (nombre == null || nombre.trim().isEmpty) return plantas.first.id;

    final nombreLower = nombre.toLowerCase();
    final match = plantas.firstWhere(
          (p) => (p.nombre ?? '').toLowerCase().contains(nombreLower) ||
          nombreLower.contains((p.nombre ?? '').toLowerCase()),
      orElse: () => plantas.first,
    );
    return match.id;
  }

  int _resolverIdEstado(String? nombreEstado, List<EstadoCultivo> estados) {
    if (estados.isEmpty) return 1;
    if (nombreEstado == null || nombreEstado.trim().isEmpty) return estados.first.id;

    final estadoLower = nombreEstado.toLowerCase();
    final match = estados.firstWhere(
          (e) => e.nombre.toLowerCase().contains(estadoLower) ||
          estadoLower.contains(e.nombre.toLowerCase()),
      orElse: () => estados.first,
    );
    return match.id;
  }

  int _resolverIdUnidadPeso(String? nombreUnidad, List<UnidadPeso> unidades) {
    if (unidades.isEmpty) return 1;
    if (nombreUnidad == null || nombreUnidad.trim().isEmpty) return unidades.first.id;

    final unidadLower = nombreUnidad.toLowerCase();
    final match = unidades.firstWhere(
          (u) => u.nombre.toLowerCase().contains(unidadLower) ||
          unidadLower.contains(u.nombre.toLowerCase()),
      orElse: () => unidades.first,
    );
    return match.id;
  }

  int _resolverIdUnidadArea(String? nombreUnidad, List<UnidadArea> unidades) {
    if (unidades.isEmpty) return 1;
    if (nombreUnidad == null || nombreUnidad.trim().isEmpty) return unidades.first.id;

    final unidadLower = nombreUnidad.toLowerCase();
    final match = unidades.firstWhere(
          (u) => u.nombre.toLowerCase().contains(unidadLower) ||
          unidadLower.contains(u.nombre.toLowerCase()),
      orElse: () => unidades.first,
    );
    return match.id;
  }

  Future<void> _seleccionarYSubirFoto(int cultivoId, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      final File imagenFile = File(pickedFile.path);
      await _apiService.actualizarFotoCultivo(cultivoId, imagenFile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto del cultivo actualizada correctamente'),
          backgroundColor: primaryColor,
        ),
      );

      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir la imagen: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  void _mostrarOpcionesFoto(int cultivoId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Cambiar foto del cultivo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColorDark,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: textColorDark),
                  title: const Text('Galería de fotos', style: TextStyle(color: textColorDark)),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarYSubirFoto(cultivoId, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: textColorDark),
                  title: const Text('Tomar foto', style: TextStyle(color: textColorDark)),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarYSubirFoto(cultivoId, ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarModalEdicion(CultivoAdminDetailModel detail) {
    final formKey = GlobalKey<FormState>();

    final fechaInicioController = TextEditingController(text: detail.fechaInicio ?? '');
    final fechaFinController = TextEditingController(text: detail.fechaEstimadaFin ?? '');
    final precioController = TextEditingController(text: detail.precioPorKg.toString());
    final cantVentaController = TextEditingController(
      text: detail.cantidadDisponibleParaVenta.toString(),
    );
    final cantDisponibleController = TextEditingController(
      text: detail.cantidadDisponible.toString(),
    );
    final cantSembradaController = TextEditingController(
      text: detail.cantidadSembrada.toString(),
    );
    final areaSembradaController = TextEditingController(
      text: detail.areaSembradaValor.toString(),
    );

    int? idPlantaSeleccionada;
    int? idEstadoSeleccionado;
    int? idUnidadPesoSeleccionada;
    int? idUnidadAreaSeleccionada;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> seleccionarFecha(
                TextEditingController controller,
                String initialDateStr,
                ) async {
              DateTime initialDate = DateTime.tryParse(initialDateStr) ?? DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                final formattedDate =
                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                setModalState(() {
                  controller.text = formattedDate;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Editar Cultivo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColorDark,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: textColorMuted),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: FutureBuilder<List<PlantaModel>>(
                              future: _futurePlantas,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 48,
                                    child: Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                                      ),
                                    ),
                                  );
                                }

                                final plantas = snapshot.data ?? [];
                                if (plantas.isEmpty) {
                                  return const Text('Sin plantas disponibles', style: TextStyle(color: Colors.red));
                                }

                                idPlantaSeleccionada ??= _resolverIdPlanta(detail.nombreCultivo, plantas);

                                return DropdownButtonFormField<int>(
                                  value: idPlantaSeleccionada,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Planta',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  items: plantas.map((planta) {
                                    return DropdownMenuItem<int>(
                                      value: planta.id,
                                      child: Text(
                                        planta.nombre ?? 'Planta ${planta.id}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setModalState(() => idPlantaSeleccionada = val);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FutureBuilder<List<EstadoCultivo>>(
                              future: _futureEstados,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 48,
                                    child: Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                                      ),
                                    ),
                                  );
                                }

                                final estados = snapshot.data ?? [];
                                if (estados.isEmpty) {
                                  return const Text('Sin estados disponibles', style: TextStyle(color: Colors.red));
                                }

                                idEstadoSeleccionado ??= _resolverIdEstado(detail.estadoCultivo, estados);

                                return DropdownButtonFormField<int>(
                                  value: idEstadoSeleccionado,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Estado',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  items: estados.map((estado) {
                                    return DropdownMenuItem<int>(
                                      value: estado.id,
                                      child: Text(
                                        estado.nombre,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setModalState(() => idEstadoSeleccionado = val);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: precioController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Precio / Kg',
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: cantVentaController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Disp. Venta',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: cantSembradaController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Cant. Sembrada',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FutureBuilder<List<UnidadPeso>>(
                              future: _futureUnidadesPeso,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 48,
                                    child: Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                                      ),
                                    ),
                                  );
                                }

                                final unidades = snapshot.data ?? [];
                                if (unidades.isEmpty) {
                                  return const Text('Sin unidades', style: TextStyle(color: Colors.red));
                                }

                                idUnidadPesoSeleccionada ??= _resolverIdUnidadPeso(detail.unidadPeso, unidades);

                                return DropdownButtonFormField<int>(
                                  value: idUnidadPesoSeleccionada,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Unid. Peso',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  items: unidades.map((unidad) {
                                    return DropdownMenuItem<int>(
                                      value: unidad.id,
                                      child: Text(
                                        unidad.nombre,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setModalState(() => idUnidadPesoSeleccionada = val);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: areaSembradaController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Área Sembrada',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FutureBuilder<List<UnidadArea>>(
                              future: _futureUnidadesArea,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 48,
                                    child: Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                                      ),
                                    ),
                                  );
                                }

                                final unidadesArea = snapshot.data ?? [];
                                if (unidadesArea.isEmpty) {
                                  return const Text('Sin unidades', style: TextStyle(color: Colors.red));
                                }

                                idUnidadAreaSeleccionada ??= _resolverIdUnidadArea(detail.areaSembradaUnidad, unidadesArea);

                                return DropdownButtonFormField<int>(
                                  value: idUnidadAreaSeleccionada,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Unid. Área',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  items: unidadesArea.map((unidad) {
                                    return DropdownMenuItem<int>(
                                      value: unidad.id,
                                      child: Text(
                                        unidad.nombre,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setModalState(() => idUnidadAreaSeleccionada = val);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cantDisponibleController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Cantidad Total Disponible',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: fechaInicioController,
                              readOnly: true,
                              onTap: () => seleccionarFecha(
                                fechaInicioController,
                                fechaInicioController.text,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Fecha Inicio',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                suffixIcon: Icon(Icons.calendar_today, size: 16),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: fechaFinController,
                              readOnly: true,
                              onTap: () => seleccionarFecha(
                                fechaFinController,
                                fechaFinController.text,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Fecha Est. Fin',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                suffixIcon: Icon(Icons.calendar_today, size: 16),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isSavingData
                              ? null
                              : () async {
                            if (!formKey.currentState!.validate()) return;

                            setModalState(() => _isSavingData = true);

                            try {
                              final dto = CultivoUpdateDto(
                                fechaInicio: fechaInicioController.text.trim(),
                                idPlanta: idPlantaSeleccionada ?? 1,
                                idUser: detail.idUser,
                                fechaEstimadaFin: fechaFinController.text.trim(),
                                cantidadSembrada: double.tryParse(cantSembradaController.text),
                                idUnidadPeso: idUnidadPesoSeleccionada ?? 1,
                                areaSembrada: double.tryParse(areaSembradaController.text),
                                idUnidadArea: idUnidadAreaSeleccionada ?? 1,
                                idEstadoCultivo: idEstadoSeleccionado ?? 1,
                                cantidadDisponible: double.tryParse(cantDisponibleController.text),
                                precioPorKg: double.tryParse(precioController.text),
                                cantidadDisponibleParaVenta: double.tryParse(cantVentaController.text),
                              );

                              final idCultivo = widget.cultivoId ?? detail.id;
                              await _apiService.updateCultivo(idCultivo, dto);

                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cultivo actualizado'),
                                  backgroundColor: primaryColor,
                                ),
                              );
                              _reload();
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            } finally {
                              setModalState(() => _isSavingData = false);
                            }
                          },
                          child: _isSavingData
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Guardar cambios',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColorDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalle del Cultivo',
          style: TextStyle(
            color: textColorDark,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          if (widget.esEditable)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: textColorDark, size: 22),
              tooltip: 'Editar',
              onPressed: () async {
                final detail = await _futureDetail;
                if (context.mounted) _mostrarModalEdicion(detail);
              },
            ),
        ],
      ),
      body: FutureBuilder<CultivoAdminDetailModel>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No se encontraron datos.',
                style: TextStyle(color: textColorMuted),
              ),
            );
          }

          final detail = snapshot.data!;
          return _buildMainContent(detail);
        },
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: textColorMuted),
            const SizedBox(height: 12),
            Text(
              'Error al cargar el detalle:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: textColorMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _reload,
              child: const Text('Reintentar', style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(CultivoAdminDetailModel detail) {
    final idCultivo = widget.cultivoId ?? detail.id;
    final hasFoto = detail.urlImgCultivo != null && detail.urlImgCultivo!.isNotEmpty;
    final hasTelefono = detail.telefono != null && detail.telefono!.isNotEmpty;
    final hasEmail = detail.email != null && detail.email!.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasFoto)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            detail.urlImgCultivo!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                        if (widget.esEditable)
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: InkWell(
                              onTap: () => _mostrarOpcionesFoto(idCultivo),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Título y Estado
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        detail.nombreCultivo.isNotEmpty ? detail.nombreCultivo : 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColorDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (detail.estadoCultivo.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          detail.estadoCultivo.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColorMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tarjeta Principal de Precio y Disponible
                _buildPriceCard(detail),
                const SizedBox(height: 24),

                // Sección Información de Cosecha
                const Text(
                  'Información de Cosecha',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColorDark,
                  ),
                ),
                const SizedBox(height: 12),
                _buildHarvestCard(detail),
                const SizedBox(height: 24),

                // Sección Vendedor
                const Text(
                  'Vendedor',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColorDark,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSellerCard(detail, hasTelefono, hasEmail),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Botón Inferior
        _buildBottomBar(detail, hasTelefono),
      ],
    );
  }

  /// Tarjeta Minimalista de Precio y Disponible
  Widget _buildPriceCard(CultivoAdminDetailModel detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Precio unitario',
                  style: TextStyle(fontSize: 12, color: textColorMuted),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '\$${_formatNum(detail.precioPorKg)} ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColorDark,
                        ),
                      ),
                      TextSpan(
                        text: '/ ${detail.unidadPeso}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: textColorMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 36,
            width: 1,
            color: dividerColor,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Disponible para venta',
                    style: TextStyle(fontSize: 12, color: textColorMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatNum(detail.cantidadDisponibleParaVenta)} ${detail.unidadPeso}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColorDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de Cosecha basada en datos limpios con líneas sutiles
  Widget _buildHarvestCard(CultivoAdminDetailModel detail) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Rango de Fechas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FECHA INICIO',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColorMuted, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail.fechaInicio ?? '---',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColorDark),
                  ),
                ],
              ),
              const Text('—', style: TextStyle(color: textColorMuted, fontSize: 16)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'FECHA EST. FIN',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColorMuted, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail.fechaEstimadaFin ?? '---',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColorDark),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: dividerColor),
          ),

          // Filas Limpias de Datos
          _buildCleanDataRow(
            label: 'Cantidad Sembrada',
            value: '${_formatNum(detail.cantidadSembrada)} ${detail.unidadPeso}',
          ),
          const SizedBox(height: 12),
          _buildCleanDataRow(
            label: 'Área Sembrada',
            value: '${_formatNum(detail.areaSembradaValor)} ${detail.areaSembradaUnidad}',
          ),
          const SizedBox(height: 12),
          _buildCleanDataRow(
            label: 'Cantidad Total Disponible',
            value: '${_formatNum(detail.cantidadDisponible)} ${detail.unidadPeso}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCleanDataRow({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: textColorMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: textColorDark,
          ),
        ),
      ],
    );
  }

  /// Tarjeta de Vendedor Ultra Limpia
  Widget _buildSellerCard(CultivoAdminDetailModel detail, bool hasTelefono, bool hasEmail) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.nombreUsuario.isNotEmpty ? detail.nombreUsuario : 'Vendedor no especificado',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColorDark,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Productor Agrícola',
            style: TextStyle(
              fontSize: 12,
              color: textColorMuted,
            ),
          ),
          if (hasTelefono || hasEmail) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: dividerColor),
            ),
            if (hasTelefono)
              _buildSellerContactRow(
                label: 'Teléfono',
                value: detail.telefono!,
              ),
            if (hasTelefono && hasEmail) const SizedBox(height: 10),
            if (hasEmail)
              _buildSellerContactRow(
                label: 'Correo',
                value: detail.email!,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSellerContactRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: textColorMuted,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColorDark,
          ),
        ),
      ],
    );
  }

  /// Botón de Acción Limpio
  Widget _buildBottomBar(CultivoAdminDetailModel detail, bool hasTelefono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: cardColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: hasTelefono
                ? () => _abrirWhatsApp(detail.telefono!, detail.nombreCultivo)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Contactar Vendedor',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}