import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/screens/home_screen.dart';
import 'package:dao_app/screens/thought_screen.dart';
import 'package:dao_app/screens/figure_screen.dart';
import 'package:dao_app/screens/sect_screen.dart';
import 'package:dao_app/screens/search_screen.dart';
import 'package:dao_app/screens/settings_screen.dart';
import 'package:dao_app/services/user_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ThoughtScreen(),
    const FigureScreen(),
    const SectScreen(),
    const SearchScreen(),
  ];

  @override
  void initState() {
    super.initState();
    print('[MainScreen] initState');
  }

  @override
  Widget build(BuildContext context) {
    print('[MainScreen] build - index: $_currentIndex');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dao · 道'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: Icon(
              Icons.settings,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: '思想',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '人物',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service),
            label: '派系',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '搜索',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.accentColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 8.0,
      ),
    );
  }
}