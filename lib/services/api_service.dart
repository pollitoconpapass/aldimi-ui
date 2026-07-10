import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/info_models.dart';

class ApiService {
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static Map<String, String> _headers() => {'Content-Type': 'application/json'};

  // == Health Check ===

  static Future<Map<String, dynamic>> healthCheck() async {
    final res = await http.get(Uri.parse('$_baseUrl/'), headers: _headers());
    return jsonDecode(res.body);
  }

  // == Auth ===

  static Future<Map<String, dynamic>> signup(SignupRequest request) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/signup'),
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode != 201) {
      throw Exception(body['detail'] ?? 'Error al registrar usuario');
    }
    return body;
  }

  static Future<Map<String, dynamic>> login(LogInRequest request) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode == 401) throw Exception('Credenciales inválidas');
    return jsonDecode(res.body);
  }

  // === Chat ===

  static Future<List<dynamic>> getChatSessions(String userId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/chat/sessions/$userId'),
      headers: _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createChatSession(
    String userId,
    String title,
  ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/chat/sessions'),
      headers: _headers(),
      body: jsonEncode({'user_id': userId, 'title': title}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getChatSessionDetail(
    String sessionId,
  ) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/chat/sessions/detail/$sessionId'),
      headers: _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteChatSession(
    String sessionId,
  ) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/chat/sessions/$sessionId'),
      headers: _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getChatMessages(String sessionId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/chat/messages/$sessionId'),
      headers: _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> sendMessage(
    String sessionId,
    String userId,
    String content,
  ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/chat/messages'),
      headers: _headers(),
      body: jsonEncode({
        'session_id': sessionId,
        'user_id': userId,
        'content': content,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> sendDoctorMessage(
    String sessionId,
    String userId,
    String content,
  ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/chat/doctor/messages'),
      headers: _headers(),
      body: jsonEncode({
        'session_id': sessionId,
        'user_id': userId,
        'content': content,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> sendDoctorMessageAboutSpecificPatient(
    String sessionId,
    String userId,
    String patientId,
    String content,
  ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/chat/doctor/messages/patient/$patientId'),
      headers: _headers(),
      body: jsonEncode({
        'session_id': sessionId,
        'user_id': userId,
        'content': content,
      }),
    );
    return jsonDecode(res.body);
  }

  // === Users ===

  static Future<List<dynamic>> getAllUsers() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/'),
      headers: _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<dynamic> getUserById(String userId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<dynamic> getUserByEmail(String email) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/email/$email'),
      headers: _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getUsersByRole(String role) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/role/$role'),
      headers: _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<dynamic> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: _headers(),
    );
    return jsonDecode(res.body);
  }

  // === Vision and Document Processing ===

  static Future<String> ocr(String filePath, String mode) async {
    final uri = Uri.parse('$_baseUrl/vision/ocr');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', filePath))
      ..fields['mode'] = mode;
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception('Error al procesar OCR');
    }
    return res.body;
  }

  static Future<String> detectDocumentType(String text) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/vision/detect-type'),
      headers: _headers(),
      body: jsonEncode({'text': text}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> formatText(
    String ocrText,
    String documentType,
  ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/vision/format-text'),
      headers: _headers(),
      body: jsonEncode({'ocr_text': ocrText, 'document_type': documentType}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> saveDocument(
    SavedDocumentRequest request,
  ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/vision/save'),
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode != 200) {
      final detail =
          jsonDecode(res.body)['detail'] ?? 'Error al guardar documento';
      throw Exception(detail);
    }
    return jsonDecode(res.body);
  }

  // === User Documents ===

  static Future<List<dynamic>> getUserDocuments(String userId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/$userId/documents'),
      headers: _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getUserDocumentsByType(
    String userId,
    String docType,
  ) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/$userId/documents/$docType'),
      headers: _headers(),
    );
    return jsonDecode(res.body);
  }

  // === User Medical Reports ===

  static Future<List<MedicalReport>> getUserMedicalReports(
    String userId,
  ) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/$userId/medical_reports'),
      headers: _headers(),
    );
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => MedicalReport.fromJson(e)).toList();
  }

  static Future<MedicalReport> getMedicalReportById(
    String userId,
    String reportId,
  ) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/$userId/medical_reports/$reportId'),
      headers: _headers(),
    );
    return MedicalReport.fromJson(jsonDecode(res.body));
  }

  // === User DNI ===

  static Future<Dni> getUserDni(String userId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/$userId/dni'),
      headers: _headers(),
    );
    return Dni.fromJson(jsonDecode(res.body));
  }
}
