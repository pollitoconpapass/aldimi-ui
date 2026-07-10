import 'package:flutter/material.dart';
import '../themes/palette.dart';
import '../widgets/input_text_box.dart';
import '../models/info_models.dart';
import '../services/api_service.dart';
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _currentStep = 0;
  static const int _totalSteps = 4;

  final _dniCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _gender = 'male';
  String _role = 'patient';
  DateTime? _birthdate;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _dniCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    setState(() => _error = null);
    switch (_currentStep) {
      case 0:
        if (_dniCtrl.text.trim().isEmpty) {
          setState(() => _error = 'El DNI es obligatorio');
          return false;
        }
        if (_firstNameCtrl.text.trim().isEmpty) {
          setState(() => _error = 'El nombre es obligatorio');
          return false;
        }
        if (_lastNameCtrl.text.trim().isEmpty) {
          setState(() => _error = 'El apellido es obligatorio');
          return false;
        }
        return true;
      case 1:
        if (_emailCtrl.text.trim().isEmpty) {
          setState(() => _error = 'El correo es obligatorio');
          return false;
        }
        if (_passwordCtrl.text.isEmpty) {
          setState(() => _error = 'La contraseña es obligatoria');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _error = null;
      });
    }
  }

  Future<void> _pickBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: white,
              onSurface: deepTeal,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  Future<void> _handleSignUp() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final request = SignupRequest(
        dni: _dniCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        firstname: _firstNameCtrl.text.trim(),
        lastname: _lastNameCtrl.text.trim(),
        birthdate: (_birthdate ?? DateTime(2000)).toIso8601String(),
        gender: _gender,
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: _role,
      );
      await ApiService.signup(request);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── Step content builders ───────────────────────

  Widget _buildStep0() {
    return Column(
      children: [
        InputTextBox(
          label: 'DNI',
          controller: _dniCtrl,
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        InputTextBox(
          label: 'Nombre',
          controller: _firstNameCtrl,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        InputTextBox(
          label: 'Apellido',
          controller: _lastNameCtrl,
          icon: Icons.person_outline,
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        InputTextBox(
          label: 'Correo electrónico',
          controller: _emailCtrl,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        InputTextBox(
          label: 'Contraseña',
          controller: _passwordCtrl,
          obscure: true,
          icon: Icons.lock_outline,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        InputTextBox(
          label: 'Teléfono',
          controller: _phoneCtrl,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        InputTextBox(
          label: 'Dirección',
          controller: _addressCtrl,
          icon: Icons.home_outlined,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickBirthdate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Fecha de nacimiento',
              prefixIcon: const Icon(Icons.calendar_today, color: deepTeal),
              filled: true,
              fillColor: white,
              labelStyle: const TextStyle(color: deepTeal),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: softGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryBlue, width: 2),
              ),
            ),
            child: Text(
              _birthdate != null
                  ? '${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}'
                  : 'Seleccionar fecha',
              style: TextStyle(color: _birthdate != null ? deepTeal : softGray),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _gender,
          decoration: InputDecoration(
            labelText: 'Género',
            prefixIcon: const Icon(Icons.wc, color: deepTeal),
            filled: true,
            fillColor: white,
            labelStyle: const TextStyle(color: deepTeal),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: softGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryBlue, width: 2),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Masculino')),
            DropdownMenuItem(value: 'female', child: Text('Femenino')),
          ],
          onChanged: (v) => setState(() => _gender = v ?? 'male'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _role,
          decoration: InputDecoration(
            labelText: 'Rol',
            prefixIcon: const Icon(Icons.badge_outlined, color: deepTeal),
            filled: true,
            fillColor: white,
            labelStyle: const TextStyle(color: deepTeal),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: softGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryBlue, width: 2),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'patient', child: Text('Paciente')),
            DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
          ],
          onChanged: (v) => setState(() => _role = v ?? 'patient'),
        ),
      ],
    );
  }

  String get _stepTitle {
    switch (_currentStep) {
      case 0:
        return 'Datos personales';
      case 1:
        return 'Cuenta';
      case 2:
        return 'Contacto';
      case 3:
        return 'Perfil';
      default:
        return '';
    }
  }

  Widget get _currentStepContent {
    switch (_currentStep) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Progress indicator ──────────────────────────

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalSteps, (i) {
        final isActive = i == _currentStep;
        final isDone = i < _currentStep;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 32 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isDone || isActive ? primaryBlue : softGray,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            if (i < _totalSteps - 1)
              Container(
                width: 20,
                height: 2,
                color: isDone ? primaryBlue : softGray,
              ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/imgs/aldimi_logo.png', height: 80),
                const SizedBox(height: 16),
                const Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: deepTeal,
                  ),
                ),
                const SizedBox(height: 20),
                _buildProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  _stepTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentStepContent,
                ),
                const SizedBox(height: 8),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: warmCoral, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
                // Navigation buttons
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _prevStep,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryBlue,
                              side: const BorderSide(color: primaryBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Atrás'),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading
                              ? null
                              : _currentStep == _totalSteps - 1
                              ? _handleSignUp
                              : _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: white,
                                  ),
                                )
                              : Text(
                                  _currentStep == _totalSteps - 1
                                      ? 'Registrarse'
                                      : 'Siguiente',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes cuenta? ',
                      style: TextStyle(color: deepTeal),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          color: warmCoral,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
