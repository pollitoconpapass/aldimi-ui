import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/info_models.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../themes/palette.dart';
import 'chat_screen.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<ChatSession> _sessions = [];
  bool _isLoading = true;

  String get _userId => context.read<AuthProvider>().user?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final data = await ApiService.getChatSessions(_userId);
      if (mounted) {
        setState(() {
          _sessions = data.map((e) => ChatSession.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar sesiones: $e')),
        );
      }
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      await ApiService.deleteChatSession(sessionId);
      if (mounted) {
        setState(() {
          _sessions = _sessions.where((s) => s.id != sessionId).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  void _openSession({String? sessionId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(sessionId: sessionId),
      ),
    ).then((_) => _loadSessions());
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = context.read<AuthProvider>().user?.role == 'doctor';
    final accentColor = isDoctor ? warmCoral : primaryBlue;

    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: accentColor,
        title: const Text('Chats', style: TextStyle(color: white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () => _openSession(),
        child: const Icon(Icons.add, color: white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : _sessions.isEmpty
              ? _buildEmptyState()
              : _buildSessionList(accentColor),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: softGray),
          const SizedBox(height: 16),
          const Text(
            'No hay conversaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia un chat nuevo presionando el boton +',
            style: TextStyle(
              fontSize: 14,
              color: deepTeal.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(Color accentColor) {
    return RefreshIndicator(
      onRefresh: _loadSessions,
      color: accentColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return _SessionTile(
            session: session,
            accentColor: accentColor,
            onTap: () => _openSession(sessionId: session.id),
            onDelete: () => _confirmDelete(session),
          );
        },
      ),
    );
  }

  void _confirmDelete(ChatSession session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar chat'),
        content: Text(
          'Eliminar "${session.title ?? 'Sin titulo'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSession(session.id);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: warmCoral),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final ChatSession session;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionTile({
    required this.session,
    required this.accentColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(session.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: warmCoral,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: white),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat, color: white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title ?? 'Sin titulo',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: deepTeal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (session.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(session.createdAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: deepTeal.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: deepTeal.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) return 'Hoy';
      if (diff.inDays == 1) return 'Ayer';
      if (diff.inDays < 7) return 'Hace ${diff.inDays} dias';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
