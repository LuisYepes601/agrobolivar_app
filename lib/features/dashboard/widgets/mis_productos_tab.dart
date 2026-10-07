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
      backgroundColor: Colors.transparent,
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
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
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
    final hasDescripcion = widget.producto.descripcion != null && widget.producto.descripcion!.trim().isNotEmpty;
    final isHighlighted = _isHovered || _isPressed;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : (_isHovered ? 1.03 : 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted
                  ? const Color(0xFF1E4D2B)
                  : Colors.grey.shade200,
              width: isHighlighted ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isHighlighted
                    ? const Color(0xFF1E4D2B).withOpacity(0.18)
                    : Colors.black.withOpacity(0.06),
                blurRadius: isHighlighted ? 18 : 10,
                spreadRadius: isHighlighted ? 2 : 0,
                offset: Offset(0, isHighlighted ? 8 : 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              splashColor: const Color(0xFF1E4D2B).withOpacity(0.12),
              highlightColor: const Color(0xFF1E4D2B).withOpacity(0.06),
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
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? const Color(0xFF1E4D2B)
                            : const Color(0xFF1E4D2B).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.producto.categoria.isNotEmpty
                            ? widget.producto.categoria
                            : 'General',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isHighlighted ? Colors.white : const Color(0xFF1E4D2B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: AnimatedScale(
                          scale: isHighlighted ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: hasImage
                              ? Image.network(
                            widget.producto.imgProducto!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.grass, color: Color(0xFF1E4D2B), size: 36),
                            ),
                          )
                              : const Center(
                            child: Icon(Icons.grass, color: Color(0xFF1E4D2B), size: 36),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.producto.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (hasDescripcion) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.producto.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          height: 1.2,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
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
      // Elevado a 60px para alejarse totalmente de la barra de paginación
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