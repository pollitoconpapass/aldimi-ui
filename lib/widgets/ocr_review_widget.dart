import 'package:flutter/material.dart';
import '../themes/palette.dart';

class OcrReviewWidget extends StatefulWidget {
  final String ocrText;
  final void Function(String correctedText) onConfirm;

  const OcrReviewWidget({
    super.key,
    required this.ocrText,
    required this.onConfirm,
  });

  @override
  State<OcrReviewWidget> createState() => _OcrReviewWidgetState();
}

class _OcrReviewWidgetState extends State<OcrReviewWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.ocrText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Texto extraído',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: deepTeal,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Revisa y corrige si es necesario',
          style: TextStyle(fontSize: 14, color: deepTeal),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 15, color: deepTeal),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'El texto extraído aparecerá aquí...',
                hintStyle: TextStyle(color: softGray),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => widget.onConfirm(_controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continuar',
              style: TextStyle(color: white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
