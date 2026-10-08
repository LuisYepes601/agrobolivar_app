import 'dart:async';
import 'package:flutter/material.dart';
import '../models/estado_cultivo_model.dart';
import '../models/estado_cultivo_detail_model.dart';
import '../models/create_estado_cultivo_dto.dart';
import '../services/estado_cultivo_service.dart';

class EstadosCultivoScreen extends StatefulWidget {
  final EstadoCultivoService? service;

  const EstadosCultivoScreen({
    super.key,
    this.service,
  });

  static const primaryGreen = Color(0xFF1E4D2B);

  @override
  State<EstadosCultivoScreen> createState() => _EstadosCultivoScreenState();
}

class _EstadosCultivoScreenState extends State<EstadosCultivoScreen> {
  late final EstadoCultivoService _service;
  final TextEditingController _searchController = TextEditingController();

  List<EstadoCultivoModel> _estados = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? EstadoCultivoService();
    _cargarEstados();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga la lista mediante el servicio HTTP
  Future<void> _cargarEstados() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.getEstadosCultivo();
      if (mounted) {
        setState(() {
          _estados = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar estados de cultivos: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  /// Filtro local por nombre o descripción
  List<EstadoCultivoModel> get _filteredEstados {
    if (_searchQuery.isEmpty) return _estados;
    return _estados.where((e) {
      final q = _searchQuery.toLowerCase();
      final nameMatches = e.nombre.toLowerCase().contains(q);
      final descMatches = e.descripcion?.toLowerCase().contains(q) ?? false;
      return nameMatches || descMatches;
    }).toList();
  }

  /// MODAL DETALLES Y AUDITORÍA
  void _showDetailsModal(EstadoCultivoModel estado) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalles de Auditoría',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: EstadosCultivoScreen.primaryGreen,
                          ),
                        ),
                        Text(
                          estado.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 24),

              FutureBuilder<EstadoCultivoDetailModel?>(
                future: _service.getEstadoDetails(estado.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: EstadosCultivoScreen.primaryGreen,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Error al obtener los detalles: ${snapshot.error}',
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final detail = snapshot.data;
                  if (detail == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'No se encontró información de detalle.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      _DetailTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Creado por',
                        value: detail.creatorName ?? detail.createBy ?? 'N/A',
                      ),
                      _DetailTile(
                        icon: Icons.edit_note_rounded,
                        label: 'Actualizado por',
                        value: detail.updateName ?? detail.updateBy ?? 'N/A',
                      ),
                      _DetailTile(
                        icon: Icons.delete_outline_rounded,
                        label: 'Estado de eliminación',
                        value: (detail.isDelete ?? false) ? 'Eliminado' : 'Activo',
                        valueColor: (detail.isDelete ?? false) ? Colors.red : Colors.green.shade700,
                      ),
                      if (detail.isDelete ?? false) ...[
                        _DetailTile(
                          icon: Icons.person_remove_outlined,
                          label: 'Eliminado por',
                          value: detail.deleteName ?? detail.deleteBy ?? 'N/A',
                        ),
                        _DetailTile(
                          icon: Icons.calendar_today_outlined,
                          label: 'Fecha de eliminación',
                          value: detail.deleteAt != null
                              ? detail.deleteAt!.toLocal().toString().split('.')[0]
                              : 'N/A',
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  /// MODAL PARA CREAR / EDITAR ESTADO
  void _openFormModal({EstadoCultivoModel? estado}) {
    final isEditing = estado != null;
    final nombreController = TextEditingController(text: estado?.nombre ?? '');
    final descController = TextEditingController(text: estado?.descripcion ?? '');
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
                            isEditing ? 'Editar Estado de Cultivo' : 'Nuevo Estado de Cultivo',
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
                          labelText: 'Nombre del estado',
                          prefixIcon: const Icon(Icons.grass_outlined),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa un nombre para el estado';
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
                            backgroundColor: EstadosCultivoScreen.primaryGreen,
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

                              final dto = CreateEstadoCultivoDto(
                                nombre: nombreController.text.trim(),
                                descripcion: descController.text.trim(),
                              );

                              try {
                                if (isEditing) {
                                  await _service.actualizarEstadoCultivo(estado.id, dto);
                                } else {
                                  await _service.crearEstadoCultivo(dto);
                                }

                                setModalState(() => _isSaving = false);

                                if (mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEditing
                                            ? 'Estado actualizado correctamente'
                                            : 'Estado registrado correctamente',
                                      ),
                                      backgroundColor: EstadosCultivoScreen.primaryGreen,
                                    ),
                                  );
                                  _cargarEstados();
                                }
                              } catch (e) {
                                setModalState(() => _isSaving = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEditing
                                            ? 'Error al actualizar: $e'
                                            : 'Error al registrar: $e',
                                      ),
                                      backgroundColor: Colors.red.shade600,
                                    ),
                                  );
                                }
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
                            isEditing ? 'Guardar Cambios' : 'Registrar Estado',
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
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredEstados;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: RefreshIndicator(
        onRefresh: _cargarEstados,
        color: EstadosCultivoScreen.primaryGreen,
        child: Column(
          children: [
            // BARRA DE BÚSQUEDA
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar estado por nombre o descripción...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade600,
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
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: EstadosCultivoScreen.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // CARRUSEL HERO
            if (_searchQuery.isEmpty) const _HeroEstadosCarousel(),

            // LISTADO DE ESTADOS
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: EstadosCultivoScreen.primaryGreen,
                ),
              )
                  : list.isEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.grass_outlined,
                            size: 52,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No hay estados de cultivos registrados'
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
                  vertical: 8,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _EstadoCardItem(
                    estado: item,
                    onEdit: () => _openFormModal(estado: item),
                    onDetails: () => _showDetailsModal(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFormModal(),
        backgroundColor: EstadosCultivoScreen.primaryGreen,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Agregar Estado',
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

// --- ITEM AUXILIAR PARA RENDERIZAR DETALLES ---
class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- CARRUSEL HERO TEMÁTICO ---
class _HeroEstadosCarousel extends StatefulWidget {
  const _HeroEstadosCarousel();

  @override
  State<_HeroEstadosCarousel> createState() => _HeroEstadosCarouselState();
}

class _HeroEstadosCarouselState extends State<_HeroEstadosCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _heroItems = const [
    {
      'title': 'Monitoreo de Fases Vegetativas',
      'subtitle': 'Sigue el crecimiento del cultivo desde la siembra hasta la cosecha',
      'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
      'tag': 'Estados Fenológicos',
    },
    {
      'title': 'Control y Alertas Tempranas',
      'subtitle': 'Identifica requerimientos hídricos y de nutrición según la etapa',
      'image': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=800&q=80',
      'tag': 'Gestión de Campo',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _heroItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 350),
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
        const SizedBox(height: 4),
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _heroItems.length,
            itemBuilder: (context, index) {
              final item = _heroItems[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          item['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: EstadosCultivoScreen.primaryGreen,
                          ),
                        ),
                      ),
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
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item['tag']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item['subtitle']!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _heroItems.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 5,
              width: _currentPage == index ? 18 : 5,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? EstadosCultivoScreen.primaryGreen
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

// --- TARJETA DE ESTADO CON FRANJA Y ACCIONES ---
class _EstadoCardItem extends StatelessWidget {
  final EstadoCultivoModel estado;
  final VoidCallback onEdit;
  final VoidCallback onDetails;

  const _EstadoCardItem({
    required this.estado,
    required this.onEdit,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final tieneDescripcion = estado.descripcion != null && estado.descripcion!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // FRANJA VERDE LATERAL
              Container(
                width: 5,
                color: EstadosCultivoScreen.primaryGreen,
              ),

              // CONTENIDO DE LA TARJETA
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onDetails,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  estado.nombre,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                if (tieneDescripcion) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    estado.descripcion!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF4B5563),
                                      height: 1.35,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            onPressed: onDetails,
                            tooltip: 'Ver auditoría',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: EstadosCultivoScreen.primaryGreen,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}