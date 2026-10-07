import 'package:flutter/material.dart';
import 'package:agro_bolivar/features/especie_planta/model/especie_planta_model.dart';
import 'package:agro_bolivar/features/especie_planta/services/especie_planta_service.dart';
import 'package:agro_bolivar/features/estaciones/models/estacion_model.dart';
import 'package:agro_bolivar/features/estaciones/services/estacion_service.dart';
import 'package:agro_bolivar/features/tipo_planta/models/tipo_planta_model.dart';
import 'package:agro_bolivar/features/tipo_planta/services/tipo_planta_service.dart';
import 'package:agro_bolivar/features/familia_planta/model/familia_planta_model.dart';
import 'package:agro_bolivar/features/familia_planta/services/familia_planta_service.dart';
import '../models/planta_admin_model.dart';
import '../models/planta_model.dart';
import '../services/planta_service.dart';
import 'planta_detail_screen.dart';

class GuiaPlantasScreen extends StatefulWidget {
  final bool isTab;

  const GuiaPlantasScreen({super.key, this.isTab = false});

  @override
  State<GuiaPlantasScreen> createState() => _GuiaPlantasScreenState();
}

class _GuiaPlantasScreenState extends State<GuiaPlantasScreen> {
  final PlantaService _plantaService = PlantaService();
  final EspeciePlantaService _especiePlantaService = EspeciePlantaService();
  final EstacionService _estacionService = EstacionService();
  final TipoPlantaService _tipoPlantaService = TipoPlantaService();
  final FamiliaPlantaService _familiaPlantaService = FamiliaPlantaService();

  final TextEditingController _searchController = TextEditingController();

  List<PlantaAdminModel> _plantas = [];
  List<EspeciePlantaModel> _especiesList = [];
  List<EstacionModel> _estacionesList = [];
  List<TipoPlantaModel> _tiposList = [];
  List<FamiliaPlantaModel> _familiasList = [];

  bool _isLoading = true;
  bool _isLoadingEspecies = false;
  bool _isLoadingEstaciones = false;
  bool _isLoadingTipos = false;
  bool _isLoadingFamilias = false;

  String? _errorMessage;
  String _searchQuery = '';

  // Filtro de Estado de la Planta ('todos', 'activos', 'inactivos')
  String _filterEstadoPlanta = 'todos';

  // Variables de Estado de Filtros Taxonómicos/Ubicación
  int? _filterIdTipo;
  int? _filterIdFamilia;
  int? _filterIdEspecie;
  int? _filterIdEstacionProduccion;

  @override
  void initState() {
    super.initState();
    _fetchPlantas();
    _fetchEspeciesList();
    _fetchEstacionesList();
    _fetchTiposList();
    _fetchFamiliasList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga la lista de familias de plantas dinámicamente
  Future<void> _fetchFamiliasList({StateSetter? setModalState}) async {
    if (mounted) {
      setState(() => _isLoadingFamilias = true);
      if (setModalState != null) setModalState(() {});
    }

    try {
      final familias = await _familiaPlantaService.fetchFamilias();

      if (mounted) {
        setState(() {
          _familiasList = familias;
          _isLoadingFamilias = false;
        });
        if (setModalState != null) setModalState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFamilias = false);
        if (setModalState != null) setModalState(() {});
      }
    }
  }

