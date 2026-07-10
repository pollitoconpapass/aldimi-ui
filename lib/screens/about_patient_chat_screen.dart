import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/info_models.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../themes/palette.dart';
import '../widgets/chat_message.dart';
import '../widgets/greeting_animation.dart';

class PatientChatScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientChatScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientChatScreen> createState() => _PatientChatScreenState();
}

class _PatientChatScreenState extends State<PatientChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  String? _sessionId;
  bool _isSending = false;
  bool _isLoadingMessages = false;

  @override
  void initState() {
    super.initState();
    _createSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _userId => context.read<AuthProvider>().user?.id ?? '';

  Future<void> _loadMessages() async {
    if (_sessionId == null) return;
    setState(() => _isLoadingMessages = true);
    try {
      final data = await ApiService.getChatMessages(_sessionId!);
      if (mounted) {
        setState(() {
          _messages.addAll(data.map((e) => ChatMessage.fromJson(e)).toList());
          _isLoadingMessages = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMessages = false);
      }
    }
  }

  Future<void> _createSession() async {
    try {
      final session = await ApiService.createChatSession(
        _userId,
        'Consulta sobre ${widget.patientName}',
      );
      if (mounted) {
        setState(() {
          _sessionId = session['id'];
        });
        _loadMessages();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear sesión: $e')));
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    if (_sessionId == null) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isSending = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final response = await ApiService.sendDoctorMessageAboutSpecificPatient(
        _sessionId!,
        _userId,
        widget.patientId,
        text,
      );
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage.fromJson(response));
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al enviar mensaje: $e')));
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: warmCoral,
        title: Text(
          'Chat sobre ${widget.patientName}',
          style: const TextStyle(color: white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingMessages
                ? const Center(
                    child: CircularProgressIndicator(color: warmCoral),
                  )
                : _messages.isEmpty
                ? const GreetingAnimation()
                : _buildMessageList(),
          ),
          if (_isSending) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: warmCoral.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Escribiendo...',
            style: TextStyle(
              fontSize: 13,
              color: deepTeal.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return MessageBubble(message: msg);
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: creamBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: softGray),
                ),
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !_isSending,
                  decoration: const InputDecoration(
                    hintText: 'Pregunta sobre el paciente...',
                    hintStyle: TextStyle(color: softGray),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: warmCoral,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: white, size: 20),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
