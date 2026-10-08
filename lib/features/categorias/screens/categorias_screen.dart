import 'package:flutter/material.dart';
import 'package:agro_bolivar/features/categorias/models/categoria_model.dart';
import 'package:agro_bolivar/features/categorias/services/categoria_service.dart';

class CategoriasScreen extends StatefulWidget {
  final List<Categoria>? categorias;
  final CategoriaService? categoriaService;
  final Function(String nombre, String? descripcion)? onAgregar;
  final Function(Categoria categoria, String nombre, String? descripcion)? onEditar;
  final Function(Categoria categoria)? onEliminar;

  const CategoriasScreen({
    super.key,
    this.categorias,
    this.categoriaService,
    this.onAgregar,
    this.onEditar,
    this.onEliminar,
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
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final nombre = nombreController.text.trim();
                        final desc = descController.text.trim().isEmpty
                            ? null
                            : descController.text.trim();

                        if (isEditing) {
                          widget.onEditar?.call(categoria, nombre, desc);
                        } else {
                          widget.onAgregar?.call(nombre, desc);
                        }
                        Navigator.pop(ctx);
                        _cargarCategorias();
                      }
                    },
                    child: Text(
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
  }

  // --- DIÁLOGO DE CONFIRMACIÓN DE ELIMINACIÓN ---
  void _confirmDelete(Categoria categoria) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar Categoría?'),
        content: Text(
          '¿Estás seguro de eliminar "${categoria.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              widget.onEliminar?.call(categoria);
              Navigator.pop(ctx);
              _cargarCategorias();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
            // BUSCADOR TIPO WHATSAPP / IOS (Limpio y redondeado)
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
                  fillColor: const Color(0xFFF1F5F9), // Gris neutro muy suave
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
                    onDelete: () => _confirmDelete(item),
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

// --- TARJETA CON ESTILO MERCADO LIBRE / WHATSAPP (SUAVE & MINIMALISTA) ---
class _CategoriaCardItem extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoriaCardItem({
    required this.categoria,
    required this.onEdit,
    required this.onDelete,
  });

  // Extrae solo la PRIMERA inicial del nombre (ej. "Granos y Cereales" -> "G")
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
        borderRadius: BorderRadius.circular(16), // Redondeado de 16px
        border: Border.all(color: const Color(0xFFF1F5F9)), // Borde ultra tenue
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4), // Sombra flotante suave
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
                // BADGE CIRCULAR CON ÚNICA INICIAL
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9), // Verde pastel suave
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

                // TEXTO CONTENIDO (Nombre + Descripción)
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

                // MENÚ DE OPCIONES DE TRES PUNTOS (...)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                          SizedBox(width: 10),
                          Text('Editar', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Eliminar', style: TextStyle(fontSize: 13, color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}