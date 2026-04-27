import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/screens/home_screen.dart';
import 'package:dao_app/screens/thought_screen.dart';
import 'package:dao_app/screens/figure_screen.dart';
import 'package:dao_app/screens/sect_screen.dart';
import 'package:dao_app/screens/search_screen.dart';
import 'package:dao_app/screens/login_screen.dart';
import 'package:dao_app/screens/settings_screen.dart';
import 'package:dao_app/services/user_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider()..initUser(),
      child: const MyApp(),
    ),
  );
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
  bool _isInitialized = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  void _checkLoginStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initUser();
    if (!userProvider.isLoggedIn && !_isInitialized) {
      _isInitialized = true;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dao · 道'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              if (userProvider.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            icon: Icon(
              userProvider.isLoggedIn ? Icons.settings : Icons.person,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
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