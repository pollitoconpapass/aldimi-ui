import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/palette.dart';

class ImageCaptureWidget extends StatelessWidget {
  final void Function(File image) onImageSelected;

  const ImageCaptureWidget({super.key, required this.onImageSelected});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      onImageSelected(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryBlue.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.document_scanner_outlined,
              size: 56,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Sube un documento o toma una foto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aceptamos DNI, reportes médicos y recetas',
            style: TextStyle(fontSize: 14, color: deepTeal),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(context, ImageSource.camera),
              icon: const Icon(Icons.camera_alt, color: white),
              label: const Text(
                'Tomar foto',
                style: TextStyle(color: white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library, color: primaryBlue),
              label: const Text(
                'Elegir de galería',
                style: TextStyle(color: primaryBlue, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
