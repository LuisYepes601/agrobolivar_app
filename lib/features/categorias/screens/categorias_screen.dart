import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agro_bolivar/features/categorias/models/categoria_model.dart';
import 'package:agro_bolivar/features/categorias/services/categoria_service.dart';

class CategoriasScreen extends StatefulWidget {
  final List<Categoria>? categorias;
  final CategoriaService? categoriaService;
  final Function(String nombre, String? descripcion)? onAgregar;
  final Function(Categoria categoria, String nombre, String? descripcion)? onEditar;

  const CategoriasScreen({
    super.key,
    this.categorias,
    this.categoriaService,
    this.onAgregar,
    this.onEditar,
  });

  static const primaryGreen = Color(0xFF1E4D2B);

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  late final CategoriaService _categoriaService;
  final TextEditingController _searchController = TextEditingController();

  List<Categoria> _categorias = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _categoriaService = widget.categoriaService ?? CategoriaService();
    _cargarCategorias();
  }

  // --- OBTENER CATEGORÍAS DEL SERVICIO ---
  Future<void> _cargarCategorias() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _categoriaService.fetchCategorias();
      if (mounted) {
        setState(() {
          _categorias = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Categoria> get _filteredCategorias {
    if (_searchQuery.isEmpty) return _categorias;
    return _categorias
        .where((cat) =>
    cat.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (cat.descripcion?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
        .toList();
  }

  // --- MODAL PARA CREAR O EDITAR CATEGORÍA ---
  void _openCategoriaModal({Categoria? categoria}) {
    final isEditing = categoria != null;
    final nombreController = TextEditingController(text: categoria?.nombre ?? '');
    final descController = TextEditingController(text: categoria?.descripcion ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
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
                          isEditing ? 'Editar Categoría' : 'Nueva Categoría',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nombreController,
                      enabled: !_isSaving,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la Categoría',
                        prefixIcon: const Icon(Icons.label_outline_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa un nombre válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: descController,
                      enabled: !_isSaving,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Descripción (opcional)',
                        prefixIcon: const Icon(Icons.description_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CategoriasScreen.primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSaving
                            ? null
                            : () async {
                          if (formKey.currentState!.validate()) {
                            setModalState(() => _isSaving = true);

                            final nombre = nombreController.text.trim();
                            final desc = descController.text.trim().isEmpty
                                ? null
                                : descController.text.trim();

                            bool exito = false;

                            if (isEditing) {
                              if (widget.onEditar != null) {
                                widget.onEditar!(categoria, nombre, desc);
                                exito = true;
                              } else {
                                exito = await _categoriaService.editarCategoria(
                                  id: categoria.id,
                                  nombre: nombre,
                                  descripcion: desc,
                                );
                              }
                            } else {
                              if (widget.onAgregar != null) {
                                widget.onAgregar!(nombre, desc);
                                exito = true;
                              } else {
                                exito = await _categoriaService.crearCategoria(
                                  nombre: nombre,
                                  descripcion: desc,
                                );
                              }
                            }

                            setModalState(() => _isSaving = false);

                            if (mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    exito
                                        ? (isEditing
                                        ? 'Categoría actualizada con éxito'
                                        : 'Categoría creada con éxito')
                                        : 'Ocurrió un error al guardar',
                                  ),
                                  backgroundColor: exito
                                      ? CategoriasScreen.primaryGreen
                                      : Colors.red.shade600,
                                ),
                              );
                              _cargarCategorias();
                            }
                          }
                        },
                        child: _isSaving
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : Text(
                          isEditing ? 'Guardar Cambios' : 'Crear Categoría',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredCategorias;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _cargarCategorias,
        color: CategoriasScreen.primaryGreen,
        child: Column(
          children: [
            // BUSCADOR TIPO WHATSAPP / IOS
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                decoration: InputDecoration(
                  hintText: 'Buscar categoría...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600, size: 20),
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
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: CategoriasScreen.primaryGreen.withOpacity(0.3)),
                  ),
                ),
              ),
            ),

            // CARRUSEL HERO DE CATEGORÍAS DESTACADAS (Se oculta al buscar)
            if (_searchQuery.isEmpty) const _HeroCategoryCarousel(),

            // LISTADO DE TARJETAS
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: CategoriasScreen.primaryGreen,
                ),
              )
                  : list.isEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 52,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No hay categorías registradas'
                                : 'No se encontraron resultados',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _CategoriaCardItem(
                    categoria: item,
                    onEdit: () => _openCategoriaModal(categoria: item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCategoriaModal(),
        backgroundColor: CategoriasScreen.primaryGreen,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Agregar Categoría',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// --- WIDGET DEL CARRUSEL HERO ---
class _HeroCategoryCarousel extends StatefulWidget {
  const _HeroCategoryCarousel();

  @override
  State<_HeroCategoryCarousel> createState() => _HeroCategoryCarouselState();
}

class _HeroCategoryCarouselState extends State<_HeroCategoryCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _heroItems = [
    {
      'title': 'Granos y Cereales',
      'subtitle': 'Maíz, arroz, avena y cereales seleccionados',
      'image': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=800&auto=format&fit=crop',
      'tag': 'Popular',
    },
    {
      'title': 'Frutas y Hortalizas',
      'subtitle': 'Cosechas frescas traídas del campo',
      'image': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=800&auto=format&fit=crop',
      'tag': 'Frescos',
    },
    {
      'title': 'Dulces y Transformados',
      'subtitle': 'Mieles, mermeladas y golosinas artesanales',
      'image': 'https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?auto=format&fit=crop&w=800&q=80',
      'tag': 'Artesanal',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _heroItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _heroItems.length,
            itemBuilder: (context, index) {
              final item = _heroItems[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      // Imagen de fondo
                      Positioned.fill(
                        child: Image.network(
                          item['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: CategoriasScreen.primaryGreen,
                          ),
                        ),
                      ),
                      // Sombra en degradado
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.15),
                                Colors.black.withOpacity(0.75),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Textos e insignias del Hero
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item['tag']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['subtitle']!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        const SizedBox(height: 10),
        // Indicador de Puntos (Dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _heroItems.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: _currentPage == index ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? CategoriasScreen.primaryGreen
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CategoriaCardItem extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onEdit;

  const _CategoriaCardItem({
    required this.categoria,
    required this.onEdit,
  });

  String _getInicial(String nombre) {
    final trimmed = nombre.trim();
    if (trimmed.isNotEmpty) {
      return trimmed[0].toUpperCase();
    }
    return 'C';
  }

  @override
  Widget build(BuildContext context) {
    final descripcionText =
    (categoria.descripcion != null && categoria.descripcion!.isNotEmpty)
        ? categoria.descripcion!
        : 'Sin descripción registrada';

    final inicial = _getInicial(categoria.nombre);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        color: CategoriasScreen.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoria.nombre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        descripcionText,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.blue,
                    size: 20,
                  ),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}