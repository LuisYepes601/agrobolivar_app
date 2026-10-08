import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agro_bolivar/features/perfil/models/usuario_model.dart';
import 'package:agro_bolivar/features/perfil/models/informacion_personal_dto_req.dart';
import 'package:agro_bolivar/features/perfil/services/perfil_sevrice.dart';
import 'package:agro_bolivar/features/tipo_documento/services/tipo_documento_api_service.dart';
import 'package:agro_bolivar/features/tipo_documento/models/tipo_documento_model.dart';

class EditarPerfilScreen extends StatefulWidget {
  final UsuarioModel usuario;

  const EditarPerfilScreen({super.key, required this.usuario});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _perfilService = PerfilService();
  final _tipoDocApiService = TipoDocumentoApiService();

  late TextEditingController _primerNombreCtrl;
  late TextEditingController _segundoNombreCtrl;
  late TextEditingController _apellidoPaternoCtrl;
  late TextEditingController _apellidoMaternoCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _numDocumentoCtrl;
  late TextEditingController _telefonoCtrl;

  List<TipoDocumentoModel> _tiposDocumento = [];
  bool _isLoadingTiposDoc = true;
  int? _selectedTipoDocId;
  bool _isSaving = false;

  // Paleta minimalista
  static const Color _primaryGreen = Color(0xFF1B4D2E);
  static const Color _bgCanvas = Color(0xFFF4F5F7);
  static const Color _cardBg = Colors.white;
  static const Color _textDark = Color(0xFF191C1E);
  static const Color _textMuted = Color(0xFF74777F);
  static const Color _dividerColor = Color(0xFFEDF0F2);

