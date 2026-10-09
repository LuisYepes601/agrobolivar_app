import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ciclo_germinacion_model.dart';
import '../models/ciclo_germinacion_detail_model.dart';
import '../models/create_ciclo_germinacion_dto.dart';
import '../services/ciclo_germinacion_service.dart';

class CiclosGerminacionScreen extends StatefulWidget {
  final CicloGerminacionService? service;

  const CiclosGerminacionScreen({
    super.key,
    this.service,
  });

  static const primaryGreen = Color(0xFF1E4D2B);

  @override
  State<CiclosGerminacionScreen> createState() => _CiclosGerminacionScreenState();
}

class _CiclosGerminacionScreenState extends State<CiclosGerminacionScreen> {
  late final CicloGerminacionService _service;
  final TextEditingController _searchController = TextEditingController();

  List<CicloGerminacionModel> _ciclos = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? CicloGerminacionService();
    _cargarCiclos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga la lista mediante getCiclosGerminacion() del servicio HTTP
  Future<void> _cargarCiclos() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.getCiclosGerminacion();
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
            content: Text('Error al cargar ciclos: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  /// Filtra localmente por nombre o descripción
  List<CicloGerminacionModel> get _filteredCiclos {
    if (_searchQuery.isEmpty) return _ciclos;
    return _ciclos.where((c) {
      final q = _searchQuery.toLowerCase();
      final nameMatches = c.nombre.toLowerCase().contains(q);
      final descMatches = c.descripcion?.toLowerCase().contains(q) ?? false;
      return nameMatches || descMatches;
    }).toList();
  }

  /// MODAL PARA VISUALIZAR LOS DETALLES DE AUDITORÍA
  void _showDetailsModal(CicloGerminacionModel ciclo) {
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
                            color: CiclosGerminacionScreen.primaryGreen,
                          ),
                        ),
                        Text(
                          ciclo.nombre,
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

              FutureBuilder<CicloGerminacionDetailModel?>(
                future: _service.getCicloDetails(ciclo.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: CiclosGerminacionScreen.primaryGreen,
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

  // --- MODAL PARA CREAR / EDITAR USANDO ÚNICAMENTE CreateCicloGerminacionDto EN EL BODY ---
  void _openFormModal({CicloGerminacionModel? ciclo}) {
    final isEditing = ciclo != null;

    final nombreController = TextEditingController(text: ciclo?.nombre ?? '');
    final diasMinController = TextEditingController();
    final diasMaxController = TextEditingController();
    final descController = TextEditingController(text: ciclo?.descripcion ?? '');
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
                            isEditing ? 'Editar Ciclo de Germinación' : 'Nuevo Ciclo de Germinación',
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
                          labelText: 'Nombre del ciclo',
                          prefixIcon: const Icon(Icons.eco_outlined),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa un nombre para el ciclo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: diasMinController,
                              enabled: !_isSaving,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: 'Días Mín.',
                                prefixIcon: const Icon(Icons.timer_outlined),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: diasMaxController,
                              enabled: !_isSaving,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: 'Días Máx.',
                                prefixIcon: const Icon(Icons.timer_outlined),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                            backgroundColor: CiclosGerminacionScreen.primaryGreen,
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

                              final dto = CreateCicloGerminacionDto(
                                nombre: nombreController.text.trim(),
                                diasMinimos: int.tryParse(diasMinController.text.trim()),
                                diasMaximos: int.tryParse(diasMaxController.text.trim()),
                                descripcion: descController.text.trim(),
                              );

                              try {
                                if (isEditing) {
                                  await _service.actualizarCicloGerminacion(ciclo.id, dto);
                                } else {
                                  await _service.crearCicloGerminacion(dto);
                                }

                                setModalState(() => _isSaving = false);

                                if (mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEditing
                                            ? 'Ciclo actualizado correctamente'
                                            : 'Ciclo registrado correctamente',
                                      ),
                                      backgroundColor: CiclosGerminacionScreen.primaryGreen,
                                    ),
                                  );
                                  _cargarCiclos();
                                }
                              } catch (e) {
                                setModalState(() => _isSaving = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEditing
                                            ? 'Error al actualizar ciclo: $e'
                                            : 'Error al crear ciclo: $e',
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
                            isEditing ? 'Guardar Cambios' : 'Registrar Ciclo',
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
    final list = _filteredCiclos;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: RefreshIndicator(
        onRefresh: _cargarCiclos,
        color: CiclosGerminacionScreen.primaryGreen,
        child: Column(
          children: [
            // BARRA DE BÚSQUEDA
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o descripción...',
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
                      color: CiclosGerminacionScreen.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // CARRUSEL HERO
            if (_searchQuery.isEmpty) const _HeroGerminacionCarousel(),

            // LISTADO DE CICLOS CON FRANJA LATERAL
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: CiclosGerminacionScreen.primaryGreen,
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
                            Icons.eco_outlined,
                            size: 52,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No hay ciclos registrados'
                                : 'No se encontraron resultados',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
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
                  return _CicloCardItem(
                    ciclo: item,
                    onEdit: () => _openFormModal(ciclo: item),
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
        backgroundColor: CiclosGerminacionScreen.primaryGreen,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Agregar Ciclo',
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

// --- CARRUSEL HERO ---
class _HeroGerminacionCarousel extends StatefulWidget {
  const _HeroGerminacionCarousel();

  @override
  State<_HeroGerminacionCarousel> createState() => _HeroGerminacionCarouselState();
}

class _HeroGerminacionCarouselState extends State<_HeroGerminacionCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _heroItems = const [
    {
      'title': 'Fases de Germinación',
      'subtitle': 'Monitorea el desarrollo desde la semilla hasta el brote',
      'image': 'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?auto=format&fit=crop&w=800&q=80',
      'tag': 'Cultivo Inteligente',
    },
    {
      'title': 'Bandejas y Semilleros',
      'subtitle': 'Condiciones óptimas de luz, temperatura y nutrición',
      'image': 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?auto=format&fit=crop&w=800&q=80',
      'tag': 'Técnicas',
    },
    {
      'title': 'Plántulas Fuertes',
      'subtitle': 'Asegura raíces sanas antes de la etapa de trasplante',
      'image': 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=800&q=80',
      'tag': 'Productividad',
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
                            color: CiclosGerminacionScreen.primaryGreen,
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
                    ? CiclosGerminacionScreen.primaryGreen
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

// --- TARJETA CON FRANJA VERDE LATERAL, ACCIÓN VER DETALLES Y EDITAR ---
class _CicloCardItem extends StatelessWidget {
  final CicloGerminacionModel ciclo;
  final VoidCallback onEdit;
  final VoidCallback onDetails;

  const _CicloCardItem({
    required this.ciclo,
    required this.onEdit,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final tieneDescripcion = ciclo.descripcion != null && ciclo.descripcion!.trim().isNotEmpty;

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
                color: CiclosGerminacionScreen.primaryGreen,
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
                                  ciclo.nombre,
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
                                    ciclo.descripcion!,
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
                              color: CiclosGerminacionScreen.primaryGreen,
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