import 'package:flutter/material.dart';
import 'package:dao_app/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  Map<String, dynamic>? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  
  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  
  // 初始化用户状态
  Future<void> initUser() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _isLoggedIn = await _userService.isLoggedIn();
      if (_isLoggedIn) {
        _user = await _userService.getCurrentUser();
      }
    } catch (e) {
      print('初始化用户状态失败: $e');
      _isLoggedIn = false;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 手机号登录
  Future<bool> loginWithPhone(String phoneNumber, String code) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final userData = await _userService.loginWithPhone(phoneNumber, code);
      if (userData != null) {
        _user = userData;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('登录失败: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 注册
  Future<bool> registerWithPhone(String phoneNumber, String code, String nickname) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final userData = await _userService.registerWithPhone(phoneNumber, code, nickname);
      if (userData != null) {
        _user = userData;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('注册失败: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 登出
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _userService.logout();
      _user = null;
      _isLoggedIn = false;
    } catch (e) {
      print('登出失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 发送验证码
  Future<bool> sendVerificationCode(String phoneNumber) async {
    return await _userService.sendVerificationCode(phoneNumber);
  }
  
  // 更新用户信息
  void updateUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners();
  }
}