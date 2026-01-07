import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/rainyun_api_service.dart';
import '../../../core/models/rainyun_user.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _apiService = RainyunApiService();
  final _authService = AuthService();
  RainyunUser? _rainyunUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!_apiService.hasApiKey()) {
        setState(() {
          _isLoading = false;
          _errorMessage = '请先绑定 API Key';
        });
        return;
      }

      debugPrint('🔍 开始获取用户信息...');
      final response = await _apiService.getUserInfo();
      debugPrint('📦 API响应: $response');
      
      // API返回小写字段名：code, data, message
      final code = response['code'] ?? response['Code'];
      final data = response['data'] ?? response['Data'];
      
      if (code == 200 && data != null) {
        setState(() {
          _rainyunUser = RainyunUser.fromJson(data);
          _isLoading = false;
        });
        debugPrint('✅ 用户信息加载成功');
      } else {
        final errorMsg = response['message'] ?? response['Message'] ?? '未知错误';
        debugPrint('❌ API返回错误: code=$code, message=$errorMsg');
        setState(() {
          _isLoading = false;
          _errorMessage = 'API错误: $errorMsg (code: $code)';
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 获取用户信息异常: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _errorMessage = '网络请求失败，请检查网络连接或API Key是否正确';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final email = user?.email ?? 'user@example.com';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Column(
                            children: [
                              Icon(Icons.error_outline, size: 48, color: theme.hintColor),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: TextStyle(color: theme.hintColor),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _loadUserInfo,
                                child: const Text('重新加载'),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: _rainyunUser?.avatarUrl.isNotEmpty == true
                                    ? NetworkImage(_rainyunUser!.avatarUrl)
                                    : null,
                                child: _rainyunUser?.avatarUrl.isEmpty ?? true
                                    ? Icon(Icons.person, size: 40, color: theme.hintColor)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _rainyunUser?.displayName ?? '用户',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (_rainyunUser?.isVerified == true) ...[
                                          const SizedBox(width: 4),
                                          Icon(Icons.verified, size: 16, color: Colors.blue[600]),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.hintColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'UID: ${_rainyunUser?.uid ?? "未知"}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.hintColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '余额: ¥${_rainyunUser?.balance.toStringAsFixed(2) ?? "0.00"}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.refresh,
                      title: '刷新信息',
                      onTap: _loadUserInfo,
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      context,
                      icon: Icons.vpn_key,
                      title: '绑定 API Key',
                      onTap: () {
                        _showBindApiKeyDialog(context).then((_) => _loadUserInfo());
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      context,
                      icon: Icons.lock,
                      title: '修改密码',
                      onTap: () => _showChangePasswordDialog(context, _authService),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: '退出登录',
                  textColor: Colors.red,
                  onTap: () => _showLogoutDialog(context, _authService),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'RainyunApp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 0.0.1',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }

  Future<void> _showBindApiKeyDialog(BuildContext context) async {
    final controller = TextEditingController();
    final existingKey = _apiService.getApiKey();
    if (existingKey != null) {
      controller.text = existingKey;
    }
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('绑定 API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请输入雨云 API Key，可在雨云控制台获取',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '粘贴 API Key',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _apiService.setApiKey(result.trim());
        if (context.mounted) {
          TDToast.showSuccess('API Key 绑定成功', context: context);
        }
      } catch (e) {
        if (context.mounted) {
          TDToast.showFail('绑定失败：${e.toString()}', context: context);
        }
      }
    }
  }

  void _showChangePasswordDialog(BuildContext context, AuthService authService) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: '请输入新密码',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      try {
        await authService.updateUser(password: controller.text);
        if (context.mounted) {
          TDToast.showSuccess('修改成功', context: context);
        }
      } catch (e) {
        if (context.mounted) {
          TDToast.showFail('修改失败：$e', context: context);
        }
      }
    }
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await authService.signOut();
        if (context.mounted) {
          TDToast.showSuccess('已退出登录', context: context);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          TDToast.showFail('退出失败：$e', context: context);
        }
      }
    }
  }
}
