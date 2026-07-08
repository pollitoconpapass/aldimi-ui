import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/palette.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../services/auth_provider.dart';
import 'my_data_screen.dart';
import 'upload_documents_screen.dart';
import 'chat_history_screen.dart';
import 'signin_screen.dart';

class HomePatientScreen extends StatefulWidget {
  const HomePatientScreen({super.key});

  @override
  State<HomePatientScreen> createState() => _HomePatientScreenState();
}

class _HomePatientScreenState extends State<HomePatientScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('ALDIMI ASSIST', style: TextStyle(color: white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: white),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: AldimiBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyDataScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Bienvenid@',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A una nueva experiencia de atención.',
            style: TextStyle(fontSize: 16, color: deepTeal),
          ),
          const SizedBox(height: 30),
          _buildSection(
            icon: 'assets/icons/instructions_desk.png',
            title: 'Sube tus documentos o recetas médicas aquí.',
            buttonText: 'Probar ->',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadDocumentsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: 'assets/icons/instructions_up.png',
            title: 'Chatea con una IA que conoce todo sobre ti.',
            buttonText: 'Ir al chat ->',
            isHighlighted: true,
            imageRight: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatHistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: 'assets/icons/instructions_folder.png',
            title: 'Revisa todos tus datos médicos aquí.',
            buttonText: 'Ver datos ->',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyDataScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String icon,
    required String title,
    required String buttonText,
    required VoidCallback onTap,
    bool isHighlighted = false,
    bool imageRight = false,
  }) {
    final imageWidget = Image.asset(icon, width: 120, height: 120);

    final textWidget = Expanded(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isHighlighted ? white : deepTeal,
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isHighlighted ? primaryBlue.withAlpha(200) : white,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: imageRight
                  ? [textWidget, const SizedBox(width: 16), imageWidget]
                  : [imageWidget, const SizedBox(width: 16), textWidget],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: imageRight
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted ? white : primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
