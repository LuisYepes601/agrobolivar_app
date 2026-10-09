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

  List<TipoDocumentoModel> _tiposDocumento = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TipoDocumentoApiService();
    _cargarTiposDocumento();
  }

  @override
  void dispose() {
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

  /// Filtrado local por nombre
  List<TipoDocumentoModel> get _filteredTiposDocumento {
    if (_searchQuery.isEmpty) return _tiposDocumento;
    return _tiposDocumento.where((item) {
      final q = _searchQuery.toLowerCase();
      return item.nombre.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredTiposDocumento;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: _cargarTiposDocumento,
        color: TipoDocumentoScreen.primaryGreen,
        child: Column(
          children: [
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
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: TipoDocumentoScreen.primaryGreen,
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
                  ),
                ],
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _TipoDocumentoCardItem(tipoDocumento: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TARJETA DE TIPO DE DOCUMENTO ---
class _TipoDocumentoCardItem extends StatelessWidget {
  final TipoDocumentoModel tipoDocumento;

  const _TipoDocumentoCardItem({required this.tipoDocumento});

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              tipoDocumento.nombre,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}