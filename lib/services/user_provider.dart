import 'package:flutter/material.dart';
import 'package:dao_app/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  Map<String, dynamic>? _user;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  UserProvider() {
    print('[UserProvider] UserProvider - 构造函数，开始初始化');
    _initUser();
  }

  Future<void> _initUser() async {
    print('[UserProvider] _initUser - 开始初始化');
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await _userService.isLoggedIn();
      print('[UserProvider] _initUser - isLoggedIn: $_isLoggedIn');
      if (_isLoggedIn) {
        _user = await _userService.getCurrentUser();
        print('[UserProvider] _initUser - user: $_user');
      }
    } catch (e) {
      print('[UserProvider] _initUser - 异常: $e');
      _isLoggedIn = false;
      _user = null;
    } finally {
      _isLoading = false;
      print('[UserProvider] _initUser - 完成, isLoggedIn: $_isLoggedIn');
      notifyListeners();
    }
  }

  Future<bool> loginWithPhone(String phoneNumber, String code) async {
    print('[UserProvider] loginWithPhone - 开始登录, phone: $phoneNumber');

    try {
      final userData = await _userService.loginWithPhone(phoneNumber, code);
      print('[UserProvider] loginWithPhone - userData: $userData');
      if (userData != null) {
        _user = userData;
        _isLoggedIn = true;
        print('[UserProvider] loginWithPhone - 登录成功, isLoggedIn: $_isLoggedIn');
        notifyListeners();
        return true;
      }
      print('[UserProvider] loginWithPhone - userData为null');
      return false;
    } catch (e) {
      print('[UserProvider] loginWithPhone - 异常: $e');
      return false;
    }
  }

  Future<bool> registerWithPhone(String phoneNumber, String code, String nickname) async {
    print('[UserProvider] registerWithPhone - 开始注册, phone: $phoneNumber, nickname: $nickname');

    try {
      final userData = await _userService.registerWithPhone(phoneNumber, code, nickname);
      print('[UserProvider] registerWithPhone - userData: $userData');
      if (userData != null) {
        _user = userData;
        _isLoggedIn = true;
        print('[UserProvider] registerWithPhone - 注册成功, isLoggedIn: $_isLoggedIn');
        notifyListeners();
        return true;
      }
      print('[UserProvider] registerWithPhone - userData为null');
      return false;
    } catch (e) {
      print('[UserProvider] registerWithPhone - 异常: $e');
      return false;
    }
  }

  Future<bool> loginWithPassword(String username, String password) async {
    print('[UserProvider] loginWithPassword - 开始账号密码登录, username: $username');

    try {
      final userData = await _userService.loginWithPassword(username, password);
      print('[UserProvider] loginWithPassword - userData: $userData');
      if (userData != null) {
        _user = userData;
        _isLoggedIn = true;
        print('[UserProvider] loginWithPassword - 登录成功, isLoggedIn: $_isLoggedIn');
        notifyListeners();
        return true;
      }
      print('[UserProvider] loginWithPassword - userData为null');
      return false;
    } catch (e) {
      print('[UserProvider] loginWithPassword - 异常: $e');
      return false;
    }
  }

  Future<bool> registerWithPassword(String phone, String username, String password, String nickname) async {
    print('[UserProvider] registerWithPassword - 开始账号密码注册, phone: $phone, username: $username, nickname: $nickname');

    try {
      final userData = await _userService.registerWithPassword(phone, username, password, nickname);
      print('[UserProvider] registerWithPassword - userData: $userData');
      if (userData != null) {
        _user = userData;
        _isLoggedIn = true;
        print('[UserProvider] registerWithPassword - 注册成功, isLoggedIn: $_isLoggedIn');
        notifyListeners();
        return true;
      }
      print('[UserProvider] registerWithPassword - userData为null');
      return false;
    } catch (e) {
      print('[UserProvider] registerWithPassword - 异常: $e');
      return false;
    }
  }

  Future<void> logout() async {
    print('[UserProvider] logout - 开始登出');
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.logout();
      _user = null;
      _isLoggedIn = false;
      print('[UserProvider] logout - 登出成功, isLoggedIn: $_isLoggedIn');
    } catch (e) {
      print('[UserProvider] logout - 异常: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendVerificationCode(String phoneNumber) async {
    print('[UserProvider] sendVerificationCode - 发送验证码到 $phoneNumber');
    return await _userService.sendVerificationCode(phoneNumber);
  }

  void updateUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners();
  }
}