import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agro_bolivar/features/auth/services/auth_local_service.dart';
import 'package:agro_bolivar/features/categorias/models/categoria_model.dart';
import 'package:agro_bolivar/features/categorias/services/categoria_service.dart';
import 'package:agro_bolivar/features/marcas/models/marca_model.dart';
import 'package:agro_bolivar/features/marcas/services/marca_service.dart';
import '../models/producto_model.dart';
import '../services/producto_service.dart';
import 'detalle_producto_screen.dart';
import 'package:agro_bolivar/features/dashboard/screens/crear_producto_screen.dart';

class MisProductosTab extends StatefulWidget {
  const MisProductosTab({super.key});

  @override
  State<MisProductosTab> createState() => _MisProductosTabState();
}

class _MisProductosTabState extends State<MisProductosTab> {
  final _productoService = ProductoService();
  final _categoriaService = CategoriaService();
  final _marcaService = MarcaService();
  final _authLocalService = AuthLocalService();
  final _searchController = TextEditingController();
  Timer? _debounce;

  // Controladores y Timer para el Carrusel Hero Automático
  final PageController _carouselController = PageController(viewportFraction: 0.92);
  int _currentCarouselPage = 0;
  Timer? _carouselTimer;

  List<Producto> _productos = [];
  List<Categoria> _categorias = [];
  List<Marca> _marcas = [];

  bool _isLoading = true;
  String? _errorMessage;

  // Controladores de paginación
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalElements = 0;
  final int _pageSize = 10;

