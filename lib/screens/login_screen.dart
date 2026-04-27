import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/services/user_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isRegisterMode = false;
  bool _isSendingCode = false;
  int _countdown = 0;
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _isSendingCode = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      } else {
        setState(() {
          _isSendingCode = false;
        });
      }
    });
  }

  Future<void> _sendVerificationCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 11) {
      _showSnackBar('请输入正确的手机号');
      return;
    }

    final success = await _userProvider.sendVerificationCode(phone);
    if (success) {
      _showSnackBar('验证码已发送');
      _startCountdown();
    } else {
      _showSnackBar('发送验证码失败，请重试');
    }
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (phone.isEmpty || phone.length != 11) {
      _showSnackBar('请输入正确的手机号');
      return;
    }

    if (code.isEmpty || code.length != 6) {
      _showSnackBar('请输入6位验证码');
      return;
    }

    final success = await _userProvider.loginWithPhone(phone, code);
    if (success) {
      Navigator.pop(context);
    } else {
      _showSnackBar('登录失败，请检查验证码是否正确');
    }
  }

  Future<void> _register() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (phone.isEmpty || phone.length != 11) {
      _showSnackBar('请输入正确的手机号');
      return;
    }

    if (code.isEmpty || code.length != 6) {
      _showSnackBar('请输入6位验证码');
      return;
    }

    if (nickname.isEmpty || nickname.length < 2) {
      _showSnackBar('请输入至少2个字符的昵称');
      return;
    }

    final success = await _userProvider.registerWithPhone(phone, code, nickname);
    if (success) {
      Navigator.pop(context);
    } else {
      _showSnackBar('注册失败，请重试');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? '注册' : '登录'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: AppTheme.accentColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _isRegisterMode ? '创建新账号' : '欢迎回来',
              style: AppTheme.titleStyle,
            ),
            const SizedBox(height: 8),
            Text(
              _isRegisterMode ? '注册后即可使用全部功能' : '请登录您的账号',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 40),

            // 手机号输入
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: '手机号',
                hintText: '请输入11位手机号',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),

            // 验证码输入
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '验证码',
                      hintText: '请输入6位验证码',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSendingCode ? null : _sendVerificationCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    backgroundColor: _isSendingCode ? Colors.grey : AppTheme.accentColor,
                  ),
                  child: Text(
                    _isSendingCode ? '$_countdown秒后重试' : '发送验证码',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 昵称输入（仅注册模式）
            if (_isRegisterMode)
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '昵称',
                  hintText: '请输入您的昵称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
            if (_isRegisterMode) const SizedBox(height: 24),

            // 登录/注册按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _userProvider.isLoading 
                    ? null 
                    : (_isRegisterMode ? _register : _login),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                ),
                child: _userProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isRegisterMode ? '注册' : '登录',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // 切换登录/注册模式
            GestureDetector(
              onTap: () {
                setState(() {
                  _isRegisterMode = !_isRegisterMode;
                });
              },
              child: Text(
                _isRegisterMode 
                    ? '已有账号？去登录' 
                    : '还没有账号？去注册',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 其他登录方式（可选）
            Column(
              children: [
                Text(
                  '其他登录方式',
                  style: AppTheme.captionStyle,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.wechat),
                      iconSize: 40,
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_android),
                      iconSize: 40,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}