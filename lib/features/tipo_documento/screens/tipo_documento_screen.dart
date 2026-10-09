// lib/features/tipo_documento/screens/tipo_documento_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agro_bolivar/features/tipo_documento/models/tipo_documento_model.dart';
import 'package:agro_bolivar/features/tipo_documento/services/tipo_documento_api_service.dart';

class TipoDocumentoScreen extends StatefulWidget {
  final TipoDocumentoApiService? service;

  const TipoDocumentoScreen({
    super.key,
    this.service,
  });

  static const primaryGreen = Color(0xFF1E4D2B);

  @override
  State<TipoDocumentoScreen> createState() => _TipoDocumentoScreenState();
}

class _TipoDocumentoScreenState extends State<TipoDocumentoScreen> {
  late final TipoDocumentoApiService _service;
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();

  List<TipoDocumentoModel> _tiposDocumento = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _currentHeroIndex = 0;
  Timer? _carouselTimer;

  // Datos para el carrusel Hero (Contexto de Tipos de Documento)
  final List<Map<String, String>> _heroItems = const [
    {
      'titulo': 'Identificación Personal',
      'subtitulo': 'Registro formal de personas naturales, agricultores y productores.',
      'image': 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=800&q=80',
      'badge': 'PERSONAS',
    },
    {
      'titulo': 'Registro Empresarial y NIT',
      'subtitulo': 'Gestión de documentos para cooperativas, fincas y empresas agropecuarias.',
      'image': 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=800&q=80',
      'badge': 'TRIBUTARIO',
    },
    {
      'titulo': 'Documentación Internacional',
      'subtitulo': 'Soporte legal para pasaportes, alianzas y trámites de exportación.',
      'image': 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&w=800&q=80',
      'badge': 'COMERCIO',
    },
  ];

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TipoDocumentoApiService();
    _cargarTiposDocumento();
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

  /// Carga los tipos de documento consumiendo el servicio de la API
  Future<void> _cargarTiposDocumento() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.fetchTiposDocumento();
      if (mounted) {
        setState(() {
          _tiposDocumento = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar tipos de documento: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  /// Modal reutilizable para crear o editar un tipo de documento
  void _mostrarFormularioModal({TipoDocumentoModel? tipoDocumento}) {
    final isEditing = tipoDocumento != null;
    final nombreController = TextEditingController(
      text: isEditing ? tipoDocumento.nombre : '',
    );
    final descripcionController = TextEditingController(
      text: isEditing ? (tipoDocumento.descripcion ?? '') : '',
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
                            isEditing ? 'Editar Tipo de Documento' : 'Nuevo Tipo de Documento',
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
                      // CAMPO NOMBRE
                      TextFormField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre *',
                          hintText: 'Ej: Cédula de Ciudadanía, NIT, Pasaporte',
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
                      // CAMPO DESCRIPCIÓN
                      TextFormField(
                        controller: descripcionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Descripción *',
                          hintText: 'Ingrese una breve descripción...',
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
                      // BOTÓN GUARDAR / ACTUALIZAR
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TipoDocumentoScreen.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isSaving
                              ? null
                              : () async {
                            if (!formKey.currentState!.validate()) return;

                            setModalState(() => isSaving = true);

                            try {
                              final data = {
                                'nombre': nombreController.text.trim(),
                                'descripcion': descripcionController.text.trim(),
                              };

                              if (isEditing) {
                                await _service.actualizarTipoDocumento(
                                  tipoDocumento.id,
                                  data,
                                );
                              } else {
                                await _service.crearTipoDocumento(data);
                              }

                              if (mounted) {
                                Navigator.pop(modalContext);
                                _cargarTiposDocumento();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEditing
                                          ? 'Tipo de documento actualizado correctamente'
                                          : 'Tipo de documento creado correctamente',
                                    ),
                                    backgroundColor: TipoDocumentoScreen.primaryGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSaving = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al guardar: $e'),
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
                            isEditing ? 'Actualizar' : 'Guardar',
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

  /// Filtrado local por nombre o descripción
  List<TipoDocumentoModel> get _filteredTiposDocumento {
    if (_searchQuery.isEmpty) return _tiposDocumento;
    return _tiposDocumento.where((item) {
      final q = _searchQuery.toLowerCase();
      final nombreCoincide = item.nombre.toLowerCase().contains(q);
      final descCoincide = item.descripcion?.toLowerCase().contains(q) ?? false;
      return nombreCoincide || descCoincide;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredTiposDocumento;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TipoDocumentoScreen.primaryGreen,
        elevation: 4,
        onPressed: () => _mostrarFormularioModal(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarTiposDocumento,
        color: TipoDocumentoScreen.primaryGreen,
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
                                    color: TipoDocumentoScreen.primaryGreen.withOpacity(0.15),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: TipoDocumentoScreen.primaryGreen,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: TipoDocumentoScreen.primaryGreen,
                                  child: const Center(
                                    child: Icon(Icons.badge_rounded, color: Colors.white, size: 40),
                                  ),
                                ),
                              ),
                            ),
                            // Overlay degradado para legibilidad del texto
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
                            // Contenido informativo
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
                                      color: TipoDocumentoScreen.primaryGreen,
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
                          ? TipoDocumentoScreen.primaryGreen
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
                    hintText: 'Buscar tipo de documento...',
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
                        color: TipoDocumentoScreen.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // LISTADO DE TIPOS DE DOCUMENTO
              _isLoading
                  ? const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: TipoDocumentoScreen.primaryGreen,
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
                        Icons.badge_outlined,
                        size: 48,
                        color: Color(0xFFCCCCCC),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No hay tipos de documento registrados'
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
                  return _TipoDocumentoCardItem(
                    tipoDocumento: item,
                    onEdit: () => _mostrarFormularioModal(tipoDocumento: item),
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

// --- TARJETA DE TIPO DE DOCUMENTO ---
class _TipoDocumentoCardItem extends StatelessWidget {
  final TipoDocumentoModel tipoDocumento;
  final VoidCallback onEdit;

  const _TipoDocumentoCardItem({
    required this.tipoDocumento,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final bool tieneDescripcion = tipoDocumento.descripcion != null &&
        tipoDocumento.descripcion!.trim().isNotEmpty;

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
              color: TipoDocumentoScreen.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.badge_rounded,
              color: TipoDocumentoScreen.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipoDocumento.nombre,
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
                    tipoDocumento.descripcion!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // BOTÓN DE EDICIÓN
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: TipoDocumentoScreen.primaryGreen,
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