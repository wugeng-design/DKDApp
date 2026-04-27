import 'package:flutter/material.dart';
import 'package:dao_app/utils/app_theme.dart';
import 'package:dao_app/services/user_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await _userProvider.logout();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 用户信息卡片
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // 头像
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(user?['avatar'] ?? 'https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // 用户信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['nickname'] ?? '用户',
                          style: AppTheme.titleStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?['phone'] ?? '未设置手机号',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 账号设置
          const Text('账号设置', style: AppTheme.subtitleStyle),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.person_outline,
                  title: '个人资料',
                  onTap: () {
                    // 跳转到个人资料页面
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.phone_android,
                  title: '手机号',
                  subtitle: user?['phone'] ?? '未设置',
                  onTap: () {
                    // 跳转到手机号设置页面
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.lock_outline,
                  title: '修改密码',
                  onTap: () {
                    // 跳转到修改密码页面
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 通用设置
          const Text('通用设置', style: AppTheme.subtitleStyle),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.notifications_outlined,
                  title: '通知设置',
                  onTap: () {
                    // 跳转到通知设置页面
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.language,
                  title: '语言设置',
                  subtitle: '简体中文',
                  onTap: () {
                    // 跳转到语言设置页面
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.brightness_medium_outlined,
                  title: '外观设置',
                  subtitle: '跟随系统',
                  onTap: () {
                    // 跳转到外观设置页面
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.storage_outlined,
                  title: '存储空间',
                  subtitle: '128MB',
                  onTap: () {
                    // 跳转到存储空间页面
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 其他设置
          const Text('其他', style: AppTheme.subtitleStyle),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.help_outline,
                  title: '帮助与反馈',
                  onTap: () {
                    // 跳转到帮助与反馈页面
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.info_outline,
                  title: '关于我们',
                  subtitle: '版本 1.0.0',
                  onTap: () {
                    // 跳转到关于我们页面
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.privacy_tip_outlined,
                  title: '隐私政策',
                  onTap: () {
                    // 跳转到隐私政策页面
                  },
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.description_outlined,
                  title: '用户协议',
                  onTap: () {
                    // 跳转到用户协议页面
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // 退出登录按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
              ),
              child: const Text(
                '退出登录',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.accentColor,
      ),
      title: Text(title, style: AppTheme.bodyStyle),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTheme.captionStyle)
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 72,
      color: Colors.grey,
    );
  }
}