  /// Carga la lista de tipos de plantas dinámicamente
  Future<void> _fetchTiposList({StateSetter? setModalState}) async {
    if (mounted) {
      setState(() => _isLoadingTipos = true);
      if (setModalState != null) setModalState(() {});
    }

    try {
      final tipos = await _tipoPlantaService.fetchTiposPlanta();

      if (mounted) {
        setState(() {
          _tiposList = tipos;
          _isLoadingTipos = false;
        });
        if (setModalState != null) setModalState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTipos = false);
        if (setModalState != null) setModalState(() {});
      }
    }
  }

  /// Carga la lista de especies
  Future<void> _fetchEspeciesList({StateSetter? setModalState}) async {
    if (mounted) {
      setState(() => _isLoadingEspecies = true);
      if (setModalState != null) setModalState(() {});
    }

    try {
      final especies = await _especiePlantaService.fetchEspecies();

      if (mounted) {
        setState(() {
          _especiesList = especies;
          _isLoadingEspecies = false;
        });
        if (setModalState != null) setModalState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEspecies = false);
        if (setModalState != null) setModalState(() {});
      }
    }
  }

  /// Carga la lista de estaciones dinámicamente
  Future<void> _fetchEstacionesList({StateSetter? setModalState}) async {
    if (mounted) {
      setState(() => _isLoadingEstaciones = true);
      if (setModalState != null) setModalState(() {});
    }

    try {
      final estaciones = await _estacionService.fetchEstaciones();

      if (mounted) {
        setState(() {
          _estacionesList = estaciones;
          _isLoadingEstaciones = false;
        });
        if (setModalState != null) setModalState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEstaciones = false);
        if (setModalState != null) setModalState(() {});
      }
    }
  }

  String? _sanitize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'string') return null;
    return trimmed;
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_filterEstadoPlanta != 'todos') count++;
    if (_filterIdTipo != null) count++;
    if (_filterIdFamilia != null) count++;
    if (_filterIdEspecie != null) count++;
    if (_filterIdEstacionProduccion != null) count++;
    return count;
  }

  String _getNombreEspecie(int id) {
    try {
      final especie = _especiesList.firstWhere((e) => e.id == id);
      return especie.nombre;
    } catch (_) {
      return 'Especie ID: $id';
    }
  }

  String _getNombreEstacion(int id) {
    try {
      final estacion = _estacionesList.firstWhere((e) => e.id == id);
      return estacion.nombre;
    } catch (_) {
      return 'Estación ID: $id';
    }
  }

  String _getNombreTipo(int id) {
    try {
      final tipo = _tiposList.firstWhere((t) => t.id == id);
      return tipo.nombre;
    } catch (_) {
      return 'Tipo ID: $id';
    }
  }

  String _getNombreFamilia(int id) {
    try {
      final familia = _familiasList.firstWhere((f) => f.id == id);
      return familia.nombre;
    } catch (_) {
      return 'Familia ID: $id';
    }
  }

  Future<void> _fetchPlantas({String? nombre}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final resultado = await _plantaService.fetchPlantasAdmin(
        nombre: nombre,
        idTipo: _filterIdTipo,
        idFamilia: _filterIdFamilia,
        idEspecie: _filterIdEspecie,
        idEstacionProduccion: _filterIdEstacionProduccion,
        size: 50,
      );

      if (mounted) {
        setState(() {
          _plantas = resultado;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudieron cargar las plantas. Intenta de nuevo.';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _fetchPlantas(nombre: value.isEmpty ? null : value);
  }

  void _clearAllFilters() {
    setState(() {
      _filterEstadoPlanta = 'todos';
      _filterIdTipo = null;
      _filterIdFamilia = null;
      _filterIdEspecie = null;
      _filterIdEstacionProduccion = null;
    });
    _fetchPlantas(nombre: _searchQuery.isEmpty ? null : _searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E4D2B);

    final bodyContent = Column(
      children: [
        // Buscador + Botón Filtros
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          color: const Color(0xFFF8FAFC),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: primaryColor, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.grey, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _showFilterModal,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: _activeFiltersCount > 0 ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _activeFiltersCount > 0
                          ? primaryColor
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: _activeFiltersCount > 0 ? Colors.white : primaryColor,
                        size: 22,
                      ),
                      if (_activeFiltersCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE11D48),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$_activeFiltersCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_activeFiltersCount > 0) _buildActiveFiltersBar(),

        Expanded(
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2.5),
          )
              : _errorMessage != null
              ? _buildErrorWidget()
              : _plantas.isEmpty
              ? _buildEmptyWidget()
              : RefreshIndicator(
            color: primaryColor,
            backgroundColor: Colors.white,
            onRefresh: () => _fetchPlantas(
              nombre: _searchQuery.isEmpty ? null : _searchQuery,
            ),
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: _plantas.length,
              itemBuilder: (context, index) {
                return _buildPlantaCard(_plantas[index]);
              },
            ),
          ),
        ),
      ],
    );

    if (widget.isTab) {
      return Container(color: const Color(0xFFF8FAFC), child: bodyContent);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Guía de Plantas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: bodyContent,
    );
  }

  Widget _buildActiveFiltersBar() {
    const primaryColor = Color(0xFF1E4D2B);

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (_filterEstadoPlanta != 'todos')
            _buildFilterChip(
              label: _filterEstadoPlanta == 'activos' ? 'Activas' : 'Inactivas',
              onDeleted: () {
                setState(() => _filterEstadoPlanta = 'todos');
                _fetchPlantas(nombre: _searchQuery);
              },
            ),
          if (_filterIdEspecie != null)
            _buildFilterChip(
              label: _getNombreEspecie(_filterIdEspecie!),
              onDeleted: () {
                setState(() => _filterIdEspecie = null);
                _fetchPlantas(nombre: _searchQuery);
              },
            ),
          if (_filterIdEstacionProduccion != null)
            _buildFilterChip(
              label: _getNombreEstacion(_filterIdEstacionProduccion!),
              onDeleted: () {
                setState(() => _filterIdEstacionProduccion = null);
                _fetchPlantas(nombre: _searchQuery);
              },
            ),
          if (_filterIdTipo != null)
            _buildFilterChip(
              label: _getNombreTipo(_filterIdTipo!),
              onDeleted: () {
                setState(() => _filterIdTipo = null);
                _fetchPlantas(nombre: _searchQuery);
              },
            ),
          if (_filterIdFamilia != null)
            _buildFilterChip(
              label: _getNombreFamilia(_filterIdFamilia!),
              onDeleted: () {
                setState(() => _filterIdFamilia = null);
                _fetchPlantas(nombre: _searchQuery);
              },
            ),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text(
              'Limpiar todos',
              style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required VoidCallback onDeleted}) {
    const primaryColor = Color(0xFF1E4D2B);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primaryColor),
        ),
        backgroundColor: primaryColor.withOpacity(0.08),
        deleteIcon: const Icon(Icons.close_rounded, size: 14, color: primaryColor),
        onDeleted: onDeleted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }

  // --- MODAL DE FILTROS ---
  void _showFilterModal() {
    const primaryColor = Color(0xFF1E4D2B);

    if (_especiesList.isEmpty && !_isLoadingEspecies) {
      _fetchEspeciesList();
    }
    if (_estacionesList.isEmpty && !_isLoadingEstaciones) {
      _fetchEstacionesList();
    }
    if (_tiposList.isEmpty && !_isLoadingTipos) {
      _fetchTiposList();
    }
    if (_familiasList.isEmpty && !_isLoadingFamilias) {
      _fetchFamiliasList();
    }

    String tempEstado = _filterEstadoPlanta;
    int? selectedEspecieId = _filterIdEspecie;
    int? selectedEstacionId = _filterIdEstacionProduccion;
    int? selectedTipoId = _filterIdTipo;
    int? selectedFamiliaId = _filterIdFamilia;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.82,
              child: Column(
                children: [
                  // Encabezado del Modal
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF333333)),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Filtros',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempEstado = 'todos';
                              selectedEspecieId = null;
                              selectedEstacionId = null;
                              selectedTipoId = null;
                              selectedFamiliaId = null;
                            });
                          },
                          child: const Text(
                            'Limpiar filtros',
                            style: TextStyle(
                              color: Color(0xFF3483FA),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cuerpo del Modal
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sección: Estado de la Planta
                          const Text(
                            'Estado de la planta',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          RadioListTile<String>(
                            title: const Text('Todos', style: TextStyle(fontSize: 14)),
                            value: 'todos',
                            groupValue: tempEstado,
                            activeColor: primaryColor,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setModalState(() => tempEstado = val!),
                          ),
                          RadioListTile<String>(
                            title: const Text('Activos únicamente', style: TextStyle(fontSize: 14)),
                            value: 'activos',
                            groupValue: tempEstado,
                            activeColor: primaryColor,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setModalState(() => tempEstado = val!),
                          ),
                          RadioListTile<String>(
                            title: const Text('Inactivos únicamente', style: TextStyle(fontSize: 14)),
                            value: 'inactivos',
                            groupValue: tempEstado,
                            activeColor: primaryColor,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setModalState(() => tempEstado = val!),
                          ),

                          const Divider(height: 28),

                          // Sección: Identificadores Generales
                          const Text(
                            'Identificadores generales',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Fila 1: Dropdowns de Especie y Estación
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Especie',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _isLoadingEspecies
                                        ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12.0),
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: primaryColor,
                                        ),
                                      ),
                                    )
                                        : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAFAFA),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFE0E0E0)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int?>(
                                          value: selectedEspecieId,
                                          isExpanded: true,
                                          hint: const Text(
                                            'Seleccionar',
                                            style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                                          ),
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: primaryColor,
                                            size: 20,
                                          ),
                                          items: [
                                            const DropdownMenuItem<int?>(
                                              value: null,
                                              child: Text(
                                                'Todas',
                                                style: TextStyle(fontSize: 13, color: Color(0xFF333333)),
                                              ),
                                            ),
                                            ..._especiesList.map((esp) {
                                              return DropdownMenuItem<int?>(
                                                value: esp.id,
                                                child: Text(
                                                  esp.nombre,
                                                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              );
                                            }),
                                          ],
                                          onChanged: (val) {
                                            setModalState(() {
                                              selectedEspecieId = val;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Estación',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _isLoadingEstaciones
                                        ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12.0),
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: primaryColor,
                                        ),
                                      ),
                                    )
                                        : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAFAFA),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFE0E0E0)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int?>(
                                          value: selectedEstacionId,
                                          isExpanded: true,
                                          hint: const Text(
                                            'Seleccionar',
                                            style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                                          ),
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: primaryColor,
                                            size: 20,
                                          ),
                                          items: [
                                            const DropdownMenuItem<int?>(
                                              value: null,
                                              child: Text(
                                                'Todas',
                                                style: TextStyle(fontSize: 13, color: Color(0xFF333333)),
                                              ),
                                            ),
                                            ..._estacionesList.map((est) {
                                              return DropdownMenuItem<int?>(
                                                value: est.id,
                                                child: Text(
                                                  est.nombre,
                                                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              );
                                            }),
                                          ],
                                          onChanged: (val) {
                                            setModalState(() {
                                              selectedEstacionId = val;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Fila 2: Dropdowns de Tipo de Planta y Familia de Planta
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tipo de Planta',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _isLoadingTipos
                                        ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12.0),
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: primaryColor,
                                        ),
                                      ),
                                    )
                                        : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAFAFA),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFE0E0E0)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int?>(
                                          value: selectedTipoId,
                                          isExpanded: true,
                                          hint: const Text(
                                            'Seleccionar',
                                            style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                                          ),
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: primaryColor,
                                            size: 20,
                                          ),
                                          items: [
                                            const DropdownMenuItem<int?>(
                                              value: null,
                                              child: Text(
                                                'Todos',
                                                style: TextStyle(fontSize: 13, color: Color(0xFF333333)),
                                              ),
                                            ),
                                            ..._tiposList.map((tipo) {
                                              return DropdownMenuItem<int?>(
                                                value: tipo.id,
                                                child: Text(
                                                  tipo.nombre,
                                                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              );
                                            }),
                                          ],
                                          onChanged: (val) {
                                            setModalState(() {
                                              selectedTipoId = val;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Familia',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _isLoadingFamilias
                                        ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12.0),
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: primaryColor,
                                        ),
                                      ),
                                    )
                                        : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAFAFA),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFE0E0E0)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int?>(
                                          value: selectedFamiliaId,
                                          isExpanded: true,
                                          hint: const Text(
                                            'Seleccionar',
                                            style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                                          ),
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: primaryColor,
                                            size: 20,
                                          ),
                                          items: [
                                            const DropdownMenuItem<int?>(
                                              value: null,
                                              child: Text(
                                                'Todas',
                                                style: TextStyle(fontSize: 13, color: Color(0xFF333333)),
                                              ),
                                            ),
                                            ..._familiasList.map((fam) {
                                              return DropdownMenuItem<int?>(
                                                value: fam.id,
                                                child: Text(
                                                  fam.nombre,
                                                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              );
                                            }),
                                          ],
                                          onChanged: (val) {
                                            setModalState(() {
                                              selectedFamiliaId = val;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
                        ],
                      ),
                    ),
                  ),

                  // Botón Aplicar Filtros
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _filterEstadoPlanta = tempEstado;
                              _filterIdTipo = selectedTipoId;
                              _filterIdFamilia = selectedFamiliaId;
                              _filterIdEspecie = selectedEspecieId;
                              _filterIdEstacionProduccion = selectedEstacionId;
                            });
                            Navigator.pop(context);
                            _fetchPlantas(nombre: _searchQuery.isEmpty ? null : _searchQuery);
                          },
                          child: const Text(
                            'Aplicar filtros',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlantaCard(PlantaAdminModel planta) {
    const primaryColor = Color(0xFF1E4D2B);
    final hasImg = planta.img != null && planta.img!.trim().isNotEmpty;
    final tipoLimpio = _sanitize(planta.nombreTipo);
    final descripcionLimpia = _sanitize(planta.descripcion);
    final cientificoLimpio = _sanitize(planta.nombreCientifico);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantaDetailScreen(planta: planta),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    color: const Color(0xFFF8FAFC),
                    child: hasImg
                        ? Image.network(
                      planta.img!,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                    )
                        : _buildImagePlaceholder(),
                  ),
                ),
                if (tipoLimpio != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        tipoLimpio,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planta.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cientificoLimpio ?? 'Especie general',
                      style: TextStyle(
                        fontStyle: cientificoLimpio != null ? FontStyle.italic : FontStyle.normal,
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      descripcionLimpia ?? 'Toca para ver detalles de cultivo y clasificación.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF475569),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ver ficha',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: primaryColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 130,
      width: double.infinity,
      color: const Color(0xFFE8F5E9).withOpacity(0.5),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          size: 42,
          color: const Color(0xFF1E4D2B).withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 14),
          Text(
            'No encontramos plantas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 4),
          Text(
            'Intenta cambiar los parámetros de búsqueda o filtros.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    const primaryColor = Color(0xFF1E4D2B);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Ocurrió un error al cargar los datos',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _fetchPlantas(nombre: _searchQuery.isEmpty ? null : _searchQuery),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
              label: const Text('Reintentar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}