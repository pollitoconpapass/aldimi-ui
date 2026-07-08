import 'package:flutter/material.dart';

import '../themes/palette.dart';

class StructuredDataReviewWidget extends StatefulWidget {
  final String documentType;
  final Map<String, dynamic> structuredData;
  final void Function(Map<String, dynamic> correctedData) onConfirm;

  const StructuredDataReviewWidget({
    super.key,
    required this.documentType,
    required this.structuredData,
    required this.onConfirm,
  });

  @override
  State<StructuredDataReviewWidget> createState() =>
      _StructuredDataReviewWidgetState();
}

class _StructuredDataReviewWidgetState
    extends State<StructuredDataReviewWidget> {
  late Map<String, TextEditingController> _controllers;
  List<Map<String, dynamic>> _medications = [];

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (final entry in widget.structuredData.entries) {
      if (entry.key == 'medications') {
        if (entry.value is List) {
          _medications = List<Map<String, dynamic>>.from(
            entry.value.map((e) => Map<String, dynamic>.from(e as Map)),
          );
        }
        continue;
      }
      final value = entry.value;
      if (value is String) {
        _controllers[entry.key] = TextEditingController(text: value);
      } else {
        _controllers[entry.key] = TextEditingController(
          text: value?.toString() ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  String _labelFor(String key) {
    const labels = {
      'names': 'Nombres',
      'paternal_lastname': 'Apellido Paterno',
      'maternal_lastname': 'Apellido Materno',
      'date_of_birth': 'Fecha de Nacimiento',
      'gender': 'Género',
      'report_date': 'Fecha del Reporte',
      'condition': 'Condición',
      'results': 'Resultados',
    };
    return labels[key] ?? key.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos estructurados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: deepTeal,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Verifica la información extraída',
          style: TextStyle(fontSize: 14, color: deepTeal),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._controllers.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: entry.value,
                        style: const TextStyle(fontSize: 15, color: deepTeal),
                        decoration: InputDecoration(
                          labelText: _labelFor(entry.key),
                          labelStyle: const TextStyle(color: deepTeal),
                          filled: true,
                          fillColor: creamBackground,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: softGray),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_medications.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _labelFor('medications'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: deepTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._medications.map((med) {
                      final name = med['name'] ?? med['nombre'] ?? '';
                      final dose = med['dose'] ?? med['dosis'] ?? '';
                      final freq =
                          med['frequency'] ?? med['frecuencia'] ?? '';
                      final parts = <String>[
                        if (name.toString().isNotEmpty) name.toString(),
                        if (dose.toString().isNotEmpty) dose.toString(),
                        if (freq.toString().isNotEmpty) freq.toString(),
                      ];
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: creamBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: softGray),
                        ),
                        child: Text(
                          parts.join(' — '),
                          style: const TextStyle(
                            fontSize: 14,
                            color: deepTeal,
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final data = <String, dynamic>{};
              for (final entry in _controllers.entries) {
                data[entry.key] = entry.value.text;
              }
              if (_medications.isNotEmpty) {
                data['medications'] = _medications;
              }
              widget.onConfirm(data);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirmar y guardar',
              style: TextStyle(color: white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
