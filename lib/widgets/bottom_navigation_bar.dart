import 'package:flutter/material.dart';
import '../themes/palette.dart';
import '../screens/chat_screen.dart';

class AldimiBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String role;

  const AldimiBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.role = 'patient',
  });

  @override
  Widget build(BuildContext context) {
    final isDoctor = role == 'doctor';
    final accentColor = isDoctor ? warmCoral : primaryBlue;

    return Container(
      decoration: const BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'Principal',
                isSelected: currentIndex == 0,
                accentColor: accentColor,
                onTap: () => onTap(0),
              ),
              _ChatButton(
                accentColor: accentColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                },
              ),
              _NavItem(
                icon: isDoctor ? Icons.people : Icons.bar_chart,
                label: isDoctor ? 'Pacientes' : 'Datos',
                isSelected: currentIndex == 2,
                accentColor: accentColor,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: isSelected ? accentColor : deepTeal),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? accentColor : deepTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onTap;

  const _ChatButton({required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.chat_bubble, color: white, size: 26),
          ),
          const SizedBox(height: 4),
          Text(
            'Chat',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
