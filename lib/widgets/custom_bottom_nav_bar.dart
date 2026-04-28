import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1B3620),
        border: Border(top: BorderSide(color: Colors.green.shade900, width: 2)),
      ),
      child: Row(
        children: [
          _buildNavItem(0, Icons.person, Colors.blue),
          _buildNavItem(1, Icons.style, Colors.redAccent),
          _buildNavItem(2, Icons.colorize, Colors.green),
          _buildNavItem(3, Icons.layers, Colors.white70),
          _buildNavItem(4, Icons.storefront, Colors.blueGrey),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, Color defaultColor) {
    bool isSelected = selectedIndex == index;
    return Expanded(
      child: Material(
        color: isSelected ? const Color(0xFF3B8E4D) : Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          splashColor: const Color.fromARGB(255, 26, 218, 68).withValues(alpha: 0.3),
          child: SizedBox(
            height: double.infinity,
            child: Center(
              child: Icon(
                icon,
                color: defaultColor,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}