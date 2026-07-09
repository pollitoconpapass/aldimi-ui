import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/info_models.dart';
import '../themes/palette.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/user_info_card.dart';
import '../widgets/medical_report_card.dart';
import '../widgets/pull_to_refresh.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import 'home_patient_screen.dart';
import 'upload_documents_screen.dart';
import 'medical_report_detail_screen.dart';

class MyDataScreen extends StatefulWidget {
  const MyDataScreen({super.key});

  @override
  State<MyDataScreen> createState() => _MyDataScreenState();
}

class _MyDataScreenState extends State<MyDataScreen> {
  List<MedicalReport> _medicalReports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) return;

      final reports = await ApiService.getUserMedicalReports(user.id);
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('ALDIMI ASSIST', style: TextStyle(color: white)),
      ),
      body: PullToRefresh(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Mis datos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: deepTeal,
                ),
              ),
              const SizedBox(height: 16),
              if (user != null) UserInfoCard(user: user),
              const SizedBox(height: 24),
              const Text(
                'Reportes médicos',
                style: TextStyle(
                  fontSize: 18,
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
                      'Aún no tienes datos.',
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
      ),
      bottomNavigationBar: AldimiBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePatientScreen(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UploadDocumentsScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: white, size: 28),
      ),
    );
  }
}
