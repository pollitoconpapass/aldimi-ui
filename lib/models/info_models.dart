class User {
  final String id;
  final String dni;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final DateTime birthdate;
  final String gender;
  final String address;
  final String? phone;
  final String role;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.dni,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    required this.birthdate,
    required this.gender,
    required this.address,
    this.phone,
    required this.role,
    this.createdAt,
  });

  // From the Get User Response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      dni: json['dni'] ?? '',
      email: json['email'] ?? '',
      passwordHash: json['password_hash'] ?? '',
      firstName: json['firstname'] ?? '',
      lastName: json['lastname'] ?? '',
      birthdate: DateTime.parse(json['birthdate'] ?? ''),
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? ''),
    );
  }

  Map<String, String> toJson() {
    return {
      'id': id,
      'dni': dni,
      'email': email,
      'password_hash': passwordHash,
      'firstname': firstName,
      'lastname': lastName,
      'birthdate': birthdate.toString(),
      'gender': gender,
      'adress': address,
      'phone': phone ?? '',
      'role': role,
      'created_at': createdAt.toString(),
    };
  }

  Map<String, dynamic> toJsonStorage() {
    return {
      'id': id,
      'dni': dni,
      'email': email,
      'firstname': firstName,
      'lastname': lastName,
      'birthdate': birthdate.toIso8601String(),
      'gender': gender,
      'address': address,
      'phone': phone ?? '',
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class SignupRequest {
  final String dni;
  final String email;
  final String password;
  final String firstname;
  final String lastname;
  final String birthdate;
  final String gender;
  final String address;
  final String? phone;
  final String role;

  SignupRequest({
    required this.dni,
    required this.email,
    required this.password,
    required this.firstname,
    required this.lastname,
    required this.birthdate,
    required this.gender,
    required this.address,
    this.phone,
    required this.role,
  });

  Map<String, String> toJson() {
    return {
      'dni': dni,
      'email': email,
      'password': password,
      'firstname': firstname,
      'lastname': lastname,
      'birthdate': birthdate,
      'gender': gender,
      'address': address,
      'phone': phone ?? '',
      'role': role,
    };
  }
}

class LogInRequest {
  final String email;
  final String password;

  LogInRequest({required this.email, required this.password});

  // To the LogIn Request
  // only toJson because we send the body to the server
  Map<String, String> toJson() {
    return {'email': email, 'password': password};
  }
}

class OCRRequest {
  final String image;
  final String? mode;

  OCRRequest({required this.image, this.mode});

  Map<String, String> toJson() {
    return {'image': image, 'mode': mode ?? ''};
  }
}

class DocumentTypeRequest {
  final String type;

  DocumentTypeRequest({required this.type});

  Map<String, String> toJson() {
    return {'type': type};
  }
}

class MedicalReport {
  final String id;
  final String documentId;
  final DateTime reportDate;
  final String condition;
  final String? results;
  final List<Map<String, dynamic>>? medications;

  MedicalReport({
    required this.id,
    required this.documentId,
    required this.reportDate,
    required this.condition,
    this.results,
    this.medications,
  });

  factory MedicalReport.fromJson(Map<String, dynamic> json) {
    return MedicalReport(
      id: json['id'] ?? '',
      documentId: json['document_id'] ?? '',
      reportDate: DateTime.parse(json['report_date'] ?? ''),
      condition: json['condition'] ?? '',
      results: json['results'],
      medications: json['medications'] != null
          ? List<Map<String, dynamic>>.from(json['medications'])
          : null,
    );
  }
}

class Dni {
  final String id;
  final String documentId;
  final String names;
  final String paternalLastname;
  final String maternalLastname;
  final DateTime dateOfBirth;
  final String gender;

  Dni({
    required this.id,
    required this.documentId,
    required this.names,
    required this.paternalLastname,
    required this.maternalLastname,
    required this.dateOfBirth,
    required this.gender,
  });

  factory Dni.fromJson(Map<String, dynamic> json) {
    return Dni(
      id: json['id'] ?? '',
      documentId: json['document_id'] ?? '',
      names: json['names'] ?? '',
      paternalLastname: json['paternal_lastname'] ?? '',
      maternalLastname: json['maternal_lastname'] ?? '',
      dateOfBirth: DateTime.parse(json['date_of_birth'] ?? ''),
      gender: json['gender'] ?? '',
    );
  }

  String get fullName => '$names $paternalLastname $maternalLastname';
}

class SavedDocumentRequest {
  final String userId;
  final String documentType;
  final String? imagePath;
  final String ocrText;

  SavedDocumentRequest({
    required this.userId,
    required this.documentType,
    this.imagePath,
    required this.ocrText,
  });

  Map<String, String> toJson() {
    return {
      'user_id': userId,
      'document_type': documentType,
      'image_path': imagePath ?? '',
      'ocr_text': ocrText,
    };
  }
}

class ChatSession {
  final String id;
  final String userId;
  final String? title;
  final String? createdAt;
  final int messageCount;

  const ChatSession({
    required this.id,
    required this.userId,
    this.title,
    this.createdAt,
    this.messageCount = 0,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'],
      createdAt: json['created_at'],
      messageCount: json['message_count'] ?? 0,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? id;
  final String? sessionId;
  final String? userId;
  final String? createdAt;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.id,
    this.sessionId,
    this.userId,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['content'] ?? '',
      isUser: json['role'] == 'user',
      id: json['id'],
      sessionId: json['session_id'],
      userId: json['user_id'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'content': text,
    'role': isUser ? 'user' : 'ai',
  };
}
