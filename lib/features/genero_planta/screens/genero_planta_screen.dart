// lib/features/genero_planta/screens/genero_planta_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agro_bolivar/features/genero_planta/models/genero_planta_model.dart';
import 'package:agro_bolivar/features/genero_planta/services/genero_planta_service.dart';

class GenerosPlantaScreen extends StatefulWidget {
  final GeneroPlantaService? service;

  const GenerosPlantaScreen({
    super.key,
    this.service,
  });

  static const primaryGreen = Color(0xFF1E4D2B);

  @override
  State<GenerosPlantaScreen> createState() => _GenerosPlantaScreenState();
}

class _GenerosPlantaScreenState extends State<GenerosPlantaScreen> {
  late final GeneroPlantaService _service;
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();

  List<GeneroPlantaModel> _generos = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _currentHeroIndex = 0;
  Timer? _carouselTimer;

  // Datos para el carrusel Hero
  final List<Map<String, String>> _heroItems = const [
    {
      'titulo': 'Taxonomía Vegetal',
      'subtitulo': 'Clasificación taxonómica de las plantas cultivadas en la región.',
      'image': 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&w=800&q=80',
      'badge': 'TAXONOMÍA',
    },
    {
      'titulo': 'Familias Botánicas',
      'subtitulo': 'Agrupación genérica para optimizar la rotación y sanidad de cultivos.',
      'image': 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?auto=format&fit=crop&w=800&q=80',
      'badge': 'BOTÁNICA',
    },
    {
      'titulo': 'Diversidad de Especies',
      'subtitulo': 'Identificación genómica y morfológica para el manejo agronómico.',
      'image': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=800&q=80',
      'badge': 'ESPECIES',
    },
  ];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? GeneroPlantaService();
    _cargarGeneros();
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

  /// Carga los géneros consumiendo GeneroPlantaService.fetchGeneros()
  Future<void> _cargarGeneros() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.fetchGeneros();
      if (mounted) {
        setState(() {
          _generos = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar géneros de planta: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  /// Modal reutilizable para Crear (genero == null) o Editar (genero != null)
  void _mostrarFormularioModal({GeneroPlantaModel? genero}) {
    final esEdicion = genero != null;
    final nombreController = TextEditingController(text: esEdicion ? genero.nombre ?? '' : '');
    final descripcionController = TextEditingController(text: esEdicion ? (genero.descripcion ?? '') : '');
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
                            esEdicion ? 'Editar Género de Planta' : 'Nuevo Género de Planta',
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
                          hintText: 'Ej. Solanum, Zea, Phaseolus',
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
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción (Opcional)',
                          hintText: 'Escribe una breve descripción botánica...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GenerosPlantaScreen.primaryGreen,
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
                              if (descripcionController.text.trim().isNotEmpty)
                                'descripcion': descripcionController.text.trim(),
                            };

                            final bool exito;
                            if (esEdicion) {
                              exito = await _service.actualizarGeneroPlanta(
                                genero.id,
                                payload,
                              );
                            } else {
                              exito = await _service.crearGeneroPlanta(payload);
                            }

                            if (mounted) {
                              Navigator.pop(modalContext);
                              if (exito) {
                                _cargarGeneros();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      esEdicion
                                          ? 'Género de planta actualizado correctamente'
                                          : 'Género de planta creado correctamente',
                                    ),
                                    backgroundColor: GenerosPlantaScreen.primaryGreen,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      esEdicion
                                          ? 'Error al actualizar el género de planta'
                                          : 'Error al guardar el género de planta',
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

  /// Filtrado local seguro contra nulos (Null-Safety)
  List<GeneroPlantaModel> get _filteredGeneros {
    if (_searchQuery.isEmpty) return _generos;
    return _generos.where((item) {
      final q = _searchQuery.toLowerCase();
      final nombreMatches = (item.nombre ?? '').toLowerCase().contains(q);
      final descMatches = item.descripcion?.toLowerCase().contains(q) ?? false;
      return nombreMatches || descMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredGeneros;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GenerosPlantaScreen.primaryGreen,
        elevation: 4,
        onPressed: () => _mostrarFormularioModal(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarGeneros,
        color: GenerosPlantaScreen.primaryGreen,
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
                                    color: GenerosPlantaScreen.primaryGreen.withOpacity(0.15),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: GenerosPlantaScreen.primaryGreen,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: GenerosPlantaScreen.primaryGreen,
                                  child: const Center(
                                    child: Icon(Icons.park_rounded, color: Colors.white, size: 40),
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
                                      color: GenerosPlantaScreen.primaryGreen,
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
                          ? GenerosPlantaScreen.primaryGreen
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
                    hintText: 'Buscar género de planta...',
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
                        color: GenerosPlantaScreen.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // LISTADO DE GÉNEROS
              _isLoading
                  ? const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: GenerosPlantaScreen.primaryGreen,
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
                        Icons.park_outlined,
                        size: 48,
                        color: Color(0xFFCCCCCC),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No hay géneros de planta registrados'
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
                  return _GeneroPlantaCardItem(
                    genero: item,
                    onEdit: () => _mostrarFormularioModal(genero: item),
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

// --- TARJETA DE GÉNERO DE PLANTA ---
class _GeneroPlantaCardItem extends StatelessWidget {
  final GeneroPlantaModel genero;
  final VoidCallback onEdit;

  const _GeneroPlantaCardItem({
    required this.genero,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final tieneDescripcion =
        genero.descripcion != null && genero.descripcion!.trim().isNotEmpty;

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
              color: GenerosPlantaScreen.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.park_rounded,
              color: GenerosPlantaScreen.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  genero.nombre ?? '',
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
                    genero.descripcion!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: GenerosPlantaScreen.primaryGreen,
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