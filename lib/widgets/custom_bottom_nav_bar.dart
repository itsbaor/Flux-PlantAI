import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 80 + bottomPadding,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home,
              label: 'Home',
              isActive: currentIndex == 0,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.eco,
              label: 'My garden',
              isActive: currentIndex == 1,
            ),
            _buildCenterScanButton(),
            _buildNavItem(
              index: 3,
              icon: Icons.notifications_outlined,
              label: 'Reminder',
              isActive: currentIndex == 3,
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final color = isActive ? const Color(0xFF90EE90) : Colors.grey;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterScanButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF90EE90),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF90EE90).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.center_focus_weak,
          color: Color(0xFF2A2A2A),
          size: 32,
        ),
      ),
    );
  }
}
