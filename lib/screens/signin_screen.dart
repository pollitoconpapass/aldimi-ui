import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/palette.dart';
import '../widgets/input_text_box.dart';
import '../models/info_models.dart';
import '../services/auth_provider.dart';
import 'signup_screen.dart';
import 'home_patient_screen.dart';
import 'home_doctor_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final req = LogInRequest(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      await context.read<AuthProvider>().login(req);
      if (!mounted) return;
      final isDoctor = context.read<AuthProvider>().user?.role == 'doctor';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              isDoctor ? const HomeDoctorScreen() : const HomePatientScreen(),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/imgs/aldimi_logo.png', height: 120),
                const SizedBox(height: 32),
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: deepTeal,
                  ),
                ),
                const SizedBox(height: 24),
                InputTextBox(
                  label: 'Correo electrónico',
                  controller: _emailCtrl,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                InputTextBox(
                  label: 'Contraseña',
                  controller: _passwordCtrl,
                  obscure: true,
                  icon: Icons.lock_outline,
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
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleLogin,
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
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: deepTeal),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Regístrate',
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
