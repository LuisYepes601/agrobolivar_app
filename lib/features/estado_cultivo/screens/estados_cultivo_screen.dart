import 'dart:async';
import 'package:agro_bolivar/features/estado_cultivo/models/create_estado_cultivo_model.dart';
import 'package:agro_bolivar/features/estado_cultivo/models/estado_cultivo_model.dart';
import 'package:agro_bolivar/features/estado_cultivo/screens/estado_details_screen.dart';
import 'package:agro_bolivar/features/estado_cultivo/services/estado_cultivo_service.dart';
import 'package:flutter/material.dart';

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

  List<EstadoCultivo> _estados = [];
  bool _isLoading = false;
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
      final result = await _service.fetchEstadoCultivosList();
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
  List<EstadoCultivo> get _filteredEstados {
    if (_searchQuery.isEmpty) return _estados;
    return _estados.where((e) {
      final q = _searchQuery.toLowerCase();
      final nameMatches = e.nombre.toLowerCase().contains(q);
      final descMatches = e.descripcion?.toLowerCase().contains(q) ?? false;
      return nameMatches || descMatches;
    }).toList();
  }

  /// Abre el modal desplegable para Crear (si estado == null) o Editar
  void _mostrarModalFormulario([EstadoCultivo? estado]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EstadoCultivoFormModal(
        service: _service,
        estado: estado,
        onSuccess: _cargarEstados,
      ),
    );
  }

  /// Navega a la pantalla de detalle y auditoría
  void _verDetalles(EstadoCultivo estado) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EstadoDetailsScreen(
          estadoId: estado.id,
          estado: estado,
          service: _service,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredEstados;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarModalFormulario(),
        backgroundColor: EstadosCultivoScreen.primaryGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nuevo Estado',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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

            // CARRUSEL HERO (Solo visible si no se está buscando)
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _EstadoCardItem(
                    estado: item,
                    onEdit: () => _mostrarModalFormulario(item),
                    onViewDetails: () => _verDetalles(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MODAL REUTILIZABLE PARA CREAR Y EDITAR ESTADOS ---
class _EstadoCultivoFormModal extends StatefulWidget {
  final EstadoCultivoService service;
  final EstadoCultivo? estado;
  final VoidCallback onSuccess;

  const _EstadoCultivoFormModal({
    required this.service,
    this.estado,
    required this.onSuccess,
  });

  @override
  State<_EstadoCultivoFormModal> createState() => _EstadoCultivoFormModalState();
}

class _EstadoCultivoFormModalState extends State<_EstadoCultivoFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  bool _isSaving = false;

  bool get _isEditing => widget.estado != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.estado?.nombre ?? '');
    _descripcionController = TextEditingController(text: widget.estado?.descripcion ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final payload = CreateEstadoCultivoModel(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isNotEmpty
            ? _descripcionController.text.trim()
            : null,
      );

      if (_isEditing) {
        await widget.service.updateEstadoCultivo(widget.estado!.id, payload);
      } else {
        await widget.service.createEstadoCultivo(payload);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Estado de cultivo actualizado exitosamente'
                  : 'Estado de cultivo creado exitosamente',
            ),
            backgroundColor: EstadosCultivoScreen.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al ${_isEditing ? "actualizar" : "crear"} estado: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Editar Estado de Cultivo' : 'Nuevo Estado de Cultivo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // CAMPO NOMBRE
              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Nombre *',
                  hintText: 'Ej. MENSUAL, GERMINACIÓN...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: EstadosCultivoScreen.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CAMPO DESCRIPCIÓN
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  hintText: 'Ej. Ciclo de producción aproximado de un mes',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: EstadosCultivoScreen.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // BOTÓN GUARDAR / ACTUALIZAR
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EstadosCultivoScreen.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    _isEditing ? 'Actualizar Estado' : 'Guardar Estado',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
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

// --- TARJETA DE ESTADO CON OPCIONES DE VER DETALLES Y EDICIÓN ---
class _EstadoCardItem extends StatelessWidget {
  final EstadoCultivo estado;
  final VoidCallback onEdit;
  final VoidCallback onViewDetails;

  const _EstadoCardItem({
    required this.estado,
    required this.onEdit,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final tieneDescripcion =
        estado.descripcion != null && estado.descripcion!.trim().isNotEmpty;

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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onViewDetails,
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
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
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // BOTÓN AUDITORÍA / DETALLES
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: onViewDetails,
                    tooltip: 'Ver Detalles y Auditoría',
                  ),

                  // BOTÓN EDITAR
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: EstadosCultivoScreen.primaryGreen,
                      size: 20,
                    ),
                    onPressed: onEdit,
                    tooltip: 'Editar Estado',
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}