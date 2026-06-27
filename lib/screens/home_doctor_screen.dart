import 'package:flutter/material.dart';
import '../themes/palette.dart';

class HomeDoctorScreen extends StatelessWidget {
  const HomeDoctorScreen({super.key});

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
    );
  }
}
