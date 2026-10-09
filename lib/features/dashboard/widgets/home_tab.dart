// lib/features/dashboard/widgets/home_tab.dart

import 'dart:async';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  final Function(int)? onSelectTab;
  final String userRole;

  const HomeTab({
    super.key,
    this.onSelectTab,
    this.userRole = 'Productor',
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  // Lista de 5 imágenes del carrusel Hero principal
  final List<Map<String, String>> _carouselItems = [
    {
      'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1000&auto=format&fit=crop',
      'title': '¡Bienvenido al Campo!',
      'subtitle': 'Gestiona tus cultivos, tareas y suelo desde un solo lugar.',
    },
    {
      'image': 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?q=80&w=1000&auto=format&fit=crop',
      'title': 'Monitoreo Inteligente',
      'subtitle': 'Consulta el estado de tus lotes y detecta alertas a tiempo.',
    },
    {
      'image': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?q=80&w=1000&auto=format&fit=crop',
      'title': 'Optimiza tus Cosechas',
      'subtitle': 'Lleva el control detallado de tus labores y actividades diarias.',
    },
    {
      'image': 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=1000&auto=format&fit=crop',
      'title': 'Prácticas Sostenibles',
      'subtitle': 'Cuida tus recursos naturales y mejora la salud de tu suelo.',
    },
    {
      'image': 'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?q=80&w=1000&auto=format&fit=crop',
      'title': 'Gestión de Insumos',
      'subtitle': 'Lleva el control de tus fertilizantes, semillas y herramientas.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _carouselItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
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
    // Validación del rol de usuario
    final cleanRole = widget.userRole.toUpperCase().replaceAll('ROLE_', '').trim();
    final isUsuario = cleanRole == 'USUARIO' || cleanRole == 'USER';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CARRUSEL HERO ---
          _buildHeroCarousel(),

          const SizedBox(height: 24),

          // --- SECCIÓN ACCESOS RÁPIDOS / SECCIONES ---
          const Text(
            'Explorar Secciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),

          // --- MASONRY GRID (ESTILO PINTEREST CON 2 COLUMNAS) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna Izquierda
              Expanded(
                child: Column(
                  children: [
                    if (isUsuario) ...[
                      // Para 'USUARIO' mostramos la tarjeta general de 'Cultivos'
                      _SpotifyCarouselCard(
                        title: 'Cultivos',
                        badgeText: 'Catálogo',
                        icon: Icons.eco_outlined,
                        height: 200,
                        autoScrollSeconds: 3,
                        images: const [
                          'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?q=80&w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1574943320219-553eb213f72d?q=80&w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?q=80&w=600&auto=format&fit=crop',
                        ],
                        onTap: () => widget.onSelectTab?.call(3),
                      ),
                      const SizedBox(height: 14),
                    ] else ...[
                      // Muestra 'Mis Cultivos' si NO es usuario simple
                      _SpotifyCarouselCard(
                        title: 'Mis Cultivos',
                        badgeText: '4 Lotes',
                        icon: Icons.grass,
                        height: 220,
                        autoScrollSeconds: 3,
                        images: const [
                          'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?q=80&w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1574943320219-553eb213f72d?q=80&w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?q=80&w=600&auto=format&fit=crop',
                        ],
                        onTap: () => widget.onSelectTab?.call(2),
                      ),
                      const SizedBox(height: 14),
                    ],

                    _SpotifyCarouselCard(
                      title: 'Guía Plantas',
                      badgeText: 'Diagnóstico',
                      icon: Icons.local_florist_outlined,
                      height: 170,
                      autoScrollSeconds: 5,
                      images: const [
                        'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=600&auto=format&fit=crop',
                        'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?q=80&w=600&auto=format&fit=crop',
                        'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?q=80&w=600&auto=format&fit=crop',
                      ],
                      onTap: () => widget.onSelectTab?.call(4),
                    ),

                    // Muestra 'Parámetros' únicamente si NO es 'USUARIO'
                    if (!isUsuario) ...[
                      const SizedBox(height: 14),
                      _SpotifyCarouselCard(
                        title: 'Parámetros',
                        badgeText: 'Configuración',
                        icon: Icons.tune_rounded,
                        height: 180,
                        autoScrollSeconds: 4,
                        images: const [
                          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=600&auto=format&fit=crop',
                        ],
                        onTap: () => widget.onSelectTab?.call(6),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Columna Derecha
              Expanded(
                child: Column(
                  children: [
                    // Muestra 'Mis Productos' únicamente si NO es 'USUARIO'
                    if (!isUsuario) ...[
                      _SpotifyCarouselCard(
                        title: 'Mis Productos',
                        badgeText: 'Catálogo',
                        icon: Icons.shopping_bag_outlined,
                        height: 170,
                        autoScrollSeconds: 4,
                        images: const [
                          'https://images.unsplash.com/photo-1615811361523-6bd03d7748e7?q=80&w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=600&auto=format&fit=crop',
                          'https://images.unsplash.com/photo-1588964895597-cfccd6e2dbf9?q=80&w=600&auto=format&fit=crop',
                        ],
                        onTap: () => widget.onSelectTab?.call(1),
                      ),
                      const SizedBox(height: 14),
                    ],

                    _SpotifyCarouselCard(
                      title: 'Tienda Agro',
                      badgeText: 'Insumos',
                      height: isUsuario ? 280 : 230,
                      icon: Icons.storefront_outlined,
                      autoScrollSeconds: 3,
                      images: const [
                        'https://images.unsplash.com/photo-1589923188900-85dae523342b?q=80&w=600&auto=format&fit=crop',
                        'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?q=80&w=600&auto=format&fit=crop',
                        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=600&auto=format&fit=crop',
                      ],
                      onTap: () => widget.onSelectTab?.call(5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Carrusel Hero de Inicio
  Widget _buildHeroCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _carouselItems.length,
            itemBuilder: (context, index) {
              final item = _carouselItems[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(item['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.80),
                        Colors.black.withOpacity(0.20),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['subtitle']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _carouselItems.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF1E4D2B)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget independiente para cada tarjeta con su propio mini carrusel automático y altura dinámica
class _SpotifyCarouselCard extends StatefulWidget {
  final String title;
  final String badgeText;
  final List<String> images;
  final IconData icon;
  final VoidCallback onTap;
  final double height;
  final int autoScrollSeconds;

  const _SpotifyCarouselCard({
    required this.title,
    required this.badgeText,
    required this.images,
    required this.icon,
    required this.onTap,
    this.height = 180,
    this.autoScrollSeconds = 3,
  });

  @override
  State<_SpotifyCarouselCard> createState() => _SpotifyCarouselCardState();
}

class _SpotifyCarouselCardState extends State<_SpotifyCarouselCard> {
  late final PageController _cardPageController;
  int _currentImageIndex = 0;
  Timer? _cardTimer;

  @override
  void initState() {
    super.initState();
    _cardPageController = PageController();
    _startCardAutoScroll();
  }

  void _startCardAutoScroll() {
    _cardTimer = Timer.periodic(
      Duration(seconds: widget.autoScrollSeconds),
          (timer) {
        if (_cardPageController.hasClients && widget.images.isNotEmpty) {
          _currentImageIndex = (_currentImageIndex + 1) % widget.images.length;
          _cardPageController.animateToPage(
            _currentImageIndex,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _cardTimer?.cancel();
    _cardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
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
            PageView.builder(
              controller: _cardPageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.30),
                    Colors.black.withOpacity(0.10),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Text(
                        widget.badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E4D2B),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white70,
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  splashColor: Colors.white24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}