  // Filtros adicionales
  String? _searchNombre;
  int? _idCat;
  int? _idMarca;
  double? _precioMin;
  double? _precioMax;
  String? _sortOrder;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
    _loadMarcas();
    _loadProductos();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _startAutoScrollCarousel() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      final destacados = _productos.take(4).toList();
      if (destacados.length > 1 && _carouselController.hasClients) {
        int nextPage = (_currentCarouselPage + 1) % destacados.length;
        _carouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadCategorias() async {
    try {
      final cats = await _categoriaService.fetchCategorias();
      if (mounted) {
        setState(() {
          _categorias = cats;
        });
      }
    } catch (e) {
      debugPrint('❌ [MisProductosTab] Error en _loadCategorias(): $e');
    }
  }

  Future<void> _loadMarcas() async {
    try {
      final marcas = await _marcaService.fetchMarcas();
      if (mounted) {
        setState(() {
          _marcas = marcas;
        });
      }
    } catch (e) {
      debugPrint('❌ [MisProductosTab] Error en _loadMarcas(): $e');
    }
  }

  Future<void> _loadProductos({int page = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dynamic rawUserId = await _authLocalService.getUserId();
      final int userId = (rawUserId is int)
          ? rawUserId
          : int.tryParse(rawUserId.toString()) ?? 1;

      final pageResponse = await _productoService.fetchMisProductos(
        userId,
        page: page,
        size: _pageSize,
        nombre: _searchNombre,
        idCat: _idCat,
        idMarca: _idMarca,
        precioMin: _precioMin,
        precioMax: _precioMax,
        sort: _sortOrder,
      );

      if (mounted) {
        setState(() {
          _productos = pageResponse.productos;
          _currentPage = pageResponse.currentPage;
          _totalPages = pageResponse.totalPages > 0 ? pageResponse.totalPages : 1;
          _totalElements = pageResponse.totalElements;
          _isLoading = false;
        });
        _startAutoScrollCarousel();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudieron cargar los productos.';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchNombre = query.trim().isEmpty ? null : query.trim();
      });
      _loadProductos(page: 0);
    });
  }

  Widget _buildHeroCarousel() {
    final destacados = _productos.take(4).toList();
    if (destacados.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 8),
      child: Column(
        children: [
          SizedBox(
            height: 148,
            child: PageView.builder(
              controller: _carouselController,
              itemCount: destacados.length,
              onPageChanged: (index) {
                setState(() {
                  _currentCarouselPage = index;
                });
              },
              itemBuilder: (context, index) {
                final prod = destacados[index];
                final hasImage = prod.imgProducto != null && prod.imgProducto!.isNotEmpty;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF4EF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFC6D8CC),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleProductoScreen(
                                productoId: prod.id,
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadProductos(page: _currentPage);
                          }
                        },
                        child: Row(
                          children: [
                            // 1. Información del Producto alineada a la izquierda
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Badge Destacado
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E4D2B),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            color: Colors.amber,
                                            size: 11,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'DESTACADO',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      prod.nombre,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '\$${prod.precioUnidad.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Color(0xFF1E4D2B),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '/${prod.categoria.isNotEmpty ? prod.categoria : 'unidad'}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF475569),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 2. Imagen de Alto Completo y Más Ancha
                            Container(
                              width: 135,
                              height: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  left: BorderSide(
                                    color: Color(0xFFC6D8CC),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: hasImage
                                    ? Image.network(
                                  prod.imgProducto!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.grass_rounded,
                                      color: Color(0xFF1E4D2B),
                                      size: 40,
                                    ),
                                  ),
                                )
                                    : const Center(
                                  child: Icon(
                                    Icons.grass_rounded,
                                    color: Color(0xFF1E4D2B),
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Indicadores de Paginación del Carrusel
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              destacados.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentCarouselPage == index ? 18 : 6,
                height: 5,
                decoration: BoxDecoration(
                  color: _currentCarouselPage == index
                      ? const Color(0xFF1E4D2B)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterModal() {
    final minController = TextEditingController(
        text: _precioMin != null ? _precioMin!.toStringAsFixed(0) : '');
    final maxController = TextEditingController(
        text: _precioMax != null ? _precioMax!.toStringAsFixed(0) : '');

    int? selectedCat = _categorias.any((c) => c.id == _idCat) ? _idCat : null;
    int? selectedMarca = _marcas.any((m) => m.id == _idMarca) ? _idMarca : null;
    String? selectedSort = _sortOrder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.tune_rounded, color: Color(0xFF1E4D2B), size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Filtros y Orden',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                _idCat = null;
                                _idMarca = null;
                                _precioMin = null;
                                _precioMax = null;
                                _sortOrder = null;
                              });
                              Navigator.pop(context);
                              _loadProductos(page: 0);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.refresh_rounded, size: 14, color: Color(0xFFEF4444)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Limpiar todo',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        children: [
                          _buildSectionHeader(
                            icon: Icons.sort_rounded,
                            title: 'Ordenar por',
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildFilterChip(
                                label: 'Menor precio',
                                icon: Icons.south_west_rounded,
                                isSelected: selectedSort == 'precioUnidad,asc',
                                onTap: () {
                                  setModalState(() {
                                    selectedSort = selectedSort == 'precioUnidad,asc'
                                        ? null
                                        : 'precioUnidad,asc';
                                  });
                                },
                              ),
                              _buildFilterChip(
                                label: 'Mayor precio',
                                icon: Icons.north_east_rounded,
                                isSelected: selectedSort == 'precioUnidad,desc',
                                onTap: () {
                                  setModalState(() {
                                    selectedSort = selectedSort == 'precioUnidad,desc'
                                        ? null
                                        : 'precioUnidad,desc';
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            icon: Icons.payments_outlined,
                            title: 'Rango de precio',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPriceInput(
                                  controller: minController,
                                  label: 'Mínimo',
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                width: 12,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF94A3B8),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Expanded(
                                child: _buildPriceInput(
                                  controller: maxController,
                                  label: 'Máximo',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (_categorias.isNotEmpty) ...[
                            _buildSectionHeader(
                              icon: Icons.grid_view_rounded,
                              title: 'Categorías',
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _categorias.map((cat) {
                                final isSelected = selectedCat == cat.id;
                                return _buildFilterChip(
                                  label: cat.nombre,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setModalState(() {
                                      selectedCat = isSelected ? null : cat.id;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (_marcas.isNotEmpty) ...[
                            _buildSectionHeader(
                              icon: Icons.verified_outlined,
                              title: 'Marcas',
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _marcas.map((marca) {
                                final isSelected = selectedMarca == marca.id;
                                return _buildFilterChip(
                                  label: marca.nombre,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setModalState(() {
                                      selectedMarca = isSelected ? null : marca.id;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.06),
                            offset: const Offset(0, -6),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E4D2B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _precioMin = double.tryParse(minController.text.trim());
                              _precioMax = double.tryParse(maxController.text.trim());
                              _idCat = selectedCat;
                              _idMarca = selectedMarca;
                              _sortOrder = selectedSort;
                            });
                            Navigator.pop(context);
                            _loadProductos(page: 0);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Ver resultados',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ],
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

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E4D2B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E4D2B) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(icon, size: 15, color: const Color(0xFF64748B)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInput({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        prefixIcon: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            widthFactor: 1,
            child: Text(
              '\$',
              style: TextStyle(
                color: Color(0xFF1E4D2B),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1E4D2B), width: 1.8),
        ),
      ),
    );
  }

  bool get _hasActiveFilters =>
      _idCat != null ||
          _idMarca != null ||
          _precioMin != null ||
          _precioMax != null ||
          _sortOrder != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: AnimatedFabCrearProducto(
        onPressed: () async {
          final creado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CrearProductoScreen(),
            ),
          );

          if (creado == true) {
            _loadProductos(page: _currentPage);
          }
        },
      ),
      body: Column(
        children: [
          // 1. Barra de Búsqueda y Filtro
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto por nombre...',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1E4D2B)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: _hasActiveFilters
                            ? const Color(0xFF1E4D2B)
                            : const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        Icons.tune,
                        color: _hasActiveFilters ? Colors.white : const Color(0xFF1E4D2B),
                      ),
                      onPressed: _openFilterModal,
                    ),
                    if (_hasActiveFilters)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Carrusel Hero Renovado (Con movimiento automático y tarjeta expandida)
          if (!_isLoading && _errorMessage == null && _productos.isNotEmpty)
            _buildHeroCarousel(),

          // 3. Cuadrícula de Productos
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E4D2B)),
            )
                : _errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadProductos(page: _currentPage),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E4D2B),
                    ),
                    child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
                : _productos.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No se encontraron productos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prueba cambiando tus términos de búsqueda o filtros.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () => _loadProductos(page: _currentPage),
              color: const Color(0xFF1E4D2B),
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemCount: _productos.length,
                itemBuilder: (context, index) {
                  final producto = _productos[index];
                  return ProductoGridCard(
                    producto: producto,
                    onProductoActualizado: () => _loadProductos(page: _currentPage),
                  );
                },
              ),
            ),
          ),

          // 4. Barra de Paginación Inferior
          _buildPaginationBar(),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: const Color(0xFF1E4D2B),
            onPressed: _currentPage > 0
                ? () => _loadProductos(page: _currentPage - 1)
                : null,
          ),
          Text(
            'Página ${_currentPage + 1} de $_totalPages',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1E293B),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            color: const Color(0xFF1E4D2B),
            onPressed: (_currentPage + 1) < _totalPages
                ? () => _loadProductos(page: _currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class ProductoGridCard extends StatefulWidget {
  final Producto producto;
  final VoidCallback? onProductoActualizado;

  const ProductoGridCard({
    super.key,
    required this.producto,
    this.onProductoActualizado,
  });

  @override
  State<ProductoGridCard> createState() => _ProductoGridCardState();
}

class _ProductoGridCardState extends State<ProductoGridCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.producto.imgProducto != null && widget.producto.imgProducto!.isNotEmpty;
    final isHighlighted = _isHovered || _isPressed;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : (_isHovered ? 1.02 : 1.0),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHighlighted
                  ? const Color(0xFF1E4D2B)
                  : const Color(0xFFE2E8F0),
              width: isHighlighted ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isHighlighted
                    ? const Color(0xFF1E4D2B).withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: isHighlighted ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleProductoScreen(
                      productoId: widget.producto.id,
                    ),
                  ),
                );

                if (result == true && widget.onProductoActualizado != null) {
                  widget.onProductoActualizado!();
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Imagen con Contenedor Proporcionado y Badge
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: hasImage
                                  ? Image.network(
                                widget.producto.imgProducto!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.grass_rounded,
                                    color: Color(0xFF1E4D2B),
                                    size: 40,
                                  ),
                                ),
                              )
                                  : const Center(
                                child: Icon(
                                  Icons.grass_rounded,
                                  color: Color(0xFF1E4D2B),
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Badge de Categoría
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              widget.producto.categoria.isNotEmpty
                                  ? widget.producto.categoria
                                  : 'General',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E4D2B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Información del Producto
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.producto.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (widget.producto.descripcion != null &&
                            widget.producto.descripcion!.trim().isNotEmpty)
                          Text(
                            widget.producto.descripcion!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          )
                        else
                          const SizedBox(height: 14),
                        const SizedBox(height: 6),
                        Text(
                          '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E4D2B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedFabCrearProducto extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedFabCrearProducto({super.key, required this.onPressed});

  @override
  State<AnimatedFabCrearProducto> createState() => _AnimatedFabCrearProductoState();
}

class _AnimatedFabCrearProductoState extends State<AnimatedFabCrearProducto> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _isPressed ? 0.92 : (_isHovered ? 1.12 : 1.0);
    final bool isHighlighted = _isHovered || _isPressed;

    return Container(
      margin: const EdgeInsets.only(bottom: 60, right: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _isPressed
                    ? const Color(0xFF14351E)
                    : (_isHovered ? const Color(0xFF276438) : const Color(0xFF1E4D2B)),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E4D2B).withOpacity(isHighlighted ? 0.45 : 0.25),
                    blurRadius: isHighlighted ? 16 : 8,
                    spreadRadius: isHighlighted ? 2 : 0,
                    offset: Offset(0, isHighlighted ? 6 : 3),
                  ),
                ],
              ),
              child: AnimatedRotation(
                turns: _isHovered ? 0.25 : 0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}