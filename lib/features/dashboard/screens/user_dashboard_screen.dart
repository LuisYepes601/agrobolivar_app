import 'package:flutter/material.dart';
import 'package:agro_bolivar/features/auth/services/auth_local_service.dart';
import 'package:agro_bolivar/features/auth/screens/login_screen.dart';
import 'package:agro_bolivar/features/dashboard/widgets/home_tab.dart';
import 'package:agro_bolivar/features/dashboard/services/dashboard_service.dart.dart';
import 'package:agro_bolivar/features/dashboard/models/user_basic_info_model.dart';
import 'package:agro_bolivar/features/cultivos/screens/admin_cultivos_list_screen.dart';
import 'package:agro_bolivar/features/cultivos/screens/cultivos_general_screen.dart';
import 'package:agro_bolivar/features/dashboard/widgets/tienda_tab.dart';
import 'package:agro_bolivar/features/plantas/screens/guia_plantas_screen.dart';
import 'package:agro_bolivar/features/perfil/screens/perfil_screen.dart';

// Módulo de Parámetros del Sistema
import 'package:agro_bolivar/features/parametros/screens/admin_parametros_screen.dart.dart';

import '../widgets/mis_productos_tab.dart';

class UserDashboardScreen extends StatefulWidget {
  final int userId;
  final String userEmail;
  final String userRole;

  const UserDashboardScreen({
    super.key,
    this.userId = 1,
    this.userEmail = 'usuario@agrobolivar.com',
    this.userRole = 'Productor',
  });

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;
  final _authLocalService = AuthLocalService();
  final _dashboardService = DashboardService();

  UserBasicInfo? _userInfo;
  bool _isLoadingUser = true;

  String get _currentAppBarTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Panel Principal';
      case 1:
        return 'Mis Productos';
      case 2:
        return 'Mis Cultivos';
      case 3:
        return 'Cultivos';
      case 4:
        return 'Guía de Plantas';
      case 5:
        return 'Tienda';
      case 6:
        return 'Parámetros del Sistema';
      default:
        return 'AgroBolívar';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final dynamic localUserId = await _authLocalService.getUserId();

      int targetUserId = widget.userId;

      if (localUserId is int) {
        targetUserId = localUserId;
      } else if (localUserId != null) {
        targetUserId = int.tryParse(localUserId.toString()) ?? widget.userId;
      }

      final info = await _dashboardService.fetchBasicUserInfo(targetUserId);

      if (mounted) {
        setState(() {
          _userInfo = info;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      debugPrint('Error obteniendo info básica del usuario: $e');
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  void _onSelectItem(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  void _navigateToPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PerfilScreen(),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    try {
      await _authLocalService.clearSession();
    } catch (e) {
      debugPrint('Error al limpiar la sesión local: $e');
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  int _getBottomNavIndex() {
    switch (_selectedIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 2;
      case 4:
        return 3;
      case 5:
        return 4;
      default:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E4D2B);

    final userName = _userInfo?.nombre ?? 'Cargando...';
    final userRole = _userInfo?.rol ?? widget.userRole;
    final photoUrl = _userInfo?.fotoPerfil;

    final bottomNavIndex = _getBottomNavIndex();
    final isBottomNavSelected = bottomNavIndex != -1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentAppBarTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              _isLoadingUser ? 'Cargando...' : 'AgroBolívar • $userRole',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _navigateToPerfil,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              onDetailsPressed: () {
                Navigator.pop(context);
                _navigateToPerfil();
              },
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E4D2B), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPerfil();
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(Icons.person, color: primaryColor, size: 40)
                      : null,
                ),
              ),
              accountName: Text(
                _isLoadingUser ? 'Cargando...' : userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                '${widget.userEmail} • $userRole',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Inicio',
                    index: 0,
                  ),
                  _buildDrawerItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Mis Productos',
                    index: 1,
                  ),
                  _buildDrawerItem(
                    icon: Icons.grass_outlined,
                    title: 'Mis Cultivos',
                    index: 2,
                  ),
                  _buildDrawerItem(
                    icon: Icons.eco_outlined,
                    title: 'Cultivos',
                    index: 3,
                  ),
                  _buildDrawerItem(
                    icon: Icons.local_florist_outlined,
                    title: 'Guía de Plantas',
                    index: 4,
                  ),
                  _buildDrawerItem(
                    icon: Icons.storefront_outlined,
                    title: 'Tienda',
                    index: 5,
                  ),
                  // ⚙️ SECCIÓN PARÁMETROS DEL SISTEMA
                  _buildDrawerItem(
                    icon: Icons.tune_rounded,
                    title: 'Parámetros',
                    index: 6,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: primaryColor),
                    title: const Text(
                      'Mi Perfil',
                      style: TextStyle(color: Color(0xFF1E293B)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToPerfil();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.red.shade50,
                leading: Icon(Icons.logout_rounded, color: Colors.red.shade700),
                title: Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _handleLogout(context),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeTab(
            onSelectTab: (index) {
              setState(() => _selectedIndex = index);
            },
          ),
          const MisProductosTab(),
          const AdminCultivosListScreen(isTab: true),
          const CultivosGeneralScreen(isTab: true),
          const GuiaPlantasScreen(),
          const TiendaTab(),
          const AdminParametrosScreen(), // Pantalla de Parámetros
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: isBottomNavSelected ? bottomNavIndex : 0,
        selectedItemColor: isBottomNavSelected ? primaryColor : Colors.grey,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedIconTheme: IconThemeData(
          color: isBottomNavSelected ? primaryColor : Colors.grey,
        ),
        selectedLabelStyle: TextStyle(
          fontWeight: isBottomNavSelected ? FontWeight.bold : FontWeight.normal,
          color: isBottomNavSelected ? primaryColor : Colors.grey,
        ),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              setState(() => _selectedIndex = 0);
              break;
            case 1:
              setState(() => _selectedIndex = 1);
              break;
            case 2:
              setState(() => _selectedIndex = 2);
              break;
            case 3:
              setState(() => _selectedIndex = 4);
              break;
            case 4:
              setState(() => _selectedIndex = 5);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'Mis Cultivos'),
          BottomNavigationBarItem(icon: Icon(Icons.local_florist_outlined), label: 'Guía Plantas'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Tienda'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    const primaryColor = Color(0xFF1E4D2B);
    final isSelected = _selectedIndex == index;

    return ListTile(
      selected: isSelected,
      selectedTileColor: primaryColor.withOpacity(0.08),
      leading: Icon(icon, color: isSelected ? primaryColor : Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? primaryColor : const Color(0xFF1E293B),
        ),
      ),
      onTap: () => _onSelectItem(index),
    );
  }
}