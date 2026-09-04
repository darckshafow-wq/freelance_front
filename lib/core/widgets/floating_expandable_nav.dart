import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';

class FloatingExpandableNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemSelected;
  final VoidCallback onAddTap;

  const FloatingExpandableNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onAddTap,
  });

  @override
  State<FloatingExpandableNav> createState() => _FloatingExpandableNavState();
}

class _FloatingExpandableNavState extends State<FloatingExpandableNav> {
  bool _isExpanded = false;
  Timer? _inactivityTimer;

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _startInactivityTimer();
    } else {
      _inactivityTimer?.cancel();
    }
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isExpanded) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double expandedWidth = (screenWidth - 24).clamp(320.0, 380.0);
    final double barWidth = _isExpanded ? expandedWidth : 64.0;

    return Container(
      height: 120,
      padding: const EdgeInsets.only(bottom: 30),
      alignment: Alignment.bottomCenter,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // The Background Bar
          AnimatedContainer(
            duration: 500.ms,
            curve: Curves.fastEaseInToSlowEaseOut,
            width: barWidth,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.deepBlack,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: _isExpanded 
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildItem(0, Icons.home_outlined, Icons.home_filled, 'Accueil'),
                      _buildItem(2, Icons.work_outline, Icons.work, 'Missions'),
                      const SizedBox(width: 58), // Central button space
                      _buildItem(4, Icons.description_outlined, Icons.description, 'Offres'),
                      _buildItem(5, Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat'),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms)
              : const SizedBox(),
          ),

          // Central Toggle / Add Button
          GestureDetector(
            onTap: _isExpanded ? widget.onAddTap : _toggleMenu,
            child: AnimatedContainer(
              duration: 400.ms,
              curve: Curves.easeInOutQuart,
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _isExpanded ? AppColors.primaryGold : AppColors.deepBlack,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isExpanded 
                      ? Colors.transparent 
                      : AppColors.primaryGold.withValues(alpha: 0.4),
                    blurRadius: _isExpanded ? 0 : 15,
                    spreadRadius: _isExpanded ? 0 : 2,
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  _isExpanded ? Icons.add : Icons.touch_app_outlined,
                  color: _isExpanded ? AppColors.deepBlack : AppColors.primaryGold,
                  size: 28,
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.2))
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1.seconds),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = widget.currentIndex == index;
    return InkWell(
      onTap: () {
        widget.onItemSelected(index);
        setState(() => _isExpanded = false);
      },
      child: Container(
        width: 50, // Fixed width for consistent spacing
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primaryGold : Colors.white.withValues(alpha: 0.5),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: isSelected ? AppColors.primaryGold : Colors.white.withValues(alpha: 0.5),
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
