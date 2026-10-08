import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:agro_bolivar/features/categorias/models/categoria_model.dart';
import 'package:agro_bolivar/features/categorias/services/categoria_service.dart';
import 'package:agro_bolivar/features/marcas/models/marca_model.dart';
import 'package:agro_bolivar/features/marcas/services/marca_service.dart';
import '../models/producto_model.dart';
import '../services/producto_service.dart';
import 'detalle_producto_screen.dart';

class TiendaTab extends StatefulWidget {
  const TiendaTab({super.key});

  @override
  State<TiendaTab> createState() => _TiendaTabState();
}

class _TiendaTabState extends State<TiendaTab> {
  final _productoService = ProductoService();
  final _categoriaService = CategoriaService();
  final _marcaService = MarcaService();
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<Producto> _productos = [];
  List<Categoria> _categorias = [];
  List<Marca> _marcas = [];

  bool _isLoading = true;
  bool _isLoadingCategorias = true;
  bool _isLoadingMarcas = true;
  String? _errorMessage;

  // Controladores de paginación
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalElements = 0;
  final int _pageSize = 10;

  // Filtros de búsqueda
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
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCategorias() async {
    try {
      final cats = await _categoriaService.fetchCategorias();
      if (mounted) {
        setState(() {
          _categorias = cats;
          _isLoadingCategorias = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [TiendaTab] Error en _loadCategorias(): $e');
      if (mounted) {
        setState(() => _isLoadingCategorias = false);
      }
    }
  }

  Future<void> _loadMarcas() async {
    try {
      final marcas = await _marcaService.fetchMarcas();
      if (mounted) {
        setState(() {
          _marcas = marcas;
          _isLoadingMarcas = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [TiendaTab] Error en _loadMarcas(): $e');
      if (mounted) {
        setState(() => _isLoadingMarcas = false);
      }
    }
  }

  Future<void> _loadProductos({int page = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pageResponse = await _productoService.fetchProductos(
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
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _searchNombre = query.trim().isEmpty ? null : query.trim();
      });
      _loadProductos(page: 0);
    });
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      width: 40,
                      height: 4,
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
                              Icon(Icons.tune_rounded, color: Color(0xFF1E4D2B), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Filtros y Orden',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
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
                                borderRadius: BorderRadius.circular(8),
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
                                      fontSize: 12,
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
                            spacing: 8,
                            runSpacing: 8,
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
                          _buildSectionHeader(
                            icon: Icons.grid_view_rounded,
                            title: 'Categorías',
                          ),
                          const SizedBox(height: 12),
                          if (_isLoadingCategorias)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF1E4D2B),
                                  ),
                                ),
                              ),
                            )
                          else if (_categorias.isEmpty)
                            const Text(
                              'No hay categorías disponibles',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
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
                          _buildSectionHeader(
                            icon: Icons.verified_outlined,
                            title: 'Marcas',
                          ),
                          const SizedBox(height: 12),
                          if (_isLoadingMarcas)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF1E4D2B),
                                  ),
                                ),
                              ),
                            )
                          else if (_marcas.isEmpty)
                            const Text(
                              'No hay marcas disponibles',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
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
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.05),
                            offset: const Offset(0, -4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E4D2B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            final minVal = double.tryParse(minController.text.trim());
                            final maxVal = double.tryParse(maxController.text.trim());
                            setState(() {
                              _precioMin = minVal;
                              _precioMax = maxVal;
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
                                'Aplicar filtros',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
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
    ).then((_) {
      minController.dispose();
      maxController.dispose();
    });
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E4D2B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E4D2B) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(icon, size: 14, color: const Color(0xFF64748B)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
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
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        prefixIcon: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            widthFactor: 1,
            child: Text(
              '\$',
              style: TextStyle(
                color: Color(0xFF1E4D2B),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E4D2B), width: 1.5),
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // 1. Barra de Búsqueda
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Buscar producto en la tienda...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close, size: 15, color: Color(0xFF64748B)),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: _hasActiveFilters ? const Color(0xFF1E4D2B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: _hasActiveFilters ? Colors.white : const Color(0xFF475569),
                        ),
                        onPressed: _openFilterModal,
                      ),
                    ),
                    if (_hasActiveFilters)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 7,
                          height: 7,
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

          // 2. Cinta Marquesina 100% Sin Cortes
          const CintaAgroBolivar(),

          // 3. Contenido Principal
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E4D2B)))
                : _errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadProductos(page: _currentPage),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E4D2B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text(
                    'No se encontraron productos',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prueba cambiando tus términos de búsqueda o filtros.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () => _loadProductos(page: _currentPage),
              color: const Color(0xFF1E4D2B),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carrusel Destacado Ligero y Legible
                    CarruselDestacadosSection(
                      productos: _productos,
                      onRefreshRequired: () => _loadProductos(page: _currentPage),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(14, 8, 14, 6),
                      child: Text(
                        'Todos los Productos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),

                    // Cuadrícula Principal
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.74,
                      ),
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        return ProductoGridCard(
                          producto: _productos[index],
                          onRefreshRequired: () => _loadProductos(page: _currentPage),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildPaginationBar(),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            color: const Color(0xFF1E4D2B),
            onPressed: _currentPage > 0 ? () => _loadProductos(page: _currentPage - 1) : null,
          ),
          Text(
            'Página ${_currentPage + 1} de $_totalPages',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              color: Color(0xFF64748B),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            color: const Color(0xFF1E4D2B),
            onPressed: (_currentPage + 1) < _totalPages ? () => _loadProductos(page: _currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CINTA MARQUESINA 100% INFINITA (SIN CORTE VISUAL)
// ---------------------------------------------------------------------------
class CintaAgroBolivar extends StatefulWidget {
  const CintaAgroBolivar({super.key});

  @override
  State<CintaAgroBolivar> createState() => _CintaAgroBolivarState();
}

class _CintaAgroBolivarState extends State<CintaAgroBolivar>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Ticker _ticker;
  final GlobalKey _childKey = GlobalKey();
  double _singleWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _ticker = createTicker((_) {
      if (!_scrollController.hasClients || _singleWidth == 0.0) return;

      double newOffset = _scrollController.offset + 0.5;

      if (newOffset >= _singleWidth) {
        newOffset -= _singleWidth;
      }

      _scrollController.jumpTo(newOffset);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureWidth();
      _ticker.start();
    });
  }

  void _measureWidth() {
    final renderBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        _singleWidth = renderBox.size.width;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF1E4D2B),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: IgnorePointer(
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              Container(
                key: _childKey,
                child: _buildSecuenciaMarquesina(),
              ),
              _buildSecuenciaMarquesina(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecuenciaMarquesina() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(10, (index) {
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 12),
            Icon(Icons.grass_rounded, color: Colors.amber, size: 11),
            SizedBox(width: 5),
            Text(
              'AGROBOLÍVAR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 12),
            Text(
              '•',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// CARRUSEL DESTACADO LIGERAMENTE MÁS ALTO (98 px)
// ---------------------------------------------------------------------------
class CarruselDestacadosSection extends StatefulWidget {
  final List<Producto> productos;
  final VoidCallback onRefreshRequired;

  const CarruselDestacadosSection({
    super.key,
    required this.productos,
    required this.onRefreshRequired,
  });

  @override
  State<CarruselDestacadosSection> createState() => _CarruselDestacadosSectionState();
}

class _CarruselDestacadosSectionState extends State<CarruselDestacadosSection>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _ticker = createTicker((_) {
      if (!_scrollController.hasClients || widget.productos.isEmpty) return;
      _scrollController.jumpTo(_scrollController.offset + 0.6);
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productos.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 2),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF86EFAC),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E4D2B).withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              'Productos Destacados',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: Color(0xFF1E4D2B),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 98, // Ligeramente más alto para mejor legibilidad
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) {
                final producto = widget.productos[index % widget.productos.length];
                return ProductoDestacadoCard(
                  producto: producto,
                  onRefreshRequired: widget.onRefreshRequired,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TARJETA DE PRODUCTO DESTACADO SIN CATEGORÍA NI PRECIO (MAYOR VISIBILIDAD)
// ---------------------------------------------------------------------------
class ProductoDestacadoCard extends StatefulWidget {
  final Producto producto;
  final VoidCallback? onRefreshRequired;

  const ProductoDestacadoCard({
    super.key,
    required this.producto,
    this.onRefreshRequired,
  });

  @override
  State<ProductoDestacadoCard> createState() => _ProductoDestacadoCardState();
}

class _ProductoDestacadoCardState extends State<ProductoDestacadoCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.producto.imgProducto != null && widget.producto.imgProducto!.isNotEmpty;
    final isHighlighted = _isHovered || _isPressed;

    return Container(
      width: 88, // Ancho proporcional a la nueva altura
      margin: const EdgeInsets.symmetric(horizontal: 3.5),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalleProductoScreen(
                  productoId: widget.producto.id,
                  esTienda: true,
                ),
              ),
            );
            if (widget.onRefreshRequired != null) {
              widget.onRefreshRequired!();
            }
          },
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isHighlighted ? const Color(0xFF1E4D2B) : const Color(0xFFE2E8F0),
                  width: isHighlighted ? 1.2 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHighlighted
                        ? const Color(0xFF1E4D2B).withOpacity(0.1)
                        : const Color(0xFF0F172A).withOpacity(0.03),
                    blurRadius: isHighlighted ? 4 : 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Imagen del producto (Ocupa la mayor parte del espacio)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: hasImage
                            ? Image.network(
                          widget.producto.imgProducto!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.eco_outlined, color: Color(0xFF94A3B8), size: 18),
                          ),
                        )
                            : const Center(
                          child: Icon(Icons.eco_outlined, color: Color(0xFF94A3B8), size: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Nombre del producto
                  Text(
                    widget.producto.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
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

// ---------------------------------------------------------------------------
// TARJETA DE PRODUCTO PARA LA CUADRÍCULA PRINCIPAL
// ---------------------------------------------------------------------------
class ProductoGridCard extends StatefulWidget {
  final Producto producto;
  final VoidCallback? onRefreshRequired;

  const ProductoGridCard({
    super.key,
    required this.producto,
    this.onRefreshRequired,
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
    final categoriaTexto = widget.producto.categoria.isNotEmpty ? widget.producto.categoria : 'General';
    final isHighlighted = _isHovered || _isPressed;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleProductoScreen(
                productoId: widget.producto.id,
                esTienda: true,
              ),
            ),
          );
          if (widget.onRefreshRequired != null) {
            widget.onRefreshRequired!();
          }
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isHighlighted ? const Color(0xFF1E4D2B) : const Color(0xFFF1F5F9),
                width: isHighlighted ? 1.2 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHighlighted
                      ? const Color(0xFF1E4D2B).withOpacity(0.1)
                      : const Color(0xFF0F172A).withOpacity(0.03),
                  blurRadius: isHighlighted ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4D2B).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      categoriaTexto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E4D2B),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: hasImage
                          ? Image.network(
                        widget.producto.imgProducto!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.eco_outlined, color: Color(0xFF94A3B8), size: 18),
                        ),
                      )
                          : const Center(
                        child: Icon(Icons.eco_outlined, color: Color(0xFF94A3B8), size: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.producto.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '\$${widget.producto.precioUnidad.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E4D2B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}