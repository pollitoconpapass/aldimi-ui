import 'dart:io';
import 'package:flutter/material.dart';
import '../models/info_models.dart';
import '../services/api_service.dart';
import '../themes/palette.dart';
import '../widgets/image_capture_widget.dart';
import '../widgets/ocr_review_widget.dart';
import '../widgets/processing_step_indicator.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;

  // Auth fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Patient fields
  final _dniController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _birthdate;
  String _gender = 'male';

  // Scan flow fields
  File? _selectedImage;
  String? _ocrText;
  Map<String, dynamic>? _structuredData;

  bool _useManualEntry = true;

  static const _stepLabels = ['Credenciales', 'Datos del paciente', 'Guardado'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _dniController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _error = message;
      _isLoading = false;
    });
  }

  void _onMethodSelected(bool manual) {
    setState(() {
      _useManualEntry = manual;
      _currentStep = 1;
      _error = null;
    });
  }

  // === Scan Flow ===

  Future<void> _onImageSelected(File image) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedImage = image;
    });

    try {
      final text = await ApiService.ocr(image.path, 'default');
      setState(() {
        _ocrText = text;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error al procesar la imagen. Intenta de nuevo.');
    }
  }

  Future<void> _onOcrConfirmed(String correctedText) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.formatText(correctedText, 'dni');
      setState(() {
        _ocrText = correctedText;
        _structuredData = data;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error al formatear el texto.');
    }
  }

  // === User Creation ===

  Future<void> _createUser({Map<String, dynamic>? dniData}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String dni;
      String firstName;
      String lastName;
      String birthdateStr;
      String gender;
      String address;
      String phone;

      if (dniData != null) {
        dni = dniData['id'] ?? '';
        firstName = dniData['names'] ?? '';
        final paternal = dniData['paternal_lastname'] ?? '';
        final maternal = dniData['maternal_lastname'] ?? '';
        lastName = '$paternal $maternal'.trim();
        birthdateStr = dniData['date_of_birth'] ?? '';
        gender = dniData['gender'] ?? 'male';
        address = _addressController.text.isNotEmpty
            ? _addressController.text
            : '';
        phone = _phoneController.text.isNotEmpty
            ? _phoneController.text
            : '';
      } else {
        dni = _dniController.text.trim();
        firstName = _firstNameController.text.trim();
        lastName = _lastNameController.text.trim();
        birthdateStr = _birthdate != null ? _birthdate!.toIso8601String() : '';
        gender = _gender;
        address = _addressController.text.trim();
        phone = _phoneController.text.trim();
      }

      if (dni.isEmpty ||
          firstName.isEmpty ||
          lastName.isEmpty ||
          birthdateStr.isEmpty) {
        _showError(
          'DNI, nombre, apellido y fecha de nacimiento son obligatorios.',
        );
        return;
      }

      final request = SignupRequest(
        dni: dni,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstname: firstName,
        lastname: lastName,
        birthdate: birthdateStr,
        gender: gender,
        address: address,
        phone: phone,
        role: 'patient',
      );

      await ApiService.signup(request);

      // Save DNI document if scanned
      if (dniData != null && _selectedImage != null) {
        try {
          final docRequest = SavedDocumentRequest(
            userId: dni,
            documentType: 'dni',
            imagePath: _selectedImage!.path,
            ocrText: _ocrText ?? '',
            dniData: dniData,
          );
          await ApiService.saveDocument(docRequest);
        } catch (e) {
          // DNI save failed, but user was created
        }
      }

      if (mounted) {
        setState(() {
          _currentStep = 2;
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError('Error al crear el paciente: $e');
    }
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _isLoading = false;
      _error = null;
      _selectedImage = null;
      _ocrText = null;
      _structuredData = null;
      _useManualEntry = true;
      _emailController.clear();
      _passwordController.clear();
      _dniController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _birthdate = null;
      _gender = 'male';
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: warmCoral,
      title: const Text('Agregar paciente', style: TextStyle(color: white)),
      leading: _currentStep > 0 && _currentStep < 2
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: white),
              onPressed: () => setState(() => _currentStep--),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: white),
              onPressed: () => Navigator.pop(context),
            ),
    );
  }

  Widget _buildStepContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: warmCoral),
            SizedBox(height: 16),
            Text(
              'Procesando...',
              style: TextStyle(fontSize: 16, color: deepTeal),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: warmCoral),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: deepTeal),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: warmCoral,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Intentar de nuevo',
                  style: TextStyle(color: white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    switch (_currentStep) {
      case 0:
        return _buildCredentialsStep();
      case 1:
        return _useManualEntry ? _buildManualFormStep() : _buildScanStep();
      case 2:
        return _buildSuccessView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCredentialsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Credenciales de acceso',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'El paciente usará estos datos para iniciar sesión.',
            style: TextStyle(fontSize: 14, color: deepTeal),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _emailController,
            label: 'Correo electrónico',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Contraseña',
            icon: Icons.lock,
            obscure: true,
          ),
          const SizedBox(height: 32),
          const Text(
            '¿Cómo deseas ingresar los datos?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMethodCard(
                  icon: Icons.edit,
                  label: 'Ingresar datos\nmanualmente',
                  onTap: () => _onMethodSelected(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMethodCard(
                  icon: Icons.camera_alt,
                  label: 'Escanear\nDNI',
                  onTap: () => _onMethodSelected(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: warmCoral),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: deepTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualFormStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos del paciente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _dniController,
            label: 'DNI',
            icon: Icons.badge,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _firstNameController,
            label: 'Nombre(s)',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _lastNameController,
            label: 'Apellido(s)',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildDateField(),
          const SizedBox(height: 16),
          _buildGenderField(),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Dirección',
            icon: Icons.home,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Teléfono',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _createUser(),
              style: ElevatedButton.styleFrom(
                backgroundColor: warmCoral,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Crear paciente',
                style: TextStyle(color: white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanStep() {
    if (_structuredData != null) {
      return _buildScanReviewStep();
    }
    if (_ocrText != null) {
      return OcrReviewWidget(ocrText: _ocrText!, onConfirm: _onOcrConfirmed);
    }
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Escanea el DNI del paciente',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: deepTeal,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Los datos se extraerán automáticamente.',
          style: TextStyle(fontSize: 14, color: softGray),
        ),
        const SizedBox(height: 24),
        Expanded(child: ImageCaptureWidget(onImageSelected: _onImageSelected)),
      ],
    );
  }

  Widget _buildScanReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos extraídos del DNI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verifica que los datos sean correctos.',
            style: TextStyle(fontSize: 14, color: deepTeal),
          ),
          const SizedBox(height: 24),
          _buildReviewField('Nombre', _structuredData!['names'] ?? ''),
          const SizedBox(height: 12),
          _buildReviewField(
            'Apellido paterno',
            _structuredData!['paternal_lastname'] ?? '',
          ),
          const SizedBox(height: 12),
          _buildReviewField(
            'Apellido materno',
            _structuredData!['maternal_lastname'] ?? '',
          ),
          const SizedBox(height: 12),
          _buildReviewField(
            'Fecha de nacimiento',
            _structuredData!['date_of_birth'] ?? '',
          ),
          const SizedBox(height: 12),
          _buildReviewField(
            'Género',
            _structuredData!['gender'] == 'male' ? 'Masculino' : 'Femenino',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Dirección (opcional)',
            icon: Icons.home,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Teléfono (opcional)',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _createUser(dniData: _structuredData),
              style: ElevatedButton.styleFrom(
                backgroundColor: warmCoral,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Crear paciente',
                style: TextStyle(color: white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: warmCoral)),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: deepTeal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: warmCoral),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warmCoral),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _birthdate ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _birthdate = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de nacimiento',
          prefixIcon: const Icon(Icons.cake, color: warmCoral),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _birthdate != null
              ? '${_birthdate!.day.toString().padLeft(2, '0')}/${_birthdate!.month.toString().padLeft(2, '0')}/${_birthdate!.year}'
              : 'Seleccionar fecha',
          style: TextStyle(color: _birthdate != null ? deepTeal : softGray),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      initialValue: _gender,
      decoration: InputDecoration(
        labelText: 'Género',
          prefixIcon: const Icon(Icons.wc, color: warmCoral),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'male', child: Text('Masculino')),
        DropdownMenuItem(value: 'female', child: Text('Femenino')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _gender = value);
        }
      },
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: warmCoral.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 56,
              color: warmCoral,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Paciente creado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'El paciente ha sido registrado exitosamente',
            style: TextStyle(fontSize: 14, color: deepTeal),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _reset,
              style: ElevatedButton.styleFrom(
                backgroundColor: warmCoral,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Agregar otro paciente',
                style: TextStyle(color: white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Volver a la lista',
              style: TextStyle(color: warmCoral, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_currentStep < 2) ...[
              ProcessingStepIndicator(currentStep: _currentStep, totalSteps: 2),
              const SizedBox(height: 4),
              Text(
                'Paso ${_currentStep + 1} de 2: ${_stepLabels[_currentStep]}',
                style: const TextStyle(fontSize: 13, color: deepTeal),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(child: _buildStepContent()),
          ],
        ),
      ),
    );
  }
}
