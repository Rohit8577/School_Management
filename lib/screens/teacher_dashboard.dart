import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const TeacherDashboardScreen({super.key, required this.userData});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final result = await ApiService.getDashboard('teacher');
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
      backgroundColor: const Color(0xFFF8FAFC), // Ekdum smooth off-white
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0049E6)),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Premium Header (Gradient Background)
                  _buildHeader(user),

                  // 2. Overlapping Stats Cards (Transform translate se upar kheencha hai)
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildStatCard(
                                'Total Classes',
                                '${stats?['totalClasses'] ?? 0}',
                                Icons.class_outlined,
                                const Color(0xFF0049E6),
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                'Total Students',
                                '${stats?['totalStudents'] ?? 0}',
                                Icons.people_outline,
                                const Color(0xFF10B981), // Fresh emerald green
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatCard(
                                'Homework Given',
                                '${stats?['homeworkAssigned'] ?? 0}',
                                Icons.assignment_outlined,
                                const Color(0xFFF59E0B), // Warm amber
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                'Department',
                                user['department'] ?? '—',
                                Icons.business_outlined,
                                const Color(0xFF8B5CF6), // Vibrant purple
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Quick Actions Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionTile(
                          'Mark Attendance',
                          'Take attendance for your class',
                          Icons.fact_check_outlined,
                          const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 12),
                        _buildActionTile(
                          'Assign Homework',
                          'Create new homework for students',
                          Icons.edit_note_outlined,
                          const Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: 12),
                        _buildActionTile(
                          'Enter Marks',
                          'Record exam results',
                          Icons.grade_outlined,
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
          colors: [Color(0xFF0049E6), Color(0xFF2563EB)],
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
                    '🎓 Teacher Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hello, ${user['name']?.split(' ')[0] ?? 'Teacher'} 👋',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${user['teacher_id'] ?? '—'}',
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
              color: const Color(0xFF0F172A).withOpacity(0.04), // Ekdum soft shadow
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
                letterSpacing: value.length > 3 ? -1 : 0, // Lambe text ke liye
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
    return InkWell( // Tap ripple effect ke liye
      onTap: () {
        // Yahan navigation daal dena aage
        print('$title clicked');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)), // Light subtle border
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