  final RegExp _nombreRegExp = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]+$');

  @override
  void initState() {
    super.initState();

    final partesNombre = widget.usuario.nombreCompleto.trim().split(RegExp(r'\s+'));

    _primerNombreCtrl = TextEditingController(text: partesNombre.isNotEmpty ? partesNombre[0] : '');
    _segundoNombreCtrl = TextEditingController(text: partesNombre.length > 2 ? partesNombre[1] : '');
    _apellidoPaternoCtrl = TextEditingController(
      text: partesNombre.length >= 3 ? partesNombre[partesNombre.length - 2] : '',
    );
    _apellidoMaternoCtrl = TextEditingController(
      text: partesNombre.length >= 2 ? partesNombre.last : '',
    );

    _emailCtrl = TextEditingController(text: widget.usuario.email);
    _numDocumentoCtrl = TextEditingController(text: widget.usuario.numDocumento);
    _telefonoCtrl = TextEditingController(text: widget.usuario.telefono);

    _cargarTiposDocumento();
  }

  /// Carga los tipos de documento desde el servicio TipoDocumentoApiService
  Future<void> _cargarTiposDocumento() async {
    try {
      final tipos = await _tipoDocApiService.fetchTiposDocumento(active: false);
      if (mounted) {
        setState(() {
          _tiposDocumento = tipos;

          if (_tiposDocumento.isNotEmpty) {
            // Intenta seleccionar el tipo de documento actual del usuario por coincidencia de nombre o id
            final docCoincidente = _tiposDocumento.firstWhere(
                  (t) =>
              t.nombre.toLowerCase().trim() ==
                  widget.usuario.tipoDocumento?.toLowerCase().trim(),
              orElse: () => _tiposDocumento.first,
            );
            _selectedTipoDocId = docCoincidente.id;
          }
          _isLoadingTiposDoc = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar tipos de documento: $e');
      if (mounted) {
        setState(() => _isLoadingTiposDoc = false);
      }
    }
  }

  @override
  void dispose() {
    _primerNombreCtrl.dispose();
    _segundoNombreCtrl.dispose();
    _apellidoPaternoCtrl.dispose();
    _apellidoMaternoCtrl.dispose();
    _emailCtrl.dispose();
    _numDocumentoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarInformacionPersonal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTipoDocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un tipo de documento'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final dtoReq = InformacionPersonalDtoReq(
      primerNombre: _primerNombreCtrl.text.trim(),
      segundoNombre: _segundoNombreCtrl.text.trim().isEmpty ? null : _segundoNombreCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      apellidoPaterno: _apellidoPaternoCtrl.text.trim(),
      apellidoMaterno: _apellidoMaternoCtrl.text.trim(),
      numDocumento: _numDocumentoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      idTipoDoc: _selectedTipoDocId!,
    );

    try {
      await _perfilService.actualizarInformacionPersonal(
        idUsuario: widget.usuario.id,
        dto: dtoReq,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guardado correctamente'),
          backgroundColor: _primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCanvas,
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _primaryGreen,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _guardarInformacionPersonal,
            child: _isSaving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Text(
              'Guardar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // --- NOMBRES Y APELLIDOS ---
              _buildSectionHeader('NOMBRES Y APELLIDOS'),
              _buildCleanGroupCard([
                _buildMinimalField(
                  controller: _primerNombreCtrl,
                  label: 'Primer nombre *',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'El primer nombre es obligatorio';
                    if (val.trim().length < 2) return 'Mínimo 2 caracteres';
                    if (!_nombreRegExp.hasMatch(val.trim())) return 'Solo letras y espacios';
                    return null;
                  },
                ),
                _buildFieldDivider(),
                _buildMinimalField(
                  controller: _segundoNombreCtrl,
                  label: 'Segundo nombre (opcional)',
                  validator: (val) {
                    if (val != null && val.trim().isNotEmpty) {
                      if (!_nombreRegExp.hasMatch(val.trim())) return 'Solo letras y espacios';
                    }
                    return null;
                  },
                ),
                _buildFieldDivider(),
                _buildMinimalField(
                  controller: _apellidoPaternoCtrl,
                  label: 'Apellido paterno *',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'El apellido paterno es obligatorio';
                    if (val.trim().length < 2) return 'Mínimo 2 caracteres';
                    if (!_nombreRegExp.hasMatch(val.trim())) return 'Solo letras y espacios';
                    return null;
                  },
                ),
                _buildFieldDivider(),
                _buildMinimalField(
                  controller: _apellidoMaternoCtrl,
                  label: 'Apellido materno *',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'El apellido materno es obligatorio';
                    if (val.trim().length < 2) return 'Mínimo 2 caracteres';
                    if (!_nombreRegExp.hasMatch(val.trim())) return 'Solo letras y espacios';
                    return null;
                  },
                ),
              ]),

              // --- IDENTIFICACIÓN ---
              _buildSectionHeader('IDENTIFICACIÓN'),
              _buildCleanGroupCard([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _isLoadingTiposDoc
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _primaryGreen,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Cargando tipos de documento...',
                          style: TextStyle(color: _textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                      : DropdownButtonFormField<int>(
                    value: _selectedTipoDocId,
                    style: const TextStyle(
                      fontSize: 15,
                      color: _textDark,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Tipo de documento *',
                      labelStyle: TextStyle(color: _textMuted, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    items: _tiposDocumento.map((tipo) {
                      return DropdownMenuItem<int>(
                        value: tipo.id,
                        child: Text(tipo.nombre),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedTipoDocId = value),
                    validator: (val) => val == null ? 'Selecciona un tipo de documento' : null,
                  ),
                ),
                _buildFieldDivider(),
                _buildMinimalField(
                  controller: _numDocumentoCtrl,
                  label: 'Número de documento *',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 20,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'El documento es obligatorio';
                    if (val.trim().length < 5 || val.trim().length > 20) return 'Entre 5 y 20 dígitos';
                    return null;
                  },
                ),
              ]),

              // --- CONTACTO ---
              _buildSectionHeader('CONTACTO'),
              _buildCleanGroupCard([
                _buildMinimalField(
                  controller: _emailCtrl,
                  label: 'Correo electrónico *',
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 100,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'El correo es obligatorio';
                    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegExp.hasMatch(val.trim())) return 'Correo no válido';
                    return null;
                  },
                ),
                _buildFieldDivider(),
                _buildMinimalField(
                  controller: _telefonoCtrl,
                  label: 'Teléfono / Celular *',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'El teléfono es obligatorio';
                    final cellRegExp = RegExp(r'^3[0-9]{9}$');
                    if (!cellRegExp.hasMatch(val.trim())) return 'Número de 10 dígitos (ej. 3001234567)';
                    return null;
                  },
                ),
              ]),

              const SizedBox(height: 32),

              // Botón inferior principal estilo Mercado Libre
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isSaving ? null : _guardarInformacionPersonal,
                    child: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text(
                      'Guardar cambios',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS MINIMALISTAS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildCleanGroupCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildMinimalField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        style: const TextStyle(fontSize: 15, color: _textDark, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _textMuted, fontSize: 13),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildFieldDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: _dividerColor,
    );
  }
}