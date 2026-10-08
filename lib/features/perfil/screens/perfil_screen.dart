import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agro_bolivar/features/auth/services/auth_local_service.dart';
import 'package:agro_bolivar/features/auth/screens/login_screen.dart';
import 'package:agro_bolivar/features/perfil/services/perfil_sevrice.dart';
import 'package:agro_bolivar/features/perfil/models/usuario_model.dart';
import 'package:agro_bolivar/features/perfil/screens/editar_perfil_screen.dart';

class PerfilScreen extends StatefulWidget {
  final int? userId;

  const PerfilScreen({super.key, this.userId});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _authLocalService = AuthLocalService();
  final _perfilService = PerfilService();
  final ImagePicker _picker = ImagePicker();

  UsuarioModel? _usuario;
  bool _isLoading = true;
  bool _isUploadingFoto = false;
  bool _notificacionesActivas = true;

  // Estilos de color limpios y modernos
  static const Color _primaryGreen = Color(0xFF1B4D2E);
  static const Color _bgCanvas = Color(0xFFF8FAFC);
  static const Color _cardBg = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderLight = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _fetchPerfilData();
  }

  Future<void> _fetchPerfilData() async {
    try {
      UsuarioModel usuarioData;

      if (widget.userId != null) {
        usuarioData = await _perfilService.obtenerUsuarioPorId(widget.userId!);
      } else {
        usuarioData = await _perfilService.obtenerUsuarioActual();
      }

      if (mounted) {
        setState(() {
          _usuario = usuarioData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar datos del perfil: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Navega a la pantalla de edición de perfil y recarga los datos si hubo cambios
  Future<void> _navegarAEditarPerfil() async {
    if (_usuario == null) return;

    final actualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPerfilScreen(usuario: _usuario!),
      ),
    );

    if (actualizado == true && mounted) {
      setState(() => _isLoading = true);
      _fetchPerfilData(); // <--- Aquí recarga los datos del servidor
    }
  }

  /// Muestra un modal para elegir entre Cámara o Galería y procesa la foto
  void _mostrarOpcionesFoto() {
    if (_usuario == null || _isUploadingFoto) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Cambiar Foto de Perfil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: _primaryGreen),
              title: const Text('Elegir de la Galería'),
              onTap: () {
                Navigator.of(ctx).pop();
                _seleccionarYSubirFoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: _primaryGreen),
              title: const Text('Tomar una Foto'),
              onTap: () {
                Navigator.of(ctx).pop();
                _seleccionarYSubirFoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Selecciona la imagen y llama a PerfilService para subirla vía FormData
  /// Selecciona la imagen y llama a PerfilService para subirla vía FormData
  Future<void> _seleccionarYSubirFoto(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null || _usuario == null) return;

      setState(() => _isUploadingFoto = true);

      final File file = File(pickedFile.path);

      final usuarioActualizado = await _perfilService.actualizarFotoPerfil(
        id: _usuario!.id,
        fotoFile: file,
      );

      // Limpia la caché interna de imágenes de Flutter para forzar la recarga visual de la nueva foto
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      if (mounted) {
        setState(() {
          _usuario = usuarioActualizado;
          _isUploadingFoto = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada correctamente'),
            backgroundColor: _primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al subir foto: $e');
      if (mounted) {
        setState(() => _isUploadingFoto = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la foto: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  Future<void> _handleLogout() async {
    try {
      await _authLocalService.clearSession();
    } catch (e) {
      debugPrint('Error al limpiar sesión: $e');
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  String _obtenerIniciales(String nombre) {
    if (nombre.trim().isEmpty) return 'U';
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return partes[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final nombreCompleto = _usuario?.nombreCompleto.isNotEmpty == true
        ? _usuario!.nombreCompleto
        : 'Usuario';
    final rol = _usuario?.rol ?? 'Productor';
    final photoUrl = _usuario?.imgUser;
    final email = _usuario?.email ?? 'No registrado';
    final telefono = _usuario?.telefono ?? 'Sin teléfono';
    final documento = (_usuario?.tipoDocumento != null && _usuario?.numDocumento != null)
        ? '${_usuario!.tipoDocumento}: ${_usuario!.numDocumento}'
        : (_usuario?.numDocumento ?? 'No registrado');
    final esActivo = _usuario?.estado ?? true;

    return Scaffold(
      backgroundColor: _bgCanvas,
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: _primaryGreen,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
            tooltip: 'Editar Perfil',
            onPressed: _usuario == null ? null : _navegarAEditarPerfil,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: _primaryGreen),
      )
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- ENCABEZADO DE USUARIO ---
            Container(
              width: double.infinity,
              color: _primaryGreen,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _mostrarOpcionesFoto,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: CircleAvatar(
                            radius: 58,
                            backgroundColor: const Color(0xFFE2E8F0),
                            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                                ? NetworkImage(photoUrl)
                                : null,
                            child: _isUploadingFoto
                                ? const CircularProgressIndicator(
                              color: _primaryGreen,
                              strokeWidth: 3,
                            )
                                : ((photoUrl == null || photoUrl.isEmpty)
                                ? Text(
                              _obtenerIniciales(nombreCompleto),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _primaryGreen,
                              ),
                            )
                                : null),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                            border: Border.all(color: _primaryGreen, width: 2.5),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    nombreCompleto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      rol,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- INFORMACIÓN PERSONAL ---
            _buildSectionTitle('INFORMACIÓN PERSONAL'),
            _buildCardBlock([
              _buildTile(
                icon: Icons.email_outlined,
                title: 'Correo Electrónico',
                value: email,
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.phone_android_outlined,
                title: 'Teléfono',
                value: telefono,
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.badge_outlined,
                title: 'Documento de Identidad',
                value: documento,
              ),
              _buildDivider(),
              _buildStatusTile(esActivo: esActivo),
            ]),

            const SizedBox(height: 28),

            // --- CONFIGURACIÓN ---
            _buildSectionTitle('CONFIGURACIÓN'),
            _buildCardBlock([
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                secondary: const Icon(Icons.notifications_none_outlined, color: _primaryGreen, size: 24),
                title: const Text(
                  'Notificaciones',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Alertas sobre tu actividad y productos',
                    style: TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ),
                value: _notificacionesActivas,
                activeColor: _primaryGreen,
                onChanged: (val) {
                  setState(() {
                    _notificacionesActivas = val;
                  });
                },
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.lock_outline,
                title: 'Cambiar Contraseña',
                subtitle: 'Actualiza tus credenciales de acceso',
                onTap: () {},
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.help_outline,
                title: 'Ayuda y Soporte',
                subtitle: 'Preguntas frecuentes y soporte directo',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 32),

            // --- BOTÓN CERRAR SESIÓN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  foregroundColor: const Color(0xFFDC2626),
                  backgroundColor: _cardBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFFCA5A5), width: 1),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => _mostrarDialogoCerrarSesion(context),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCardBlock(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: _primaryGreen, size: 24),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile({required bool esActivo}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: esActivo ? _primaryGreen : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado de la Cuenta',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: esActivo ? const Color(0xFF16A34A) : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      esActivo ? 'Activa' : 'Inactiva',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: esActivo ? const Color(0xFF16A34A) : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: _primaryGreen, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: _textMuted),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: _textMuted, size: 22),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 62,
      endIndent: 20,
      color: Color(0xFFF1F5F9),
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleLogout();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}