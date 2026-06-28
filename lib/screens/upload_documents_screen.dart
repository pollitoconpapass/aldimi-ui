import 'package:flutter/material.dart';
import '../themes/palette.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({super.key});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      body: const Center(
        child: Text(
          'Subir Documentos',
          style: TextStyle(fontSize: 24, color: deepTeal),
        ),
      ),
    );
  }
}
