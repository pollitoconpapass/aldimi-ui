import 'package:flutter/material.dart';
import '../models/info_models.dart';
import '../themes/palette.dart';

class MedicalReportDetailScreen extends StatelessWidget {
  final MedicalReport report;

  const MedicalReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${report.reportDate.day}/${report.reportDate.month}/${report.reportDate.year}';

    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(report.condition, style: const TextStyle(color: white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha: $dateStr',
              style: const TextStyle(fontSize: 14, color: deepTeal),
            ),
            const SizedBox(height: 20),
            _buildSection('Condición', report.condition),
            if (report.results != null && report.results!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection('Resultados', report.results!),
            ],
            if (report.medications != null &&
                report.medications!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Medicamentos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: deepTeal,
                ),
              ),
              const SizedBox(height: 8),
              ...report.medications!.map(
                (med) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    med['name'] ?? med.toString(),
                    style: const TextStyle(fontSize: 14, color: deepTeal),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: deepTeal, height: 1.6),
          ),
        ],
      ),
    );
  }
}
