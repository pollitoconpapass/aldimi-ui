import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/palette.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../services/auth_provider.dart';
import 'patients_list_screen.dart';
import 'signin_screen.dart';
import 'chat_screen.dart';

class HomeDoctorScreen extends StatefulWidget {
  const HomeDoctorScreen({super.key});

  @override
  State<HomeDoctorScreen> createState() => _HomeDoctorScreenState();
}

class _HomeDoctorScreenState extends State<HomeDoctorScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: warmCoral,
        title: const Text('ALDIMI DOCTOR', style: TextStyle(color: white)),
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
        role: 'doctor',
        onTap: (index) {
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PatientsListScreen(),
              ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/imgs/aldimi_logo.png',
              width: 150,
              height: 150,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bienvenido Dr.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: deepTeal,
            ),
          ),
          const SizedBox(height: 30),
          _buildSection(
            icon: 'assets/icons/instructions_up.png',
            title: 'Conversa con el chat para brindarte apoyo.',
            buttonText: 'Ir al chat ->',
            isHighlighted: true,
            imageRight: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: 'assets/icons/instructions_folder.png',
            title:
                'Registro de tus pacientes. Mira aquí los datos de cada uno y conversa con una IA sobre ese paciente en específico.',
            buttonText: 'Ver pacientes ->',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientsListScreen(),
                ),
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
          color: isHighlighted ? warmCoral.withAlpha(200) : white,
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
                  color: isHighlighted ? white : warmCoral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
