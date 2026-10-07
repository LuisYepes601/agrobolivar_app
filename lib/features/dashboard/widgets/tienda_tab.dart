import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
          // Barra de Búsqueda
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Buscar producto en la tienda...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: _hasActiveFilters ? const Color(0xFF1E4D2B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          size: 20,
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
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E4D2B)))
                : _errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: const TextStyle(fontSize: 15, color: Color(0xFF475569))),
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
                  Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No se encontraron productos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Prueba cambiando tus términos de búsqueda o filtros.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                  childAspectRatio: 0.58,
                ),
                itemCount: _productos.length,
                itemBuilder: (context, index) {
                  return ProductoGridCard(
                    producto: _productos[index],
                    onRefreshRequired: () => _loadProductos(page: _currentPage),
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
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 22),
            color: const Color(0xFF1E4D2B),
            onPressed: _currentPage > 0 ? () => _loadProductos(page: _currentPage - 1) : null,
          ),
          Text(
            'Página ${_currentPage + 1} de $_totalPages',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 22),
            color: const Color(0xFF1E4D2B),
            onPressed: (_currentPage + 1) < _totalPages ? () => _loadProductos(page: _currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TARJETA DE PRODUCTO REDISEÑADA CON MICRO-INTERACCIONES + HOVER
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

  Future<void> _abrirWhatsApp(BuildContext context, String? telefono, String productoNombre) async {
    if (telefono == null || telefono.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este producto no tiene número de contacto registrado.')),
        );
      }
      return;
    }

    final numLimpio = telefono.replaceAll(RegExp(r'[^\d]'), '');
    if (numLimpio.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Número de teléfono inválido.')),
        );
      }
      return;
    }

    final mensaje = Uri.encodeComponent('¡Hola! Me interesa comprar "$productoNombre" que vi en AgroBolívar.');
    final uri = Uri.parse('https://wa.me/$numLimpio?text=$mensaje');

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al redirigir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.producto.imgProducto != null && widget.producto.imgProducto!.isNotEmpty;
    final hasDescripcion = widget.producto.descripcion != null && widget.producto.descripcion!.trim().isNotEmpty;
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHighlighted ? const Color(0xFF1E4D2B) : const Color(0xFFF1F5F9),
                width: isHighlighted ? 1.4 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHighlighted
                      ? const Color(0xFF1E4D2B).withOpacity(0.12)
                      : const Color(0xFF0F172A).withOpacity(0.04),
                  blurRadius: isHighlighted ? 14 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pill de Categoría Alineado a la Izquierda
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4D2B).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      categoriaTexto,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E4D2B),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                // Imagen del Producto
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: hasImage
                          ? Image.network(
                        widget.producto.imgProducto!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.eco_outlined, color: Color(0xFF94A3B8), size: 28),
                        ),
                      )
                          : const Center(
                        child: Icon(Icons.eco_outlined, color: Color(0xFF94A3B8), size: 28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Nombre
                Text(
                  widget.producto.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),

                // Descripción opcional
                if (hasDescripcion) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.producto.descripcion!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
                const SizedBox(height: 4),

                // Precio
                Text(
                  '\$${widget.producto.precioUnidad.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E4D2B),
                  ),
                ),
                const SizedBox(height: 8),

                // Botón de WhatsApp
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _abrirWhatsApp(
                      context,
                      widget.producto.telefono,
                      widget.producto.nombre,
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 13),
                    label: const Text(
                      'Comprar',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
  }
}