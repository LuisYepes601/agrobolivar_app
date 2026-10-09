import 'package:flutter/material.dart';
import 'package:agro_bolivar/features/estado_cultivo/models/estado_cultivo_details_model.dart';
import 'package:agro_bolivar/features/estado_cultivo/models/estado_cultivo_model.dart';
import 'package:agro_bolivar/features/estado_cultivo/services/estado_cultivo_service.dart';

class EstadoDetailsScreen extends StatefulWidget {
  final int estadoId;
  final EstadoCultivo? estado;
  final EstadoCultivoService? service;

  const EstadoDetailsScreen({
    super.key,
    required this.estadoId,
    this.estado,
    this.service,
  });

  @override
  State<EstadoDetailsScreen> createState() => _EstadoDetailsScreenState();
}

class _EstadoDetailsScreenState extends State<EstadoDetailsScreen> {
  late final EstadoCultivoService _service;
  late Future<AuditDetailsModel> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? EstadoCultivoService();
    _cargarDetalles();
  }

  void _cargarDetalles() {
    setState(() {
      _detailsFuture = _service.fetchEstadoCultivoDetails(widget.estadoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombreEstado = widget.estado?.nombre ?? 'Detalle del Estado';
    final descripcionEstado = widget.estado?.descripcion;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fondo limpio estilo Mercado Libre
      appBar: AppBar(
        title: const Text(
          'Detalle de Auditoría',
          style: TextStyle(
            color: Color(0xFF222222),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF222222)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Actualizar',
            onPressed: _cargarDetalles,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _cargarDetalles(),
        color: const Color(0xFF1E4D2B),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TARJETA CABECERA (LIMPIA Y SIN ID)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreEstado,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222),
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (descripcionEstado != null &&
                        descripcionEstado.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 12),
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descripcionEstado,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Registro e Historial',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 10),

              // 2. SECCIÓN DE AUDITORÍA FORMATO FICHA TÉCNICA
              FutureBuilder<AuditDetailsModel>(
                future: _detailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFE0E0E0), width: 0.8),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF1E4D2B),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFFFCDD2), width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Error al cargar la auditoría',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD32F2F),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${snapshot.error}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _cargarDetalles,
                            child: const Text(
                              'Reintentar',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E4D2B),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }

                  final details = snapshot.data!;
                  final isDeleted = details.isDelete ?? false;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFFE0E0E0), width: 0.8),
                    ),
                    child: Column(
                      children: [
                        // ESTADO DE REGISTRO
                        _buildRowItem(
                          label: 'Estado del Registro',
                          customValue: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDeleted
                                  ? const Color(0xFFFFEBEE)
                                  : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isDeleted ? 'ELIMINADO' : 'ACTIVO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDeleted
                                    ? const Color(0xFFC62828)
                                    : const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),

                        // CREADO POR
                        _buildRowItem(
                          label: 'Creado Por',
                          value: _formatUser(
                              details.creatorName, details.createBy),
                        ),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),

                        // ÚLTIMA MODIFICACIÓN
                        _buildRowItem(
                          label: 'Última Modificación',
                          value: _formatUser(
                              details.updateName, details.updateBy),
                        ),

                        // INFORMACIÓN DE ELIMINACIÓN (SOLO SI APLICA)
                        if (isDeleted || details.deleteAt != null) ...[
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          _buildRowItem(
                            label: 'Eliminado Por',
                            value: _formatUser(
                                details.deleteName, details.deleteBy),
                          ),
                          if (details.deleteAt != null) ...[
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                            _buildRowItem(
                              label: 'Fecha de Eliminación',
                              value: _formatDate(details.deleteAt!),
                            ),
                          ],
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fila reutilizable clave-valor tipo Mercado Libre
  Widget _buildRowItem({
    required String label,
    String? value,
    Widget? customValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w400,
            ),
          ),
          if (customValue != null)
            customValue
          else
            Flexible(
              child: Text(
                value ?? '—',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF222222),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatUser(String? name, String? id) {
    if (name != null && name.isNotEmpty) {
      if (id != null && id.isNotEmpty && id != name) {
        return '$name ($id)';
      }
      return name;
    }
    if (id != null && id.isNotEmpty) {
      return id;
    }
    return 'Sin registrar';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}