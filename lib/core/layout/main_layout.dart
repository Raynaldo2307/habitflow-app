import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/features/habits/home_screen.dart';
import 'package:habitflow/features/progress/progress_screen.dart';
import 'package:habitflow/features/profile/profile_screen.dart';
import 'package:habitflow/services/user_service.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initUserProfile(); // ⬅️ Call async function here
  });
}

Future<void> _initUserProfile() async {
  try {
    await context.read<UserService>().ensureUserProfile();
  } catch (e, stack) {
    debugPrint('Error ensuring user profile: $e\n$stack');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to load user profile.')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppTheme.primaryColor,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
