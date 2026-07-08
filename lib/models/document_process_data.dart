class DniData {
  final String names;
  final String paternalLastname;
  final String maternalLastname;
  final String dateOfBirth;
  final String gender;

  const DniData({
    required this.names,
    required this.paternalLastname,
    required this.maternalLastname,
    required this.dateOfBirth,
    required this.gender,
  });

  factory DniData.fromJson(Map<String, dynamic> json) {
    return DniData(
      names: json['names'] ?? '',
      paternalLastname: json['paternal_lastname'] ?? '',
      maternalLastname: json['maternal_lastname'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'names': names,
    'paternal_lastname': paternalLastname,
    'maternal_lastname': maternalLastname,
    'date_of_birth': dateOfBirth,
    'gender': gender,
  };

  DniData copyWith({
    String? names,
    String? paternalLastname,
    String? maternalLastname,
    String? dateOfBirth,
    String? gender,
  }) {
    return DniData(
      names: names ?? this.names,
      paternalLastname: paternalLastname ?? this.paternalLastname,
      maternalLastname: maternalLastname ?? this.maternalLastname,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }
}

class MedicalReportData {
  final String reportDate;
  final String condition;
  final String results;
  final List<Map<String, dynamic>> medications;

  const MedicalReportData({
    required this.reportDate,
    required this.condition,
    required this.results,
    required this.medications,
  });

  factory MedicalReportData.fromJson(Map<String, dynamic> json) {
    return MedicalReportData(
      reportDate: json['report_date'] ?? '',
      condition: json['condition'] ?? '',
      results: json['results'] ?? '',
      medications: json['medications'] != null
          ? List<Map<String, dynamic>>.from(json['medications'])
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'report_date': reportDate,
    'condition': condition,
    'results': results,
    'medications': medications,
  };

  MedicalReportData copyWith({
    String? reportDate,
    String? condition,
    String? results,
    List<Map<String, dynamic>>? medications,
  }) {
    return MedicalReportData(
      reportDate: reportDate ?? this.reportDate,
      condition: condition ?? this.condition,
      results: results ?? this.results,
      medications: medications ?? this.medications,
    );
  }
}
