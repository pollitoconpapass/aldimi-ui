import 'package:flutter/material.dart';
import '../models/info_models.dart';
import '../themes/palette.dart';

class MedicalReportCard extends StatelessWidget {
  final MedicalReport report;
  final VoidCallback? onTap;

  const MedicalReportCard({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${report.reportDate.day}/${report.reportDate.month}/${report.reportDate.year}';
    final preview = report.results != null && report.results!.isNotEmpty
        ? (report.results!.length > 100
              ? '${report.results!.substring(0, 100)}...'
              : report.results!)
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
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
            Row(
              children: [
                const Icon(Icons.description, size: 20, color: primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.condition,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: deepTeal,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: deepTeal),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 12, color: deepTeal),
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                preview,
                style: const TextStyle(fontSize: 13, color: deepTeal),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
