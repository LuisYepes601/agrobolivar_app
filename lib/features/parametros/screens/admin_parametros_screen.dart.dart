import 'package:flutter/material.dart';
// Importación de pantallas reales
import 'package:agro_bolivar/features/categorias/screens/categorias_screen.dart';
import 'package:agro_bolivar/features/ciclo_germinacion/screens/ciclos_germinacion_screen.dart';
import 'package:agro_bolivar/features/estado_cultivo/screens/estados_cultivo_screen.dart';
import 'package:agro_bolivar/features/unidades_area/screens/unidad_area_screen.dart';
import 'package:agro_bolivar/features/unidades_peso/screens/unidades_peso_screen.dart';
import 'package:agro_bolivar/features/tipo_planta/screens/tipo_planta_screen.dart';
import 'package:agro_bolivar/features/tipo_documento/screens/tipo_documento_screen.dart';
import 'package:agro_bolivar/features/rol/screens/roles_screen.dart';
import 'package:agro_bolivar/features/marcas/screens/marcas_screen.dart';
import 'package:agro_bolivar/features/genero_planta/screens/genero_planta_screen.dart';
import 'package:agro_bolivar/features/familia_planta/screens/familia_planta_screen.dart';
import 'package:agro_bolivar/features/estaciones/screens/estaciones_cultivo_screen.dart';
import 'package:agro_bolivar/features/especie_planta/screens/especies_planta_screen.dart';
import 'package:agro_bolivar/features/ciclo_produccion/screens/ciclos_produccion_screen.dart';

class AdminParametrosScreen extends StatefulWidget {
  const AdminParametrosScreen({super.key});

  static const primaryGreen = Color(0xFF1E4D2B);

  @override
  State<AdminParametrosScreen> createState() => _AdminParametrosScreenState();
}

class _AdminParametrosScreenState extends State<AdminParametrosScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _secciones = const [
    {
      'nombre': 'Categoría',
      'plural': 'Categorías',
      'icon': Icons.category_outlined,
    },
    {
      'nombre': 'Ciclo de Germinación',
      'plural': 'Ciclos de Germinación',
      'icon': Icons.nature_outlined,
    },
    {
      'nombre': 'Estado de Cultivo',
      'plural': 'Estados de Cultivo',
      'icon': Icons.flag_outlined,
    },
    {
      'nombre': 'Unidad de Área',
      'plural': 'Unidades de Área',
      'icon': Icons.square_foot_outlined,
    },
    {
      'nombre': 'Unidad de Peso',
      'plural': 'Unidades de Peso',
      'icon': Icons.scale_outlined,
    },
    {
      'nombre': 'Tipo de Planta',
      'plural': 'Tipos de Planta',
      'icon': Icons.eco_outlined,
    },
    {
      'nombre': 'Tipo de Documento',
      'plural': 'Tipos de Documento',
      'icon': Icons.badge_outlined,
    },
    {
      'nombre': 'Rol',
      'plural': 'Roles',
      'icon': Icons.admin_panel_settings_outlined,
    },
    {
      'nombre': 'Marca',
      'plural': 'Marcas',
      'icon': Icons.sell_outlined,
    },
    {
      'nombre': 'Género de Planta',
      'plural': 'Géneros de Planta',
      'icon': Icons.park_outlined,
    },
    {
      'nombre': 'Familia de Planta',
      'plural': 'Familias de Planta',
      'icon': Icons.local_florist_outlined,
    },
    {
      'nombre': 'Estación de Cultivo',
      'plural': 'Estaciones de Cultivo',
      'icon': Icons.wb_sunny_outlined,
    },
    {
      'nombre': 'Especie de Planta',
      'plural': 'Especies de Planta',
      'icon': Icons.grass_outlined,
    },
    {
      'nombre': 'Ciclo de Producción',
      'plural': 'Ciclos de Producción',
      'icon': Icons.sync_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final seccionActual = _secciones[_selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // --- MENÚ HAMBURGUESA FLOTANTE (DRAWER MINIMALISTA) ---
      drawer: Drawer(
        width: 270,
        child: Column(
          children: [
            // Header compacto
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
              color: AdminParametrosScreen.primaryGreen,
              child: Row(
                children: const [
                  Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Parámetros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de opciones estilo Mercado Libre
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                itemCount: _secciones.length,
                itemBuilder: (context, index) {
                  final item = _secciones[index];
                  final isSelected = index == _selectedIndex;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AdminParametrosScreen.primaryGreen.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      leading: Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: isSelected
                            ? AdminParametrosScreen.primaryGreen
                            : const Color(0xFF555555),
                      ),
                      title: Text(
                        item['plural'] as String,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AdminParametrosScreen.primaryGreen
                              : const Color(0xFF222222),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AdminParametrosScreen.primaryGreen,
                      )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Builder(
        builder: (innerContext) {
          return Column(
            children: [
              // --- BARRA CABECERA INTERNA ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Scaffold.of(innerContext).openDrawer();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AdminParametrosScreen.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: AdminParametrosScreen.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seccionActual['plural'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Text(
                            'Toca el menú para cambiar de parámetro',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        seccionActual['icon'] as IconData,
                        size: 18,
                        color: AdminParametrosScreen.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),

              // --- RUTEO SEGÚN LA OPCIÓN SELECCIONADA ---
              Expanded(
                child: _buildPantallaActual(seccionActual['nombre'] as String),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPantallaActual(String nombreEntidad) {
    switch (_selectedIndex) {
      case 0:
        return const CategoriasScreen();
      case 1:
        return const CiclosGerminacionScreen();
      case 2:
        return const EstadosCultivoScreen();
      case 3:
        return const UnidadesAreaScreen();
      case 4:
        return const UnidadesPesoScreen();
      case 5:
        return const TiposPlantaScreen();
      case 6:
        return const TipoDocumentoScreen();
      case 7:
        return const RolesScreen();
      case 8:
        return const MarcasScreen();
      case 9:
        return const GenerosPlantaScreen();
      case 10:
        return const FamiliasPlantaScreen();
      case 11:
        return const EstacionesCultivoScreen();
      case 12:
        return const EspeciesPlantaScreen();
      case 13:
        return const CiclosProduccionScreen();
      default:
        return _ModuloEnConstruccion(entidadNombre: nombreEntidad);
    }
  }
}

class _ModuloEnConstruccion extends StatelessWidget {
  final String entidadNombre;

  const _ModuloEnConstruccion({required this.entidadNombre});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 52,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Gestión de $entidadNombre',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Próximamente disponible',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}