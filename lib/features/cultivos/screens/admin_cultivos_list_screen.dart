import 'dart:async';
import 'package:flutter/material.dart';

import 'package:agro_bolivar/features/cultivos/models/cultivo_admin_model.dart';
import 'package:agro_bolivar/features/cultivos/services/cultivo_api_service.dart';
import 'package:agro_bolivar/features/cultivos/screens/admin_cultivo_create_screen.dart';
import 'package:agro_bolivar/features/cultivos/screens/admin_cultivo_detail_screen.dart';

class AdminCultivosListScreen extends StatefulWidget {
  final bool isTab;

  const AdminCultivosListScreen({
    super.key,
    this.isTab = false,
  });

  @override
  State<AdminCultivosListScreen> createState() => _AdminCultivosListScreenState();
}

class _AdminCultivosListScreenState extends State<AdminCultivosListScreen> {
  static const primaryGreen = Color(0xFF1E4D2B);
  static const tagBgAccent = Color(0xFFECFDF5);
  static const tagTextAccent = Color(0xFF059669);
  static const backgroundColor = Color(0xFFF8FAFC);
  static const textColorDark = Color(0xFF0F172A);
  static const textColorMuted = Color(0xFF64748B);
  static const borderColor = Color(0xFFE2E8F0);
  static const dividerColor = Color(0xFFF1F5F9);

  final CultivoApiService _cultivoService = CultivoApiService();
  final TextEditingController _searchController = TextEditingController();

  late PageController _heroPageController;
  int _currentHeroPage = 0;
  Timer? _heroTimer;

  final List<Map<String, String>> _heroItems = [
    {
      'title': 'Gestión de Cosecha',
      'subtitle': 'Optimiza los tiempos de siembra y recolección para maximizar tu rendimiento agrícola.',
      'tag': 'Técnica',
      'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Rotación de Cultivos',
      'subtitle': 'Mejora la salud del suelo y previene plagas alternando especies en tus lotes.',
      'tag': 'Sostenibilidad',
      'image': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Riego Eficiente',
      'subtitle': 'Aplica el agua y fertilizantes exactos según la etapa fenológica del cultivo.',
      'tag': 'Tecnología',
      'image': 'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': 'Comercialización Directa',
      'subtitle': 'Establece precios competitivos y conecta directamente con el mercado regional.',
      'tag': 'Mercado',
      'image': 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=800&auto=format&fit=crop&q=80',
    },
  ];

  List<CultivoAdminModel> _cultivos = [];
  List<CultivoAdminModel> _filteredCultivos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _heroPageController = PageController(viewportFraction: 0.92);
    _startHeroAutoScroll();
    _fetchCultivos();
  }

  void _startHeroAutoScroll() {
    _heroTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_heroPageController.hasClients) {
        _currentHeroPage = (_currentHeroPage + 1) % _heroItems.length;
        _heroPageController.animateToPage(
          _currentHeroPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCultivos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _cultivoService.getCultivosAdmin();

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

  Future<void> _navigateToCreate() async {
    final bool? created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminCultivoCreateScreen(),
      ),
    );

    if (created == true && mounted) {
      _fetchCultivos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: widget.isTab
          ? null
          : AppBar(
        title: const Text(
          'Mis Cultivos',
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        backgroundColor: primaryGreen,
        elevation: 2,
        highlightElevation: 0,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCultivos,
        color: primaryGreen,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // Buscador
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                    hintText: 'Buscar cultivo...',
                    hintStyle: TextStyle(color: textColorMuted, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: textColorMuted, size: 20),
                    suffixIcon: Icon(Icons.tune_rounded, color: textColorMuted, size: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ),
            ),

            // Carrusel Hero Banner
            _buildHeroCarousel(),

            Expanded(
              child: _buildBodyContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 155,
          child: PageView.builder(
            controller: _heroPageController,
            onPageChanged: (index) {
              setState(() {
                _currentHeroPage = index;
              });
            },
            itemCount: _heroItems.length,
            itemBuilder: (context, index) {
              final item = _heroItems[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      Image.network(
                        item['image']!,
                        height: 155,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        headers: const {'User-Agent': 'Mozilla/5.0'},
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: primaryGreen.withOpacity(0.1),
                            child: const Center(
                              child: Icon(Icons.eco_rounded, size: 48, color: primaryGreen),
                            ),
                          );
                        },
                      ),
                      Container(
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
                      Positioned(
                        top: 12,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item['tag']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 14,
                        right: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item['subtitle']!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
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
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_heroItems.length, (index) {
            final isSelected = _currentHeroPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 5,
              width: isSelected ? 18 : 5,
              decoration: BoxDecoration(
                color: isSelected ? primaryGreen : primaryGreen.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
      ],
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
                  'Sin cultivos registrados',
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
                      : 'Agrega un cultivo para comenzar.',
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LISTADO DE CULTIVOS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColorMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${_filteredCultivos.length} registrados',
                style: const TextStyle(
                  fontSize: 11,
                  color: textColorMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Cards de Cultivos Estructuradas por Secciones
        ..._filteredCultivos.map((cultivo) => _buildCultivoCard(cultivo)),
      ],
    );
  }

  Widget _buildCultivoCard(CultivoAdminModel cultivo) {
    final hasFoto = cultivo.urlFoto != null && cultivo.urlFoto!.isNotEmpty;
    final hasTelefono = cultivo.telefono != null && cultivo.telefono!.isNotEmpty;
    final hasEmail = cultivo.email != null && cultivo.email!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                builder: (context) => AdminCultivoDetailScreen(cultivo: cultivo),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. MINIATURA
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 95,
                    height: 110,
                    color: const Color(0xFFF1F5F9),
                    child: hasFoto
                        ? Image.network(
                      cultivo.urlFoto!,
                      fit: BoxFit.cover,
                      headers: const {'User-Agent': 'Mozilla/5.0'},
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.eco_outlined, color: textColorMuted, size: 32),
                    )
                        : const Icon(Icons.eco_outlined, color: textColorMuted, size: 32),
                  ),
                ),
                const SizedBox(width: 14),

                // 2. COLUMNA ORGANIZADA EN SECCIONES
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- SECCIÓN 1: TÍTULO Y ESTADO ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          if (cultivo.estado.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _buildFloatingTag(
                              label: cultivo.estado.toUpperCase(),
                              bgColor: const Color(0xFFF1F5F9),
                              textColor: textColorMuted,
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 6),
                      const Divider(height: 1, thickness: 1, color: dividerColor),
                      const SizedBox(height: 8),

                      // --- SECCIÓN 2: TIPO Y PRECIO ---
                      Row(
                        children: [
                          _buildFloatingTag(
                            label: 'AGRÍCOLA',
                            bgColor: tagBgAccent,
                            textColor: tagTextAccent,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: primaryGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '\$${cultivo.precioPorKg.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' / kg',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: textColorMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // --- SECCIÓN 3: CONTACTO ---
                      if (hasTelefono || hasEmail) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasTelefono)
                                Padding(
                                  padding: EdgeInsets.only(bottom: hasEmail ? 3.0 : 0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, size: 12, color: textColorMuted),
                                      const SizedBox(width: 6),
                                      Text(
                                        cultivo.telefono!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: textColorDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (hasEmail)
                                Row(
                                  children: [
                                    const Icon(Icons.mail_outline_rounded, size: 12, color: textColorMuted),
                                    const SizedBox(width: 6),
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
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
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