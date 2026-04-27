import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _baseUrl = 'https://api.example.com/auth'; // 模拟API地址
  
  // 发送验证码
  Future<bool> sendVerificationCode(String phoneNumber) async {
    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      print('验证码已发送到 $phoneNumber');
      return true;
    } catch (e) {
      print('发送验证码失败: $e');
      return false;
    }
  }
  
  // 手机号登录
  Future<Map<String, dynamic>?> loginWithPhone(String phoneNumber, String code) async {
    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟登录成功响应
      final userData = {
        'id': '123456',
        'phone': phoneNumber,
        'nickname': '用户${phoneNumber.substring(7)}',
        'avatar': 'https://via.placeholder.com/150',
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      };
      
      // 保存用户信息到本地
      await _saveUserInfo(userData);
      
      return userData;
    } catch (e) {
      print('登录失败: $e');
      return null;
    }
  }
  
  // 注册
  Future<Map<String, dynamic>?> registerWithPhone(String phoneNumber, String code, String nickname) async {
    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟注册成功响应
      final userData = {
        'id': '123456',
        'phone': phoneNumber,
        'nickname': nickname,
        'avatar': 'https://via.placeholder.com/150',
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      };
      
      // 保存用户信息到本地
      await _saveUserInfo(userData);
      
      return userData;
    } catch (e) {
      print('注册失败: $e');
      return null;
    }
  }
  
  // 登出
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_info');
      await prefs.remove('token');
    } catch (e) {
      print('登出失败: $e');
    }
  }
  
  // 获取当前用户信息
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfo = prefs.getString('user_info');
      if (userInfo != null) {
        return json.decode(userInfo);
      }
      return null;
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }
  
  // 保存用户信息到本地
  Future<void> _saveUserInfo(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_info', json.encode(userData));
      await prefs.setString('token', userData['token'] as String);
    } catch (e) {
      print('保存用户信息失败: $e');
    }
  }
  
  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      return token != null;
    } catch (e) {
      print('检查登录状态失败: $e');
      return false;
    }
  }
}