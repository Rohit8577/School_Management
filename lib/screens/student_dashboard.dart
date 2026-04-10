import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart'; // LoginPage access karne ke liye
import 'tabs/home_tab.dart';
import 'tabs/homework_tab.dart';
import 'tabs/attendance_tab.dart';
import 'tabs/marks_tab.dart';

class StudentDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? userData; 
  const StudentDashboardScreen({super.key, this.userData});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    // Pro-tip: Jab tu HomeTab me changes karega, toh yahan se widget.userData usko pass kar dena
    _tabs = [
      const HomeTab(),
      const HomeworkTab(),
      const AttendanceTab(),
      const MarksTab(),
    ];
  }

  // Logout function add kar diya
  void _logout() {
    // Agar API service me setToken hatane ka logic nahi hai toh add kar lena
    // ApiService.setToken(''); 
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      backgroundColor: const Color(0xFFF8FAFC), 
      
      // 1. Ek sleek AppBar with Logout Button
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Background se blend hone ke liye
        elevation: 0,
        title: Text(
          'Hey, ${widget.userData?['name']?.split(' ')[0] ?? 'Student'} 👋',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1), // Halka sa red danger vibe
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _logout,
              icon: const Icon(
                Icons.logout_rounded, 
                color: Color(0xFFEF4444), // Solid red icon
                size: 22,
              ),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),

      // 2. Yahan tere tabs render ho rahe hain
      body: _tabs[_currentIndex],
      
      // 3. Tera custom bottom nav bar
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.08), 
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.menu_book_rounded, Icons.menu_book_outlined, 'Tasks'),
              _buildNavItem(2, Icons.fact_check_rounded, Icons.fact_check_outlined, 'Present'),
              _buildNavItem(3, Icons.stars_rounded, Icons.stars_outlined, 'Marks'),
            ],
          ),
        ),
      ),
    );
  }

  // Animated Custom Navbar Item
  Widget _buildNavItem(int index, IconData activeIcon, IconData defaultIcon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0049E6).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : defaultIcon,
              color: isSelected ? const Color(0xFF0049E6) : const Color(0xFF94A3B8),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0049E6),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}