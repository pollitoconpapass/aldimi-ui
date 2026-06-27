import 'package:flutter/material.dart';
import '../themes/palette.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,

      body: const Center(
        child: Text(
          'Configuración',
          style: TextStyle(fontSize: 24, color: deepTeal),
        ),
      ),
    );
  }
}
