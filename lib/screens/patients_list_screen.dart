import 'package:flutter/material.dart';
import '../themes/palette.dart';
import '../models/info_models.dart';
import '../services/api_service.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/patient_card.dart';
import 'home_doctor_screen.dart';
import 'patient_detail_screen.dart';

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
                  : Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          color: primaryBlue.withValues(alpha: 0.08),
                          child: Column(
                            children: const [
                              Text(
                                'Aquí podrás ver los resultados de todos los pacientes',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: deepTeal,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Para saber más de ellos solo dale click a su perfil',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: softGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _patients.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return PatientCard(
                                patient: _patients[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PatientDetailScreen(
                                        patient: _patients[index],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
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
