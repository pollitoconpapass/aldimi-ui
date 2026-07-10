import 'package:flutter/material.dart';
import '../models/info_models.dart';
import '../themes/palette.dart';

class PatientCard extends StatelessWidget {
  final User patient;
  final VoidCallback? onTap;

  const PatientCard({super.key, required this.patient, this.onTap});

  int _calculateAge() {
    final now = DateTime.now();
    int age = now.year - patient.birthdate.year;
    if (now.month < patient.birthdate.month ||
        (now.month == patient.birthdate.month && now.day < patient.birthdate.day)) {
      age--;
    }
    return age;
  }

  String _genderLabel() {
    switch (patient.gender.toLowerCase()) {
      case 'male':
        return 'Masculino';
      case 'female':
        return 'Femenino';
      default:
        return patient.gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = _calculateAge();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: primaryBlue,
            child: Text(
              '${patient.firstName.isNotEmpty ? patient.firstName[0] : ''}'
              '${patient.lastName.isNotEmpty ? patient.lastName[0] : ''}',
              style: const TextStyle(color: white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            '${patient.firstName} ${patient.lastName}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: deepTeal),
          ),
          subtitle: Text(
            '$age años · ${_genderLabel()}',
            style: const TextStyle(color: deepTeal),
          ),
          trailing: const Icon(Icons.chevron_right, color: primaryBlue),
        ),
      ),
    );
  }
}
