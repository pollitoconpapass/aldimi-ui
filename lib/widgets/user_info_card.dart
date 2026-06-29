import 'package:flutter/material.dart';
import '../models/info_models.dart';
import '../themes/palette.dart';

class UserInfoCard extends StatelessWidget {
  final User user;

  const UserInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final birthdate = user.birthdate;
    final now = DateTime.now();
    int calculatedAge = now.year - birthdate.year;
    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      calculatedAge--;
    }
    final age = calculatedAge.toString();

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
        children: [
          _buildInfoRow(
            Icons.person,
            'Nombre',
            '${user.firstName} ${user.lastName}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.cake, 'Edad', '$age años'),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.wc,
            'Género',
            user.gender.isNotEmpty ? user.gender : '-',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.phone,
            'Teléfono',
            user.phone != null && user.phone!.isNotEmpty ? user.phone! : '-',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email, 'Email', user.email),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryBlue),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: deepTeal),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: deepTeal,
            ),
          ),
        ),
      ],
    );
  }
}
