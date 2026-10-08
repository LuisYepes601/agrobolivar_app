import 'package:flutter/material.dart';
// Importamos la pantalla real de Categorías
import 'package:agro_bolivar/features/categorias/screens/categorias_screen.dart';

class AdminParametrosScreen extends StatefulWidget {
  const AdminParametrosScreen({super.key});

  static const primaryGreen = Color(0xFF1E4D2B);

  @override
  State<AdminParametrosScreen> createState() => _AdminParametrosScreenState();
}

class _AdminParametrosScreenState extends State<AdminParametrosScreen> {
  int _selectedIndex = 0;

  // Lista de secciones
  final List<Map<String, dynamic>> _secciones = const [
    {
      'nombre': 'Categoría',
      'plural': 'Categorías',
      'icon': Icons.category_outlined,
      'descripcion': 'Gestión de categorías generales',
    },
    {
      'nombre': 'Ciclo de Germinación',
      'plural': 'Ciclos de Germinación',
      'icon': Icons.nature_outlined,
      'descripcion': 'Fases y etapas de germinación',
    },
    {
      'nombre': 'Estado de Cultivo',
      'plural': 'Estados de Cultivo',
      'icon': Icons.flag_outlined,
      'descripcion': 'Estatus operativo de siembras',
    },
    {
      'nombre': 'Tipo de Suelo',
      'plural': 'Tipos de Suelo',
      'icon': Icons.landscape_outlined,
      'descripcion': 'Clasificación de suelos y terrenos',
    },
    {
      'nombre': 'Unidad de Medida',
      'plural': 'Unidades de Medida',
      'icon': Icons.straighten_outlined,
      'descripcion': 'Kilos, hectáreas, litros, etc.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final seccionActual = _secciones[_selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // --- MENÚ HAMBURGUESA FLOTANTE (DRAWER) ---
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              color: AdminParametrosScreen.primaryGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.tune_rounded, color: Colors.white, size: 32),
                  SizedBox(height: 12),
                  Text(
                    'Parámetros del Sistema',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Selecciona el parámetro a gestionar',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _secciones.length,
                itemBuilder: (context, index) {
                  final item = _secciones[index];
                  final isSelected = index == _selectedIndex;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AdminParametrosScreen.primaryGreen.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? AdminParametrosScreen.primaryGreen
                            : Colors.grey.shade700,
                      ),
                      title: Text(
                        item['plural'] as String,
                        style: TextStyle(
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AdminParametrosScreen.primaryGreen
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: Text(
                        item['descripcion'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        Navigator.pop(context); // Cierra el menú flotante
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
              // --- BARRA CABECERA INTERNA CON BOTÓN HAMBURGUESA ---
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
                    // Botón para desplegar el menú flotante
                    InkWell(
                      onTap: () {
                        Scaffold.of(innerContext).openDrawer();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AdminParametrosScreen.primaryGreen
                              .withOpacity(0.1),
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

              // --- CONVIVENCIA: CATEGORÍAS REAL + PLANTILLAS ---
              Expanded(
                child: _selectedIndex == 0
                    ? const CategoriasScreen()
                    : _EntidadCrudList(
                  key: ValueKey(_selectedIndex),
                  entidadNombre: seccionActual['nombre'] as String,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Plantilla temporal para los parámetros que aún no tienen pantalla propia
class _EntidadCrudList extends StatelessWidget {
  final String entidadNombre;

  const _EntidadCrudList({
    super.key,
    required this.entidadNombre,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF1E4D2B),
                  size: 20,
                ),
              ),
              title: Text(
                '$entidadNombre ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Parámetro configurable para $entidadNombre'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E4D2B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Agregar $entidadNombre',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}