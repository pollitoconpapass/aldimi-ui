import 'package:flutter/material.dart';
import '../themes/palette.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'patients_list_screen.dart';

class HomeDoctorScreen extends StatefulWidget {
  const HomeDoctorScreen({super.key});

  @override
  State<HomeDoctorScreen> createState() => _HomeDoctorScreenState();
}

class _HomeDoctorScreenState extends State<HomeDoctorScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Aldimi', style: TextStyle(color: white)),
      ),
      body: const Center(
        child: Text(
          'Bienvenido Dr.',
          style: TextStyle(fontSize: 24, color: deepTeal),
        ),
      ),
      bottomNavigationBar: AldimiBottomNavBar(
        currentIndex: _currentIndex,
        role: 'doctor',
        onTap: (index) {
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PatientsListScreen(),
              ),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
