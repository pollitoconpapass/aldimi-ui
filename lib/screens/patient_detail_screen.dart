import 'package:flutter/material.dart';
import '../models/info_models.dart';
import '../themes/palette.dart';
import '../widgets/medical_report_card.dart';
import '../services/api_service.dart';
import 'medical_report_detail_screen.dart';
import 'about_patient_chat_screen.dart';
import 'upload_documents_for_patient_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final User patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  List<MedicalReport> _medicalReports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await ApiService.getUserMedicalReports(widget.patient.id);
      if (!mounted) return;
      setState(() {
        _medicalReports = reports;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  int _calculateAge() {
    final now = DateTime.now();
    int age = now.year - widget.patient.birthdate.year;
    if (now.month < widget.patient.birthdate.month ||
        (now.month == widget.patient.birthdate.month &&
            now.day < widget.patient.birthdate.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _genderLabel() {
    switch (widget.patient.gender.toLowerCase()) {
      case 'male':
        return 'Masculino';
      case 'female':
        return 'Femenino';
      default:
        return widget.patient.gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    final age = _calculateAge();

    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(
          '${patient.firstName} ${patient.lastName}',
          style: const TextStyle(color: white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Datos generales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: deepTeal,
              ),
            ),
            const SizedBox(height: 12),
            _buildDataBlock(patient, age),
            const SizedBox(height: 16),
            _buildActionButtons(context, patient),
            const SizedBox(height: 24),
            const Text(
              'Reportes médicos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: deepTeal,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: primaryBlue),
                ),
              )
            else if (_error != null)
              Center(
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: warmCoral),
                ),
              )
            else if (_medicalReports.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'Este paciente aún no tiene reportes médicos.',
                    style: TextStyle(fontSize: 16, color: deepTeal),
                  ),
                ),
              )
            else
              ..._medicalReports.map(
                (report) => MedicalReportCard(
                  report: report,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MedicalReportDetailScreen(report: report),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBlock(User patient, int age) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          _buildInfoRow(
            Icons.person,
            'Nombre',
            '${patient.firstName} ${patient.lastName}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.cake,
            'Nacimiento',
            _formatDate(patient.birthdate),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, 'Edad', '$age años'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.wc, 'Género', _genderLabel()),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email, 'Email', patient.email),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.home,
            'Dirección',
            patient.address.isNotEmpty ? patient.address : '-',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.phone,
            'Teléfono',
            patient.phone != null && patient.phone!.isNotEmpty
                ? patient.phone!
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryBlue),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: deepTeal),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: deepTeal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, User patient) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Pregunta sobre este\nusuario en específico',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientChatScreen(
                    patientId: patient.id,
                    patientName: '${patient.firstName} ${patient.lastName}',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.upload_file,
            label: 'Agregar más\ndatos',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadDocumentsForPatientScreen(
                    patientId: patient.id,
                    patientName: '${patient.firstName} ${patient.lastName}',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
            Icon(icon, size: 28, color: primaryBlue),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: deepTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
