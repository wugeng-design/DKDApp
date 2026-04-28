import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _baseUrl = 'http://192.168.1.7:3000/auth';
  
  // 发送验证码
  Future<bool> sendVerificationCode(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phoneNumber}),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        print('发送验证码成功: ${data['message']}');
        return true;
      } else {
        print('发送验证码失败: ${response.body}');
        return false;
      }
    } catch (e) {
      print('发送验证码失败: $e');
      return false;
    }
  }
  
  // 手机号登录
  Future<Map<String, dynamic>?> loginWithPhone(String phoneNumber, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phoneNumber, 'code': code}),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final userData = {
            'id': data['data']['user']['id'],
            'phone': data['data']['user']['phone'],
            'nickname': data['data']['user']['nickname'],
            'avatar': data['data']['user']['avatar'] ?? '',
            'token': data['data']['token'],
          };
          
          await _saveUserInfo(userData);
          print('登录成功');
          return userData;
        }
      } else {
        print('登录失败: ${response.body}');
      }
      return null;
    } catch (e) {
      print('登录失败: $e');
      return null;
    }
  }
  
  // 注册
  Future<Map<String, dynamic>?> registerWithPhone(String phoneNumber, String code, String nickname) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phoneNumber, 'code': code, 'nickname': nickname}),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final userData = {
            'id': data['data']['user']['id'],
            'phone': data['data']['user']['phone'],
            'nickname': data['data']['user']['nickname'],
            'avatar': data['data']['user']['avatar'] ?? '',
            'token': data['data']['token'],
          };
          
          await _saveUserInfo(userData);
          print('注册成功');
          return userData;
        }
      } else {
        print('注册失败: ${response.body}');
      }
      return null;
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