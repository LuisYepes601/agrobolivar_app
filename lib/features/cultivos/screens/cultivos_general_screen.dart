import 'package:flutter/material.dart';

import 'package:agro_bolivar/features/cultivos/models/cultivo_admin_model.dart';
import 'package:agro_bolivar/features/cultivos/services/cultivo_api_service.dart';
import 'package:agro_bolivar/features/cultivos/screens/admin_cultivo_detail_screen.dart';

class CultivosGeneralScreen extends StatefulWidget {
  final bool isTab;

  const CultivosGeneralScreen({
    super.key,
    this.isTab = false,
  });

  @override
  State<CultivosGeneralScreen> createState() => _CultivosGeneralScreenState();
}

class _CultivosGeneralScreenState extends State<CultivosGeneralScreen> {
  static const primaryGreen = Color(0xFF1E4D2B);
  static const tagTextAccent = Color(0xFF059669);
  static const backgroundColor = Color(0xFFF8FAFC);
  static const textColorDark = Color(0xFF0F172A);
  static const textColorMuted = Color(0xFF64748B);
  static const borderColor = Color(0xFFE2E8F0);
  static const dividerColor = Color(0xFFF1F5F9);

  final CultivoApiService _cultivoService = CultivoApiService();
  final TextEditingController _searchController = TextEditingController();

  List<CultivoAdminModel> _cultivos = [];
  List<CultivoAdminModel> _filteredCultivos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCultivos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCultivos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Se utiliza el nuevo método para la vista general sin filtrar id_usuario
      final response = await _cultivoService.getCultivosGeneral();

      if (mounted) {
        setState(() {
          _cultivos = response;
          _filteredCultivos = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _filterCultivos(String query) {
    if (query.isEmpty) {
      setState(() => _filteredCultivos = _cultivos);
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredCultivos = _cultivos.where((item) {
        final nombre = item.nombre.toLowerCase();
        final email = (item.email ?? '').toLowerCase();
        final telefono = (item.telefono ?? '').toLowerCase();
        final estado = item.estado.toLowerCase();

        return nombre.contains(lowerQuery) ||
            email.contains(lowerQuery) ||
            telefono.contains(lowerQuery) ||
            estado.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: widget.isTab
          ? null
          : AppBar(
        title: const Text(
          'Cultivos en AgroBolívar',
          style: TextStyle(
            color: textColorDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColorDark),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCultivos,
        color: primaryGreen,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterCultivos,
                  style: const TextStyle(fontSize: 14, color: textColorDark),
                  decoration: const InputDecoration(
                    hintText: 'Buscar cultivos en AgroBolívar...',
                    hintStyle: TextStyle(color: textColorMuted, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: textColorMuted, size: 20),
                    suffixIcon: Icon(Icons.tune_rounded, color: textColorMuted, size: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ),
            ),

            Expanded(
              child: _buildBodyContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGreen, strokeWidth: 2.5),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: textColorMuted),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textColorMuted, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _fetchCultivos,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
                style: TextButton.styleFrom(foregroundColor: primaryGreen),
              )
            ],
          ),
        ),
      );
    }

    if (_filteredCultivos.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.eco_outlined, size: 48, color: textColorMuted),
                const SizedBox(height: 16),
                const Text(
                  'No hay cultivos disponibles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColorDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _searchController.text.isNotEmpty
                      ? 'No se encontraron resultados para la búsqueda.'
                      : 'Próximamente habrá nuevos cultivos promocionados.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: textColorMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CULTIVOS DISPONIBLES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColorMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${_filteredCultivos.length} encontrados',
                style: const TextStyle(
                  fontSize: 11,
                  color: textColorMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        ..._filteredCultivos.map((cultivo) => _buildCultivoCard(cultivo)),
      ],
    );
  }

  Widget _buildCultivoCard(CultivoAdminModel cultivo) {
    final hasFoto = cultivo.urlFoto != null && cultivo.urlFoto!.isNotEmpty;
    final hasTelefono = cultivo.telefono != null && cultivo.telefono!.isNotEmpty;
    final hasEmail = cultivo.email != null && cultivo.email!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminCultivoDetailScreen(
                  cultivo: cultivo,
                  esEditable: false,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 105,
                      width: double.infinity,
                      color: const Color(0xFFF1F5F9),
                      child: hasFoto
                          ? Image.network(
                        cultivo.urlFoto!,
                        fit: BoxFit.cover,
                      )
                          : const Center(
                        child: Icon(
                          Icons.eco_outlined,
                          color: textColorMuted,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _buildFloatingTag(
                      label: 'AGRÍCOLA',
                      bgColor: Colors.white.withOpacity(0.92),
                      textColor: tagTextAccent,
                    ),
                  ),
                  if (cultivo.estado.isNotEmpty)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _buildFloatingTag(
                        label: cultivo.estado.toUpperCase(),
                        bgColor: Colors.black.withOpacity(0.65),
                        textColor: Colors.white,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            cultivo.nombre.isNotEmpty ? cultivo.nombre : 'Sin nombre',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColorDark,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$${cultivo.precioPorKg.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: primaryGreen,
                                ),
                              ),
                              const TextSpan(
                                text: ' / kg',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: textColorMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (hasTelefono || hasEmail) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: dividerColor),
                      ),
                      Row(
                        children: [
                          if (hasTelefono) ...[
                            const Icon(Icons.phone_outlined, size: 12, color: textColorMuted),
                            const SizedBox(width: 5),
                            Text(
                              cultivo.telefono!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textColorMuted,
                              ),
                            ),
                          ],
                          if (hasTelefono && hasEmail)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11)),
                            ),
                          if (hasEmail) ...[
                            const Icon(Icons.mail_outline_rounded, size: 12, color: textColorMuted),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                cultivo.email!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: textColorMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingTag({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}