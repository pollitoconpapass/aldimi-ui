import 'package:flutter/material.dart';
import '../themes/palette.dart';

class DocumentTypeSelectorWidget extends StatefulWidget {
  final String detectedType;
  final void Function(String selectedType) onConfirm;

  const DocumentTypeSelectorWidget({
    super.key,
    required this.detectedType,
    required this.onConfirm,
  });

  @override
  State<DocumentTypeSelectorWidget> createState() =>
      _DocumentTypeSelectorWidgetState();
}

class _DocumentTypeSelectorWidgetState
    extends State<DocumentTypeSelectorWidget> {
  late String _selectedType;
  final List<Map<String, dynamic>> _types = const [
    {'value': 'dni', 'label': 'DNI', 'icon': Icons.badge_outlined},
    {
      'value': 'medical_report',
      'label': 'Reporte Médico',
      'icon': Icons.medical_information_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.detectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de documento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: deepTeal,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Selecciona o corrige el tipo detectado',
          style: TextStyle(fontSize: 14, color: deepTeal),
        ),
        const SizedBox(height: 24),
        ..._types.map((type) {
          final isSelected = _selectedType == type['value'];
          return GestureDetector(
            onTap: () => setState(() => _selectedType = type['value']),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? primaryBlue.withAlpha(20) : white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primaryBlue : softGray,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    type['icon'] as IconData,
                    color: isSelected ? primaryBlue : deepTeal,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      type['label'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? primaryBlue : deepTeal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: primaryBlue,
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        }),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => widget.onConfirm(_selectedType),
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
