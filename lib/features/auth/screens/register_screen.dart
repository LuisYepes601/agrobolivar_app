// lib/features/auth/screens/register_screen.dart

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/auth_model/register_request_model.dart';
import '../services/auth_api_service.dart';

// Importaciones del feature tipo_documento con prefijo
import '../../tipo_documento/models/tipo_documento_model.dart';
import '../../tipo_documento/services/tipo_documento_api_service.dart' as tipo_doc_service;
import '../../tipo_documento/widgets/tipo_documento_dropdown.dart';

// Importaciones del feature rol con prefijo
import '../../rol/models/rol_model.dart';
import '../../rol/services/rol_api_service.dart' as rol_service;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Controladores de Texto
  final _primerNombreController = TextEditingController();
  final _segundoNombreController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _emailController = TextEditingController();
  final _numDocController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Servicios instanciados
  final _authApiService = AuthApiService();
  final _tipoDocApiService = tipo_doc_service.TipoDocumentoApiService();
  final _rolApiService = rol_service.RolApiService();

  // Estado dinámico para Tipos de Documento
  List<TipoDocumentoModel> _tiposDocumento = [];
  bool _isLoadingTiposDoc = true;
  String? _errorTiposDoc;
  int? _selectedTipoDoc;

  // Estado dinámico para Roles
  List<RolModel> _roles = [];
  bool _isLoadingRoles = true;
  String? _errorRoles;
  int? _selectedRol;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Animación de Fondo
  late final AnimationController _bgController = AnimationController(
    duration: const Duration(seconds: 8),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _bgAnimation = CurvedAnimation(
    parent: _bgController,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    _fetchTiposDocumento();
    _fetchRoles();
  }

  Future<void> _fetchTiposDocumento() async {
    setState(() {
      _isLoadingTiposDoc = true;
      _errorTiposDoc = null;
    });

    try {
      final response = await _tipoDocApiService.fetchTiposDocumento(
        active: false,
        size: 50,
      );

      if (mounted) {
        setState(() {
          _tiposDocumento = response;
          _isLoadingTiposDoc = false;

          if (_tiposDocumento.isNotEmpty) {
            _selectedTipoDoc = _tiposDocumento.first.id;
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('--> Error cargando Tipos de Documento: $e');
      }
      if (mounted) {
        setState(() {
          _isLoadingTiposDoc = false;
          _errorTiposDoc = 'Error al cargar tipos de documento';
          _tiposDocumento = [
            TipoDocumentoModel(id: 1, nombre: 'Cédula de Ciudadanía'),
            TipoDocumentoModel(id: 2, nombre: 'Cédula de Extranjería'),
            TipoDocumentoModel(id: 3, nombre: 'NIT'),
          ];
          _selectedTipoDoc = 1;
        });
      }
    }
  }

  Future<void> _fetchRoles() async {
    setState(() {
      _isLoadingRoles = true;
      _errorRoles = null;
    });

    try {
      final roles = await _rolApiService.fetchRoles();

      if (mounted) {
        setState(() {
          _roles = roles;
          _isLoadingRoles = false;

          if (_roles.isNotEmpty) {
            _selectedRol = _roles.first.id;
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('<-- Error al cargar roles desde API: $e');
      }

      if (mounted) {
        setState(() {
          _isLoadingRoles = false;
          _errorRoles = 'No se conectó al servidor de roles. Usando lista local.';
          _roles = [
            RolModel(id: 2, nombre: 'Productor', descripcion: 'Agricultor / Campo'),
            RolModel(id: 3, nombre: 'Comprador', descripcion: 'Cliente / Aliado'),
          ];
          _selectedRol = 2;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _primerNombreController.dispose();
    _segundoNombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _emailController.dispose();
    _numDocController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _handleRegister();
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _showSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2E7D32), size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Registro Exitoso!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu cuenta ha sido creada correctamente. Inicia sesión con tu correo y contraseña.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar modal
                      Navigator.of(context).pop(); // Volver al LoginScreen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Ir al Login', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorModal(BuildContext context, {required String title, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTipoDoc == null) {
      _showErrorModal(
        context,
        title: 'Tipo de Documento',
        message: 'Por favor selecciona un tipo de documento válido.',
      );
      return;
    }

    if (_selectedRol == null) {
      _showErrorModal(
        context,
        title: 'Rol Requerido',
        message: 'Por favor selecciona un rol de usuario.',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorModal(
        context,
        title: 'Contraseñas no coinciden',
        message: 'Asegúrate de que ambas contraseñas sean totalmente iguales.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = RegisterRequestModel(
        primerNombre: _primerNombreController.text.trim(),
        segundoNombre: _segundoNombreController.text.trim(),
        apellidoPaterno: _apellidoPaternoController.text.trim(),
        apellidoMaterno: _apellidoMaternoController.text.trim(),
        email: _emailController.text.trim(),
        idRol: _selectedRol!,
        idTipoDoc: _selectedTipoDoc!,
        contrasenia: _passwordController.text,
        numDocumento: _numDocController.text.trim(),
        telefono: _telefonoController.text.trim(),
      );

      // 1. Llama a la API de registro
      await _authApiService.register(request);

      if (!mounted) return;

      // 2. Muestra modal de éxito y redirige al Login al hacer tap en "Ir al Login"
      _showSuccessModal(context);
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      _showErrorModal(
        context,
        title: 'Error de Registro',
        message: errorMsg.isNotEmpty ? errorMsg : 'No se pudo crear la cuenta. Intenta de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Fondo animado
          Positioned(
            top: -40,
            bottom: -40,
            left: -40,
            right: -40,
            child: AnimatedBuilder(
              animation: _bgAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_bgAnimation.value * 20, _bgAnimation.value * 15),
                  child: child,
                );
              },
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // 2. Overlay oscuro
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),

          // 3. Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _previousPage,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          'Registro de Usuario',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Indicador de Pasos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Row(
                    children: [
                      _buildStepIndicator(0, 'Personal'),
                      _buildStepLine(0),
                      _buildStepIndicator(1, 'Contacto'),
                      _buildStepLine(1),
                      _buildStepIndicator(2, 'Cuenta'),
                    ],
                  ),
                ),

                // Tarjeta Principal Glassmorphism
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.90),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              onPageChanged: (page) => setState(() => _currentStep = page),
                              children: [
                                _buildStepPersonal(primaryColor),
                                _buildStepContacto(primaryColor),
                                _buildStepCuenta(primaryColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Controles de Navegación Inferior
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentStep == 2 ? 'Completar Registro' : 'Siguiente Paso',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentStep == 2 ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('¿Ya tienes cuenta? ', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Inicia Sesión',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- PASO 1: DATOS PERSONALES ---
  Widget _buildStepPersonal(Color primaryColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Datos Personales', 'Ingresa tus nombres y apellidos tal como figuran en tu documento.'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _primerNombreController,
            decoration: _inputDecoration('Primer Nombre *', Icons.person_outline, primaryColor),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu primer nombre' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _segundoNombreController,
            decoration: _inputDecoration('Segundo Nombre (Opcional)', Icons.person_outline, primaryColor),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _apellidoPaternoController,
            decoration: _inputDecoration('Primer Apellido *', Icons.badge_outlined, primaryColor),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu primer apellido' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _apellidoMaternoController,
            decoration: _inputDecoration('Segundo Apellido (Opcional)', Icons.badge_outlined, primaryColor),
          ),
        ],
      ),
    );
  }

  // --- PASO 2: IDENTIFICACIÓN Y CONTACTO ---
  Widget _buildStepContacto(Color primaryColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Identificación y Contacto', 'Necesitamos estos datos para validar tu identidad.'),
          const SizedBox(height: 20),

          TipoDocumentoDropdown(
            items: _tiposDocumento,
            selectedValue: _selectedTipoDoc,
            isLoading: _isLoadingTiposDoc,
            errorMessage: _errorTiposDoc,
            onChanged: (val) => setState(() => _selectedTipoDoc = val),
            validator: (val) => val == null ? 'Selecciona un tipo de documento' : null,
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _numDocController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Número de Documento *', Icons.numbers_outlined, primaryColor),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu número de documento' : null,
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _telefonoController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('Teléfono / Celular *', Icons.phone_outlined, primaryColor),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu teléfono' : null,
          ),
        ],
      ),
    );
  }

  // --- PASO 3: CUENTA Y SELECCIÓN DE ROL ---
  Widget _buildStepCuenta(Color primaryColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Configuración de Cuenta', 'Selecciona tu perfil e ingresa tus credenciales.'),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Perfil de Usuario', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
              if (_errorRoles != null)
                GestureDetector(
                  onTap: _fetchRoles,
                  child: const Text('Reintentar', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 10),

          _buildRoleSelector(primaryColor),
          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Correo Electrónico *', Icons.email_outlined, primaryColor),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
              if (!v.contains('@')) return 'Correo no válido';
              return null;
            },
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: _inputDecoration('Contraseña *', Icons.lock_outline, primaryColor).copyWith(
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: primaryColor),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: _inputDecoration('Confirmar Contraseña *', Icons.lock_clock_outlined, primaryColor).copyWith(
              suffixIcon: IconButton(
                icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: primaryColor),
                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Confirma tu contraseña' : null,
          ),
        ],
      ),
    );
  }

  // --- COMPONENTES AUXILIARES ---

  Widget _buildRoleSelector(Color primaryColor) {
    if (_isLoadingRoles) {
      return Container(
        height: 60,
        alignment: Alignment.center,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
        ),
      );
    }

    if (_roles.isEmpty) {
      return const Text(
        'No se encontraron roles disponibles.',
        style: TextStyle(color: Colors.grey, fontSize: 13),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorRoles != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              _errorRoles!,
              style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ..._roles.map((rol) {
          final isSelected = _selectedRol == rol.id;
          final nameLower = rol.nombre.toLowerCase();

          IconData icon = Icons.person_outline;
          if (nameLower.contains('produc') || nameLower.contains('agri')) {
            icon = Icons.agriculture_outlined;
          } else if (nameLower.contains('compra') || nameLower.contains('clien')) {
            icon = Icons.shopping_bag_outlined;
          } else if (nameLower.contains('admin')) {
            icon = Icons.admin_panel_settings_outlined;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => setState(() => _selectedRol = rol.id),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor.withOpacity(0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey.shade300,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? primaryColor : Colors.grey.shade600,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rol.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? primaryColor : Colors.black87,
                            ),
                          ),
                          if (rol.descripcion != null && rol.descripcion!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              rol.descripcion!,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Radio<int>(
                      value: rol.id,
                      groupValue: _selectedRol,
                      activeColor: primaryColor,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRol = val);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStepHeader(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3)),
      ],
    );
  }

  Widget _buildStepIndicator(int stepIndex, String label) {
    final isActive = _currentStep >= stepIndex;
    final isCurrent = _currentStep == stepIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Theme.of(context).colorScheme.primary : Colors.white.withOpacity(0.3),
            border: Border.all(
              color: isCurrent ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isActive && !isCurrent
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
              '${stepIndex + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isCurrent ? Colors.white : Colors.white60,
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int stepIndex) {
    final isActive = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16.0),
        color: isActive ? Theme.of(context).colorScheme.primary : Colors.white.withOpacity(0.3),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, Color primaryColor) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.95),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    );
  }
}