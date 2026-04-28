import 'package:flutter/material.dart';
import 'package:dao_app/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:dao_app/screens/main_screen.dart';

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
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    print('[LoginScreen] initState - 登录页面初始化');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    print('[LoginScreen] _startCountdown - 开始倒计时');
    setState(() {
      _countdown = 60;
      _isSendingCode = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      } else {
        if (mounted) {
          setState(() {
            _isSendingCode = false;
          });
        }
      }
    });
  }

  Future<void> _sendVerificationCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 11) {
      _showSnackBar('请输入正确的手机号');
      return;
    }

    print('[LoginScreen] _sendVerificationCode - 发送验证码到 $phone');

    setState(() {
      _isSendingCode = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('[LoginScreen] _sendVerificationCode - 获取到UserProvider');
      final success = await userProvider.sendVerificationCode(phone);
      print('[LoginScreen] _sendVerificationCode - 发送结果: $success');
      if (success) {
        _showSnackBar('验证码已发送');
        _startCountdown();
      } else {
        _showSnackBar('发送验证码失败，请重试');
      }
    } catch (e) {
      print('[LoginScreen] _sendVerificationCode - 异常: $e');
      _showSnackBar('发送验证码失败：$e');
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
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

    print('[LoginScreen] _login - 开始登录, phone: $phone, code: $code');

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('[LoginScreen] _login - 获取到UserProvider, isLoggedIn: ${userProvider.isLoggedIn}');

      final success = await userProvider.loginWithPhone(phone, code);
      print('[LoginScreen] _login - 登录结果: $success');
      print('[LoginScreen] _login - 当前isLoggedIn状态: ${userProvider.isLoggedIn}');

      if (success && mounted) {
        _showSnackBar('登录成功！');
        // 登录成功后直接跳转到主页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (!success && mounted) {
        _showSnackBar('登录失败，请检查验证码是否正确');
      }
    } catch (e) {
      print('[LoginScreen] _login - 异常: $e');
      if (mounted) {
        _showSnackBar('登录失败：$e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
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

    print('[LoginScreen] _register - 开始注册, phone: $phone, nickname: $nickname');

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('[LoginScreen] _register - 获取到UserProvider, isLoggedIn: ${userProvider.isLoggedIn}');

      final success = await userProvider.registerWithPhone(phone, code, nickname);
      print('[LoginScreen] _register - 注册结果: $success');
      print('[LoginScreen] _register - 当前isLoggedIn状态: ${userProvider.isLoggedIn}');

      if (success && mounted) {
        _showSnackBar('注册成功！');
        // 注册成功后直接跳转到主页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (!success && mounted) {
        _showSnackBar('注册失败，请重试');
      }
    } catch (e) {
      print('[LoginScreen] _register - 异常: $e');
      if (mounted) {
        _showSnackBar('注册失败：$e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    print('[LoginScreen] _showSnackBar - $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[LoginScreen] build - 构建登录页面');
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? '注册' : '登录'),
        centerTitle: true,
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
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _isRegisterMode ? '创建新账号' : '欢迎回来',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isRegisterMode ? '注册后即可使用全部功能' : '请登录您的账号',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: '手机号',
                hintText: '请输入11位手机号',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),

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
                        borderRadius: BorderRadius.circular(12),
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
                    backgroundColor: _isSendingCode ? Colors.grey : Colors.blue,
                  ),
                  child: Text(
                    _isSendingCode ? '$_countdown秒后重试' : '发送验证码',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isRegisterMode)
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '昵称',
                  hintText: '请输入您的昵称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
            if (_isRegisterMode) const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoggingIn
                    ? null
                    : (_isRegisterMode ? _register : _login),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoggingIn
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
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}