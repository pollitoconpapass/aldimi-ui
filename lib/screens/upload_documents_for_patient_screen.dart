import 'dart:io';
import 'package:flutter/material.dart';
import '../models/info_models.dart';
import '../services/api_service.dart';
import '../themes/palette.dart';
import '../widgets/image_capture_widget.dart';
import '../widgets/ocr_review_widget.dart';
import '../widgets/document_type_selector_widget.dart';
import '../widgets/structured_data_review_widget.dart';
import '../widgets/processing_step_indicator.dart';

class UploadDocumentsForPatientScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const UploadDocumentsForPatientScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<UploadDocumentsForPatientScreen> createState() =>
      _UploadDocumentsForPatientScreenState();
}

class _UploadDocumentsForPatientScreenState
    extends State<UploadDocumentsForPatientScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;

  File? _selectedImage;
  String? _ocrText;
  String? _detectedType;
  Map<String, dynamic>? _structuredData;

  static const _stepLabels = [
    'Seleccionar imagen',
    'Revisar OCR',
    'Tipo de documento',
    'Datos extraídos',
    'Guardado',
  ];

  void _showError(String message) {
    setState(() {
      _error = message;
      _isLoading = false;
    });
  }

  Future<void> _onImageSelected(File image) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedImage = image;
    });

    try {
      final text = await ApiService.ocr(image.path, 'default');
      setState(() {
        _ocrText = text;
        _currentStep = 1;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error al procesar la imagen. Intenta de nuevo.');
    }
  }

  Future<void> _onOcrConfirmed(String correctedText) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final type = await ApiService.detectDocumentType(correctedText);
      setState(() {
        _ocrText = correctedText;
        _detectedType = type;
        _currentStep = 2;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error al detectar el tipo de documento.');
    }
  }

  Future<void> _onTypeConfirmed(String selectedType) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.formatText(_ocrText!, selectedType);
      setState(() {
        _detectedType = selectedType;
        _structuredData = data;
        _currentStep = 3;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error al formatear el texto.');
    }
  }

  Future<void> _onDataConfirmed(Map<String, dynamic> correctedData) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = SavedDocumentRequest(
        userId: widget.patientId,
        documentType: _detectedType!,
        imagePath: _selectedImage?.path ?? '',
        ocrText: _ocrText!,
        dniData: _detectedType == 'dni' ? correctedData : null,
        medicalReportData: _detectedType == 'medical_report'
            ? correctedData
            : null,
      );
      await ApiService.saveDocument(request);
      setState(() {
        _currentStep = 4;
        _isLoading = false;
      });
    } catch (e) {
      _showError('Error al guardar el documento.');
    }
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _isLoading = false;
      _error = null;
      _selectedImage = null;
      _ocrText = null;
      _detectedType = null;
      _structuredData = null;
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: warmCoral,
      title: Text(
        'Subir documento a ${widget.patientName}',
        style: const TextStyle(color: white, fontSize: 16),
      ),
      leading: _currentStep > 0 && _currentStep < 4
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: white),
              onPressed: () => setState(() => _currentStep--),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: white),
              onPressed: () => Navigator.pop(context),
            ),
    );
  }

  Widget _buildStepContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: warmCoral),
            SizedBox(height: 16),
            Text(
              'Procesando...',
              style: TextStyle(fontSize: 16, color: deepTeal),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: warmCoral),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: deepTeal),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: warmCoral,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Intentar de nuevo',
                  style: TextStyle(color: white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    switch (_currentStep) {
      case 0:
        return ImageCaptureWidget(onImageSelected: _onImageSelected);
      case 1:
        return OcrReviewWidget(
          ocrText: _ocrText ?? '',
          onConfirm: _onOcrConfirmed,
        );
      case 2:
        return DocumentTypeSelectorWidget(
          detectedType: _detectedType ?? 'dni',
          onConfirm: _onTypeConfirmed,
        );
      case 3:
        return StructuredDataReviewWidget(
          documentType: _detectedType!,
          structuredData: _structuredData ?? {},
          onConfirm: _onDataConfirmed,
        );
      case 4:
        return _buildSuccessView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: warmCoral.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 56,
              color: warmCoral,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Documento guardado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El documento de ${widget.patientName} ha sido procesado exitosamente',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: deepTeal),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _reset,
              style: ElevatedButton.styleFrom(
                backgroundColor: warmCoral,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Subir otro documento',
                style: TextStyle(color: white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Volver al perfil del paciente',
              style: TextStyle(color: warmCoral, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_currentStep < 4) ...[
              ProcessingStepIndicator(currentStep: _currentStep, totalSteps: 4),
              const SizedBox(height: 4),
              Text(
                'Paso ${_currentStep + 1} de 4: ${_stepLabels[_currentStep]}',
                style: const TextStyle(fontSize: 13, color: deepTeal),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(child: _buildStepContent()),
          ],
        ),
      ),
    );
  }
}
