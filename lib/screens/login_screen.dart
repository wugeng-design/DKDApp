import 'package:flutter/material.dart';
import 'package:dao_app/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:dao_app/screens/main_screen.dart';

enum LoginType {
  password,
  phone,
  alipay,
  wechat,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _nicknameController = TextEditingController();
  
  bool _isRegisterMode = false;
  LoginType _currentLoginType = LoginType.password;
  
  bool _isSendingCode = false;
  int _countdown = 0;
  bool _isLoggingIn = false;
  
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    print('[LoginScreen] initState - 登录页面初始化');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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

  Future<void> _loginWithPassword() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty) {
      _showSnackBar('请输入账号');
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _showSnackBar('请输入至少6位密码');
      return;
    }

    print('[LoginScreen] _loginWithPassword - 开始账号密码登录, username: $username');

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('[LoginScreen] _loginWithPassword - 获取到UserProvider');

      final success = await userProvider.loginWithPassword(username, password);
      print('[LoginScreen] _loginWithPassword - 登录结果: $success');

      if (success && mounted) {
        _showSnackBar('登录成功！');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (!success && mounted) {
        _showSnackBar('登录失败，请检查账号密码是否正确');
      }
    } catch (e) {
      print('[LoginScreen] _loginWithPassword - 异常: $e');
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

  Future<void> _loginWithPhone() async {
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

    print('[LoginScreen] _loginWithPhone - 开始手机号登录, phone: $phone, code: $code');

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('[LoginScreen] _loginWithPhone - 获取到UserProvider');

      final success = await userProvider.loginWithPhone(phone, code);
      print('[LoginScreen] _loginWithPhone - 登录结果: $success');

      if (success && mounted) {
        _showSnackBar('登录成功！');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (!success && mounted) {
        _showSnackBar('登录失败，请检查验证码是否正确');
      }
    } catch (e) {
      print('[LoginScreen] _loginWithPhone - 异常: $e');
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

  Future<void> _registerWithPassword() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (username.isEmpty) {
      _showSnackBar('请输入账号');
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _showSnackBar('请输入至少6位密码');
      return;
    }

    if (nickname.isEmpty || nickname.length < 2) {
      _showSnackBar('请输入至少2个字符的昵称');
      return;
    }

    print('[LoginScreen] _registerWithPassword - 开始账号密码注册, username: $username, nickname: $nickname');

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('[LoginScreen] _registerWithPassword - 获取到UserProvider');

      final success = await userProvider.registerWithPassword(username, password, nickname);
      print('[LoginScreen] _registerWithPassword - 注册结果: $success');

      if (success && mounted) {
        _showSnackBar('注册成功！');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (!success && mounted) {
        _showSnackBar('注册失败，请重试');
      }
    } catch (e) {
      print('[LoginScreen] _registerWithPassword - 异常: $e');
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

  Future<void> _registerWithPhone() async {
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

    print('[LoginScreen] _registerWithPhone - 开始手机号注册, phone: $phone, nickname: $nickname');

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('[LoginScreen] _registerWithPhone - 获取到UserProvider');

      final success = await userProvider.registerWithPhone(phone, code, nickname);
      print('[LoginScreen] _registerWithPhone - 注册结果: $success');

      if (success && mounted) {
        _showSnackBar('注册成功！');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (!success && mounted) {
        _showSnackBar('注册失败，请重试');
      }
    } catch (e) {
      print('[LoginScreen] _registerWithPhone - 异常: $e');
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

  void _loginWithAlipay() {
    _showSnackBar('支付宝登录功能开发中');
  }

  void _loginWithWechat() {
    _showSnackBar('微信登录功能开发中');
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

  Widget _buildPasswordLoginForm() {
    return Column(
      children: [
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: '账号',
            hintText: '请输入账号',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: '密码',
            hintText: '请输入密码',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
          ),
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
        if (_isRegisterMode) const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhoneLoginForm() {
    return Column(
      children: [
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
        if (_isRegisterMode) const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOtherLoginMethods() {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('其他登录方式'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialLoginButton(
              icon: Icons.alipay,
              label: '支付宝',
              color: const Color(0xFF1677FF),
              onTap: _loginWithAlipay,
            ),
            const SizedBox(width: 32),
            _buildSocialLoginButton(
              icon: Icons.message,
              label: '微信',
              color: const Color(0xFF07C160),
              onTap: _loginWithWechat,
            ),
            const SizedBox(width: 32),
            _buildSocialLoginButton(
              icon: Icons.phone,
              label: '手机号',
              color: const Color(0xFF607D8B),
              onTap: () {
                setState(() {
                  _currentLoginType = LoginType.phone;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
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

            _currentLoginType == LoginType.password
                ? _buildPasswordLoginForm()
                : _buildPhoneLoginForm(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoggingIn
                    ? null
                    : _currentLoginType == LoginType.password
                        ? (_isRegisterMode ? _registerWithPassword : _loginWithPassword)
                        : (_isRegisterMode ? _registerWithPhone : _loginWithPhone),
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
            const SizedBox(height: 16),

            if (_currentLoginType == LoginType.phone)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentLoginType = LoginType.password;
                  });
                },
                child: const Text(
                  '使用账号密码登录',
                  style: TextStyle(
                    color: Colors.blue,
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

            if (_currentLoginType == LoginType.password)
              _buildOtherLoginMethods(),
          ],
        ),
      ),
    );
  }
}