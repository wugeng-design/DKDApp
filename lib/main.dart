import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/screens/home_screen.dart';
import 'package:dao_app/screens/thought_screen.dart';
import 'package:dao_app/screens/figure_screen.dart';
import 'package:dao_app/screens/sect_screen.dart';
import 'package:dao_app/screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dao · 道',
      theme: AppTheme.themeData,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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