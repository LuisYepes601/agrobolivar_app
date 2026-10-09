// lib/features/estaciones/screens/estaciones_cultivo_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agro_bolivar/features/estaciones/models/estacion_model.dart';
import 'package:agro_bolivar/features/estaciones/services/estacion_service.dart';

class EstacionesCultivoScreen extends StatefulWidget {
  final EstacionService? service;

  const EstacionesCultivoScreen({
    super.key,
    this.service,
  });

  static const primaryGreen = Color(0xFF1E4D2B);

  @override
  State<EstacionesCultivoScreen> createState() => _EstacionesCultivoScreenState();
}

class _EstacionesCultivoScreenState extends State<EstacionesCultivoScreen> {
  late final EstacionService _service;
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();

  List<EstacionModel> _estaciones = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _currentHeroIndex = 0;
  Timer? _carouselTimer;

  // Datos para el carrusel Hero
  final List<Map<String, String>> _heroItems = const [
    {
      'titulo': 'Temporadas Agrícolas',
      'subtitulo': 'Planificación de siembras y cosechas según el período climático.',
      'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
      'badge': 'ESTACIONES',
    },
    {
      'titulo': 'Clima y Rendimiento',
      'subtitulo': 'Optimización del riego y nutrición según la estación meteorológica.',
      'image': 'https://images.unsplash.com/photo-1592417817098-8f3d6eb23659?auto=format&fit=crop&w=800&q=80',
      'badge': 'CLIMA',
    },
    {
      'titulo': 'Calendario Agronómico',
      'subtitulo': 'Monitoreo de ventanas fenológicas para potenciar la producción.',
      'image': 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?auto=format&fit=crop&w=800&q=80',
      'badge': 'SIEMBRA',
    },
  ];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? EstacionService();
    _cargarEstaciones();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentHeroIndex + 1) % _heroItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Extrae propiedades adicionales de EstacionModel dinámicamente evitando errores de compilación
  static String _getEstacionField(EstacionModel? estacion, String key) {
    if (estacion == null) return '';
    try {
      final dyn = estacion as dynamic;
      final json = dyn.toJson();
      if (json is Map && json.containsKey(key)) {
        return json[key]?.toString() ?? '';
      }
    } catch (_) {}
    return '';
  }

  /// Carga la lista de estaciones desde el servicio
  Future<void> _cargarEstaciones() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.fetchEstaciones();
      if (mounted) {
        setState(() {
          _estaciones = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar estaciones de cultivo: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Modal para Crear o Editar estaciones de cultivo
  void _mostrarFormularioModal({EstacionModel? estacion}) {
    final esEdicion = estacion != null;
    final nombreController = TextEditingController(text: esEdicion ? (estacion.nombre ?? '') : '');
    final descripcionController = TextEditingController(
      text: esEdicion ? _getEstacionField(estacion, 'descripcion') : '',
    );
    final fechaInicioController = TextEditingController(
      text: esEdicion ? _getEstacionField(estacion, 'fechaInicio') : '',
    );
    final fechaFinController = TextEditingController(
      text: esEdicion ? _getEstacionField(estacion, 'fechaFin') : '',
    );

    final formKey = GlobalKey<FormState>();
    DateTime? fechaInicioSelected;
    DateTime? fechaFinSelected;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                          Text(
                            esEdicion ? 'Editar Estación de Cultivo' : 'Nueva Estación de Cultivo',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre *',
                          hintText: 'Ej. Hortaliza, Verano, Primavera',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: descripcionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Descripción *',
                          hintText: 'Escribe el propósito o características...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La descripción es obligatoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: fechaInicioController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Fecha Inicio *',
                                hintText: 'YYYY-MM-DD',
                                suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Obligatoria';
                                }
                                return null;
                              },
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: fechaInicioSelected ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    fechaInicioSelected = picked;
                                    fechaInicioController.text = _formatDate(picked);
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: fechaFinController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Fecha Fin *',
                                hintText: 'YYYY-MM-DD',
                                suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Obligatoria';
                                }
                                return null;
                              },
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: fechaFinSelected ?? (fechaInicioSelected ?? DateTime.now()),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    fechaFinSelected = picked;
                                    fechaFinController.text = _formatDate(picked);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EstacionesCultivoScreen.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isSaving
                              ? null
                              : () async {
                            if (!formKey.currentState!.validate()) return;

                            setModalState(() => isSaving = true);

                            final payload = {
                              'nombre': nombreController.text.trim(),
                              'descripcion': descripcionController.text.trim(),
                              'fechaInicio': fechaInicioController.text.trim(),
                              'fechaFin': fechaFinController.text.trim(),
                            };

                            final bool exito;
                            if (esEdicion) {
                              exito = await _service.actualizarEstacion(
                                estacion.id,
                                payload,
                              );
                            } else {
                              exito = await _service.crearEstacion(payload);
                            }

                            if (mounted) {
                              Navigator.pop(modalContext);
                              if (exito) {
                                _cargarEstaciones();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      esEdicion
                                          ? 'Estación de cultivo actualizada correctamente'
                                          : 'Estación de cultivo creada correctamente',
                                    ),
                                    backgroundColor: EstacionesCultivoScreen.primaryGreen,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      esEdicion
                                          ? 'Error al actualizar la estación de cultivo'
                                          : 'Error al guardar la estación de cultivo',
                                    ),
                                    backgroundColor: Colors.red.shade600,
                                  ),
                                );
                              }
                            }
                          },
                          child: isSaving
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            esEdicion ? 'Actualizar' : 'Guardar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

  /// Filtrado local seguro por nombre o descripción
  List<EstacionModel> get _filteredEstaciones {
    if (_searchQuery.isEmpty) return _estaciones;
    return _estaciones.where((item) {
      final q = _searchQuery.toLowerCase();
      final nombreMatches = (item.nombre ?? '').toLowerCase().contains(q);
      final desc = _getEstacionField(item, 'descripcion').toLowerCase();
      return nombreMatches || (desc.isNotEmpty && desc.contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredEstaciones;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton(
        backgroundColor: EstacionesCultivoScreen.primaryGreen,
        elevation: 4,
        onPressed: () => _mostrarFormularioModal(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarEstaciones,
        color: EstacionesCultivoScreen.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // --- CARRUSEL HERO ---
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentHeroIndex = index);
                  },
                  itemCount: _heroItems.length,
                  itemBuilder: (context, index) {
                    final item = _heroItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                item['image']!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: EstacionesCultivoScreen.primaryGreen.withOpacity(0.15),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: EstacionesCultivoScreen.primaryGreen,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: EstacionesCultivoScreen.primaryGreen,
                                  child: const Center(
                                    child: Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 40),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.2),
                                      Colors.black.withOpacity(0.85),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: EstacionesCultivoScreen.primaryGreen,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item['badge']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['titulo']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['subtitulo']!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Indicadores del carrusel
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_heroItems.length, (index) {
                  final isSelected = _currentHeroIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 6,
                    width: isSelected ? 18 : 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? EstacionesCultivoScreen.primaryGreen
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),

              // BARRA DE BÚSQUEDA
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Buscar estación de cultivo...',
                    hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF666666),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: EstacionesCultivoScreen.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // LISTADO DE ESTACIONES
              _isLoading
                  ? const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: EstacionesCultivoScreen.primaryGreen,
                  ),
                ),
              )
                  : list.isEmpty
                  ? SizedBox(
                height: 250,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wb_sunny_outlined,
                        size: 48,
                        color: Color(0xFFCCCCCC),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No hay estaciones de cultivo registradas'
                            : 'No se encontraron resultados',
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _EstacionCardItem(
                    estacion: item,
                    onEdit: () => _mostrarFormularioModal(estacion: item),
                    getFieldValue: (key) => _getEstacionField(item, key),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TARJETA DE ESTACIÓN DE CULTIVO ---
class _EstacionCardItem extends StatelessWidget {
  final EstacionModel estacion;
  final VoidCallback onEdit;
  final String Function(String key) getFieldValue;

  const _EstacionCardItem({
    required this.estacion,
    required this.onEdit,
    required this.getFieldValue,
  });

  @override
  Widget build(BuildContext context) {
    final descripcion = getFieldValue('descripcion');
    final fechaInicio = getFieldValue('fechaInicio');
    final fechaFin = getFieldValue('fechaFin');

    final tieneDesc = descripcion.isNotEmpty;
    final tieneFechas = fechaInicio.isNotEmpty || fechaFin.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: EstacionesCultivoScreen.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: EstacionesCultivoScreen.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estacion.nombre ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                    letterSpacing: -0.2,
                  ),
                ),
                if (tieneDesc) ...[
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (tieneFechas) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF888888)),
                      const SizedBox(width: 4),
                      Text(
                        '$fechaInicio  ➔  $fechaFin',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: EstacionesCultivoScreen.primaryGreen,
              size: 20,
            ),
            onPressed: onEdit,
            tooltip: 'Editar',
          ),
        ],
      ),
    );
  }
}