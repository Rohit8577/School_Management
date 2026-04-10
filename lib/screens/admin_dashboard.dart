import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';

class AdminDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AdminDashboardScreen({super.key, required this.userData});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final result = await ApiService.getDashboard('admin');
      if (result['success']) {
        setState(() {
          dashboardData = result['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _logout() {
    ApiService.setToken('');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;
    final stats = dashboardData?['stats'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Smooth off-white
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)), // Indigo loader
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Premium Admin Header (Indigo/Purple Gradient)
                  _buildHeader(user),

                  // 2. Overlapping Stats Cards (Transform translate)
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildStatCard(
                                'Students',
                                '${stats?['totalStudents'] ?? 0}',
                                Icons.school_outlined,
                                const Color(0xFF3B82F6), // Blue
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                'Teachers',
                                '${stats?['totalTeachers'] ?? 0}',
                                Icons.person_outline,
                                const Color(0xFF10B981), // Emerald
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatCard(
                                'Classes',
                                '${stats?['totalClasses'] ?? 0}',
                                Icons.class_outlined,
                                const Color(0xFFF59E0B), // Amber
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                'Subjects',
                                '${stats?['totalSubjects'] ?? 0}',
                                Icons.menu_book_outlined,
                                const Color(0xFF8B5CF6), // Purple
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Management Quick Actions Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Management',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionTile(
                          'Manage Students',
                          'Add, edit or remove students',
                          Icons.people_alt_outlined,
                          const Color(0xFF3B82F6),
                        ),
                        const SizedBox(height: 12),
                        _buildActionTile(
                          'Manage Teachers',
                          'Add, edit or remove teachers',
                          Icons.person_add_alt_outlined,
                          const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 12),
                        _buildActionTile(
                          'Manage Classes',
                          'Create or update class sections',
                          Icons.meeting_room_outlined,
                          const Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: 12),
                        _buildActionTile(
                          'Reports',
                          'View attendance & performance',
                          Icons.bar_chart_outlined,
                          const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(height: 40), // Bottom padding
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(Map<String, dynamic> user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 70),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)], // Indigo to Purple mix
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🏫 Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hello, ${user['name']?.split(' ')[0] ?? 'Admin'} 👋',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user['designation'] ?? 'School Administrator',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04), // Super soft shadow
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
                letterSpacing: value.length > 3 ? -1 : 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color) {
    return InkWell( // Tap ripple effect 
      onTap: () {
        // Yahan navigator logic push karna aage
        print('$title clicked');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)), // Subtle light border
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF94A3B8),
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}