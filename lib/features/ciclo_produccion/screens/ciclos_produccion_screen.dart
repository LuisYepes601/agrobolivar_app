// lib/features/ciclo_produccion/screens/ciclos_produccion_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agro_bolivar/features/ciclo_produccion/models/ciclo_produccion_model.dart';
import 'package:agro_bolivar/features/ciclo_produccion/services/ciclo_produccion_service.dart';

class CiclosProduccionScreen extends StatefulWidget {
  final CicloProduccionService? service;

  const CiclosProduccionScreen({
    super.key,
    this.service,
  });

  static const primaryGreen = Color(0xFF1E4D2B);

  @override
  State<CiclosProduccionScreen> createState() => _CiclosProduccionScreenState();
}

class _CiclosProduccionScreenState extends State<CiclosProduccionScreen> {
  late final CicloProduccionService _service;
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();

  List<CicloProduccionModel> _ciclos = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _currentHeroIndex = 0;
  Timer? _carouselTimer;

  // Datos para el carrusel Hero
  final List<Map<String, String>> _heroItems = const [
    {
      'titulo': 'Ciclos de Cosecha',
      'subtitulo': 'Planificación integral de las fases de producción agrícola.',
      'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
      'badge': 'PRODUCCIÓN',
    },
    {
      'titulo': 'Monitoreo Fenológico',
      'subtitulo': 'Seguimiento continuo de etapas desde la siembra hasta la cosecha.',
      'image': 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?auto=format&fit=crop&w=800&q=80',
      'badge': 'ETAPAS',
    },
    {
      'titulo': 'Rendimiento Agrícola',
      'subtitulo': 'Optimización de insumos y tiempos de desarrollo por cultivo.',
      'image': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=800&q=80',
      'badge': 'EFICIENCIA',
    },
  ];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? CicloProduccionService();
    _cargarCiclos();
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

  /// Extractor seguro de campos opcionales del modelo de forma dinámica
  static String _getCicloField(CicloProduccionModel? ciclo, String key) {
    if (ciclo == null) return '';
    try {
      final dyn = ciclo as dynamic;
      final json = dyn.toJson();
      if (json is Map && json.containsKey(key)) {
        return json[key]?.toString() ?? '';
      }
    } catch (_) {}
    return '';
  }

