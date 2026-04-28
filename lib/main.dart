import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/screens/login_screen.dart';
import 'package:dao_app/screens/main_screen.dart';
import 'package:dao_app/services/user_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
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
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    print('[AuthWrapper] initState');
  }

  @override
  Widget build(BuildContext context) {
    print('[AuthWrapper] build - 构建中');

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        print('[AuthWrapper] build - userProvider.isLoggedIn: ${userProvider.isLoggedIn}, isLoading: ${userProvider.isLoading}');

        if (userProvider.isLoading) {
          print('[AuthWrapper] build - 显示加载页面');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (userProvider.isLoggedIn) {
          print('[AuthWrapper] build - 显示主页');
          return const MainScreen();
        } else {
          print('[AuthWrapper] build - 显示登录页');
          return const LoginScreen();
        }
      },
    );
  }
}