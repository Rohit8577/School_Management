import 'package:flutter/material.dart';
import 'screens/student_dashboard.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'services/api_service.dart';

void main() {
  runApp(const AcademicEtherealApp());
}

class AcademicEtherealApp extends StatelessWidget {
  const AcademicEtherealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Ethereal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0049E6)),
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int _selectedRoleIndex = 0; // 0: Student, 1: Teacher, 2: Admin
  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<String> _roles = ['Student', 'Teacher', 'Admin'];
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _roleValue {
    switch (_selectedRoleIndex) {
      case 0:
        return 'student';
      case 1:
        return 'teacher';
      case 2:
        return 'admin';
      default:
        return 'student';
    }
  }

  Future<void> _handleLogin() async {
    final identifier = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(
        identifier: identifier,
        password: password,
        role: _roleValue,
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        final userData = result['data']['user'];
        final role = userData['role'];

        

        if (!mounted) return;

        Widget dashboard;
        if (role == 'teacher') {
          print(userData);
          dashboard = TeacherDashboardScreen(userData: userData);
        } else if (role == 'admin') {
          dashboard = AdminDashboardScreen(userData: userData);
        } else {
          dashboard = const StudentDashboardScreen();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => dashboard),
        );
      } else {
        _showSnackBar(result['data']['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Connection error. Make sure the backend server is running.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String idLabel;
    String idHint;
    IconData idIcon;

    if (_selectedRoleIndex == 0) {
      idLabel = 'STUDENT ID';
      idHint = 'e.g. STU12345';
      idIcon = Icons.badge_outlined;
    } else if (_selectedRoleIndex == 1) {
      idLabel = 'TEACHER ID';
      idHint = 'e.g. TCH9876';
      idIcon = Icons.badge_outlined;
    } else {
      idLabel = 'ADMIN EMAIL';
      idHint = 'admin@university.edu';
      idIcon = Icons.mail_outline;
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0049E6),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0049E6).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Academic Ethereal',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0049E6),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 54),

                  // Welcome Text
                  const Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Log in to your academic portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Segmented Control
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tabWidth = constraints.maxWidth / _roles.length;
                        return Stack(
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              left: _selectedRoleIndex * tabWidth,
                              width: tabWidth,
                              height: constraints.maxHeight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0049E6),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0049E6).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                ),
                              ),
                            ),
                            Row(
                              children: List.generate(
                                _roles.length,
                                (index) => Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        _selectedRoleIndex = index;
                                        _idController.clear();
                                      });
                                    },
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 250),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: _selectedRoleIndex == index
                                              ? Colors.white
                                              : const Color(0xFF475569),
                                        ),
                                        child: Text(_roles[index]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Dynamic ID/Email Input
                  Text(
                    idLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        hintText: idHint,
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 15,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                          child: Icon(idIcon, color: const Color(0xFF94A3B8), size: 22),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0049E6), width: 1.5),
                        ),
                      ),
                      keyboardType: _selectedRoleIndex == 2 ? TextInputType.emailAddress : TextInputType.text,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Password Input
                  const Text(
                    'PASSWORD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 15,
                          letterSpacing: 2,
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 16.0, right: 12.0),
                          child: Icon(Icons.lock_outline, color: Color(0xFF94A3B8), size: 22),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF94A3B8),
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0049E6), width: 1.5),
                        ),
                      ),
                      style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0049E6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF0049E6).withOpacity(0.5),
                      disabledBackgroundColor: const Color(0xFF0049E6).withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
