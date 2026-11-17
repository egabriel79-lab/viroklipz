import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'main_screen.dart';

class RegisterFormScreen extends StatefulWidget {
  const RegisterFormScreen({super.key});

  @override
  State<RegisterFormScreen> createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends State<RegisterFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Datos principales del creador
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Datos del representante legal (solo cuando edad < 18)
  final _tutorFirstNameController = TextEditingController();
  final _tutorLastNameController = TextEditingController();
  final _tutorEmailController = TextEditingController();

  bool _isMinor = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _ageController.addListener(_onAgeChanged);
  }

  void _onAgeChanged() {
    final int? parsedAge = int.tryParse(_ageController.text.trim());
    final bool nextIsMinor =
        parsedAge != null && parsedAge > 0 && parsedAge < 18;
    if (nextIsMinor != _isMinor) {
      setState(() {
        _isMinor = nextIsMinor;
      });
    }
  }

  @override
  void dispose() {
    _ageController.removeListener(_onAgeChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _tutorFirstNameController.dispose();
    _tutorLastNameController.dispose();
    _tutorEmailController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFDC2626),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    final bool isValidForm = _formKey.currentState?.validate() ?? false;
    if (!isValidForm) {
      if (_isMinor &&
          (_tutorFirstNameController.text.trim().isEmpty ||
              _tutorLastNameController.text.trim().isEmpty ||
              _tutorEmailController.text.trim().isEmpty)) {
        _showErrorSnackBar(
          'Debes completar todos los campos del representante legal.',
        );
      }
      return;
    }

    final int? parsedAge = int.tryParse(_ageController.text.trim());
    if (parsedAge == null || parsedAge <= 0) {
      _showErrorSnackBar('Ingresa una edad válida.');
      return;
    }

    final bool minorAccount = parsedAge < 18;
    if (minorAccount &&
        (_tutorFirstNameController.text.trim().isEmpty ||
            _tutorLastNameController.text.trim().isEmpty ||
            _tutorEmailController.text.trim().isEmpty)) {
      _showErrorSnackBar(
        'Para menores de 18 años es obligatorio completar los datos del tutor legal.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final String generatedUsername =
        '${_firstNameController.text.trim()}.${_lastNameController.text.trim()}'
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), '');

    final authProvider = context.read<AuthProvider>();
    final String? errorMessage = await authProvider.signUp(
      _emailController.text.trim(),
      _passwordController.text,
      generatedUsername.isEmpty ? 'creador' : generatedUsername,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      country: _countryController.text.trim(),
      age: parsedAge,
      isMinor: minorAccount,
      tutor: minorAccount
          ? {
              'nombre': _tutorFirstNameController.text.trim(),
              'apellido': _tutorLastNameController.text.trim(),
              'email': _tutorEmailController.text.trim(),
            }
          : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (errorMessage != null) {
      _showErrorSnackBar(errorMessage);
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    Color focusColor = const Color(0xFFFF6B00),
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF71717A), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFFA1A1AA), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF161616),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: focusColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF4D6D)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Viroklipz',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.16),
                    blurRadius: 110,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9333EA).withValues(alpha: 0.16),
                    blurRadius: 110,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Crea tu perfil de creador',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Completa tus datos para personalizar tu cuenta en Viroklipz.',
                      style: TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const _FieldLabel('Nombres'),
                    TextFormField(
                      controller: _firstNameController,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(
                        hint: 'Ej. Mateo Sebastián',
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tus nombres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    const _FieldLabel('Apellidos'),
                    TextFormField(
                      controller: _lastNameController,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(
                        hint: 'Ej. Rivera Gómez',
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tus apellidos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 1. País en lugar de Ciudad
                    const _FieldLabel('País'),
                    TextFormField(
                      controller: _countryController,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(
                        hint: 'Escribe tu país (ej. Colombia, España, México...)',
                        icon: Icons.location_on_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu país';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. Edad con listener en tiempo real
                    const _FieldLabel('Edad'),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(
                        hint: 'Ej. 22',
                        icon: Icons.calendar_today_outlined,
                      ),
                      validator: (value) {
                        final int? age = int.tryParse(value?.trim() ?? '');
                        if (age == null || age <= 0 || age > 120) {
                          return 'Ingresa una edad numérica válida (1 a 120)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    const _FieldLabel('Correo electrónico'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(
                        hint: 'correo@ejemplo.com',
                        icon: Icons.mail_outline_rounded,
                      ),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Ingresa un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    const _FieldLabel('Contraseña'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction:
                          _isMinor ? TextInputAction.next : TextInputAction.done,
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(
                        hint: 'Mínimo 6 caracteres',
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFFA1A1AA),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),

                    // 3. Formulario dinámico para menores de 18 años
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: Visibility(
                        visible: _isMinor,
                        child: Container(
                          margin: const EdgeInsets.only(top: 22),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Color(0xFFFBBF24),
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Debes tener al menos 18 años o contar con la autorización de un tutor legal',
                                        style: TextStyle(
                                          color: Color(0xFFFDE68A),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    color: Color(0xFFEC4899),
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Información del Representante Legal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              const _FieldLabel('Nombres (del tutor)'),
                              TextFormField(
                                controller: _tutorFirstNameController,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(color: Colors.white),
                                decoration: _fieldDecoration(
                                  hint: 'Nombres del representante legal',
                                  icon: Icons.person_outline_rounded,
                                  focusColor: const Color(0xFFEC4899),
                                ),
                                validator: (value) {
                                  if (!_isMinor) return null;
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingresa los nombres del tutor legal';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              const _FieldLabel('Apellidos (del tutor)'),
                              TextFormField(
                                controller: _tutorLastNameController,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(color: Colors.white),
                                decoration: _fieldDecoration(
                                  hint: 'Apellidos del representante legal',
                                  icon: Icons.person_outline_rounded,
                                  focusColor: const Color(0xFFEC4899),
                                ),
                                validator: (value) {
                                  if (!_isMinor) return null;
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingresa los apellidos del tutor legal';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              const _FieldLabel('Correo electrónico (del tutor)'),
                              TextFormField(
                                controller: _tutorEmailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(color: Colors.white),
                                decoration: _fieldDecoration(
                                  hint: 'tutor@ejemplo.com',
                                  icon: Icons.mail_outline_rounded,
                                  focusColor: const Color(0xFFEC4899),
                                ),
                                validator: (value) {
                                  if (!_isMinor) return null;
                                  final clean = value?.trim() ?? '';
                                  if (clean.isEmpty || !clean.contains('@')) {
                                    return 'Ingresa un correo válido del tutor legal';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 4. Botón dinámico según edad (< 18 vs 18+)
                    if (!_isMinor)
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B00), Color(0xFFEC4899)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B00).withValues(alpha: 0.45),
                              blurRadius: 22,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Crear mi cuenta',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      )
                    else
                      Container(
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF673AB7), Color(0xFFEC4899)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9333EA).withValues(alpha: 0.45),
                              blurRadius: 22,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: _isSubmitting
                              ? const SizedBox.shrink()
                              : const Icon(
                                  Icons.verified_user_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                          label: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Soy representante legal de menor de edad',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                      child: const Text(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE4E4E7),
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}