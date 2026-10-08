import 'package:flutter/material.dart';

class AdminParametrosScreen extends StatelessWidget {
  const AdminParametrosScreen({super.key});

  static const primaryGreen = Color(0xFF1E4D2B);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Barra de Pestañas por Entidad / Parámetro
          Container(
            color: primaryGreen,
            child: const TabBar(
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  icon: Icon(Icons.category_outlined),
                  text: 'Categorías',
                ),
                Tab(
                  icon: Icon(Icons.nature_outlined),
                  text: 'Ciclos Germinación',
                ),
                Tab(
                  icon: Icon(Icons.flag_outlined),
                  text: 'Estados Cultivo',
                ),
              ],
            ),
          ),

          // Vistas CRUD para cada Parámetro
          const Expanded(
            child: TabBarView(
              children: [
                _EntidadCrudList(entidadNombre: 'Categoría'),
                _EntidadCrudList(entidadNombre: 'Ciclo de Germinación'),
                _EntidadCrudList(entidadNombre: 'Estado de Cultivo'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntidadCrudList extends StatelessWidget {
  final String entidadNombre;

  const _EntidadCrudList({required this.entidadNombre});

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
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.tune_rounded, color: Color(0xFF1E4D2B), size: 20),
              ),
              title: Text('$entidadNombre ${index + 1}'),
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}