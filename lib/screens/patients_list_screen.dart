import 'package:flutter/material.dart';
import '../themes/palette.dart';
import '../models/info_models.dart';
import '../services/api_service.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'home_doctor_screen.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  List<User> _patients = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final data = await ApiService.getUsersByRole('patient');
      setState(() {
        _patients = data.map((e) => User.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Pacientes', style: TextStyle(color: white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: warmCoral),
                  ),
                )
              : _patients.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay pacientes registrados.',
                        style: TextStyle(fontSize: 16, color: deepTeal),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _patients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final patient = _patients[index];
                        return Card(
                          color: white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: primaryBlue,
                              child: Text(
                                '${patient.firstName.isNotEmpty ? patient.firstName[0] : ''}'
                                '${patient.lastName.isNotEmpty ? patient.lastName[0] : ''}',
                                style: const TextStyle(
                                  color: white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              '${patient.firstName} ${patient.lastName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: deepTeal,
                              ),
                            ),
                            subtitle: Text(
                              patient.email,
                              style: const TextStyle(color: deepTeal),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: primaryBlue,
                            ),
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: AldimiBottomNavBar(
        currentIndex: 2,
        role: 'doctor',
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeDoctorScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}
