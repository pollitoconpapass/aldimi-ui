import 'package:flutter/material.dart';
import '../themes/palette.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'configuration_screen.dart';
import 'my_data_screen.dart';

class HomePatientScreen extends StatefulWidget {
  const HomePatientScreen({super.key});

  @override
  State<HomePatientScreen> createState() => _HomePatientScreenState();
}

class _HomePatientScreenState extends State<HomePatientScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Aldimi', style: TextStyle(color: white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfigurationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: AldimiBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyDataScreen()),
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

  Widget _buildBody() {
    return const Center(
      child: Text(
        'Bienvenido',
        style: TextStyle(fontSize: 24, color: deepTeal),
      ),
    );
  }
}