  /// Carga la lista de ciclos desde el servicio
  Future<void> _cargarCiclos() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.getCiclosProduccion();
      if (mounted) {
        setState(() {
          _ciclos = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar ciclos de producción: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  /// Modal reutilizable para Crear (ciclo == null) o Editar (ciclo != null)
  void _mostrarFormularioModal({CicloProduccionModel? ciclo}) {
    final esEdicion = ciclo != null;
    final nombreController = TextEditingController(
      text: esEdicion ? (ciclo.nombre ?? _getCicloField(ciclo, 'nombre')) : '',
    );
    final diasMinimosController = TextEditingController(
      text: esEdicion ? _getCicloField(ciclo, 'diasMinimos') : '',
    );
    final diasMaximosController = TextEditingController(
      text: esEdicion ? _getCicloField(ciclo, 'diasMaximos') : '',
    );
    final descripcionController = TextEditingController(
      text: esEdicion ? _getCicloField(ciclo, 'descripcion') : '',
    );

    final formKey = GlobalKey<FormState>();
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
                            esEdicion ? 'Editar Ciclo de Producción' : 'Nuevo Ciclo de Producción',
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
                          hintText: 'Ej. MENSUAL, TRIMESTRAL, CORTO',
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: diasMinimosController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Días Mínimos *',
                                hintText: 'Ej. 25',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Obligatorio';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return 'Número inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: diasMaximosController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Días Máximos *',
                                hintText: 'Ej. 35',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Obligatorio';
                                }
                                final maxVal = int.tryParse(value.trim());
                                if (maxVal == null) {
                                  return 'Número inválido';
                                }
                                final minVal = int.tryParse(diasMinimosController.text.trim());
                                if (minVal != null && maxVal < minVal) {
                                  return 'Debe ser >= mín';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: descripcionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Descripción *',
                          hintText: 'Ej. Ciclo de producción aproximado de un mes',
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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CiclosProduccionScreen.primaryGreen,
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
                              'diasMinimos': int.parse(diasMinimosController.text.trim()),
                              'diasMaximos': int.parse(diasMaximosController.text.trim()),
                              'descripcion': descripcionController.text.trim(),
                            };

                            final bool exito;
                            if (esEdicion) {
                              exito = await _service.actualizarCicloProduccion(
                                ciclo.id,
                                payload,
                              );
                            } else {
                              exito = await _service.crearCicloProduccion(payload);
                            }

                            if (mounted) {
                              Navigator.pop(modalContext);
                              if (exito) {
                                _cargarCiclos();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      esEdicion
                                          ? 'Ciclo de producción actualizado correctamente'
                                          : 'Ciclo de producción creado correctamente',
                                    ),
                                    backgroundColor: CiclosProduccionScreen.primaryGreen,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      esEdicion
                                          ? 'Error al actualizar el ciclo de producción'
                                          : 'Error al guardar el ciclo de producción',
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

  /// Filtrado local seguro contra nulos
  List<CicloProduccionModel> get _filteredCiclos {
    if (_searchQuery.isEmpty) return _ciclos;
    return _ciclos.where((item) {
      final q = _searchQuery.toLowerCase();
      final nombreVal = (item.nombre ?? _getCicloField(item, 'nombre')).toLowerCase();
      final descVal = _getCicloField(item, 'descripcion').toLowerCase();
      return nombreVal.contains(q) || descVal.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredCiclos;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CiclosProduccionScreen.primaryGreen,
        elevation: 4,
        onPressed: () => _mostrarFormularioModal(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarCiclos,
        color: CiclosProduccionScreen.primaryGreen,
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
                                    color: CiclosProduccionScreen.primaryGreen.withOpacity(0.15),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: CiclosProduccionScreen.primaryGreen,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: CiclosProduccionScreen.primaryGreen,
                                  child: const Center(
                                    child: Icon(Icons.sync_rounded, color: Colors.white, size: 40),
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
                                      color: CiclosProduccionScreen.primaryGreen,
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
                          ? CiclosProduccionScreen.primaryGreen
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
                    hintText: 'Buscar ciclo de producción...',
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
                        color: CiclosProduccionScreen.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // LISTADO DE CICLOS DE PRODUCCIÓN
              _isLoading
                  ? const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: CiclosProduccionScreen.primaryGreen,
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
                        Icons.sync_disabled_rounded,
                        size: 48,
                        color: Color(0xFFCCCCCC),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No hay ciclos de producción registrados'
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
                  return _CicloProduccionCardItem(
                    ciclo: item,
                    onEdit: () => _mostrarFormularioModal(ciclo: item),
                    getFieldValue: (key) => _getCicloField(item, key),
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

// --- TARJETA DE CICLO DE PRODUCCIÓN ---
class _CicloProduccionCardItem extends StatelessWidget {
  final CicloProduccionModel ciclo;
  final VoidCallback onEdit;
  final String Function(String key) getFieldValue;

  const _CicloProduccionCardItem({
    required this.ciclo,
    required this.onEdit,
    required this.getFieldValue,
  });

  @override
  Widget build(BuildContext context) {
    final nombreText = ciclo.nombre ?? getFieldValue('nombre');
    final descripcionText = getFieldValue('descripcion');
    final minDias = getFieldValue('diasMinimos');
    final maxDias = getFieldValue('diasMaximos');
    final duracion = getFieldValue('diasDuracion');

    final tieneDescripcion = descripcionText.isNotEmpty;
    final tieneRangoDias = minDias.isNotEmpty && maxDias.isNotEmpty;

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
              color: CiclosProduccionScreen.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sync_rounded,
              color: CiclosProduccionScreen.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreText.isNotEmpty ? nombreText : 'Ciclo de Producción',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                    letterSpacing: -0.2,
                  ),
                ),
                if (tieneDescripcion) ...[
                  const SizedBox(height: 4),
                  Text(
                    descripcionText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (tieneRangoDias || duracion.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: CiclosProduccionScreen.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tieneRangoDias
                            ? '$minDias - $maxDias días'
                            : 'Duración: $duracion días',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CiclosProduccionScreen.primaryGreen,
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
              color: CiclosProduccionScreen.primaryGreen,
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