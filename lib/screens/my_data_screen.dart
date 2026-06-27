import 'package:flutter/material.dart';
import '../themes/palette.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'home_patient_screen.dart';

class MyDataScreen extends StatefulWidget {
  const MyDataScreen({super.key});

  @override
  State<MyDataScreen> createState() => _MyDataScreenState();
}

class _MyDataScreenState extends State<MyDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      body: const Center(
        child: Text('Datos', style: TextStyle(fontSize: 24, color: deepTeal)),
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
          } else if (index == 2) {
            // Already on Datos, do nothing
          }
        },
      ),
    );
  }
}
