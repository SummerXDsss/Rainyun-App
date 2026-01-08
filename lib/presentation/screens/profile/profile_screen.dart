import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/rainyun_api_service.dart';
import '../../../core/models/rainyun_user.dart';
import '../../../core/utils/debug_log_manager.dart';
import '../auth/login_screen.dart';
import '../points/points_screen.dart';

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
                                        Flexible(
                                          child: Text(
                                            _rainyunUser?.displayName ?? '用户',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        // VIP等级徽章
                                        if (_rainyunUser != null && _rainyunUser!.vipLevel > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: _getVipColors(_rainyunUser!.vipLevel),
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'VIP${_rainyunUser!.vipLevel}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 4),
                                        // 实名认证徽章
                                        if (_rainyunUser?.isVerified == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.green.withOpacity(0.5)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.verified_user, size: 10, color: Colors.green),
                                                SizedBox(width: 2),
                                                Text(
                                                  '已实名',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.orange.withOpacity(0.5)),
                                            ),
                                            child: const Text(
                                              '未实名',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
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
                      icon: Icons.account_balance_wallet,
                      title: '我的余额',
                      subtitle: '¥${_rainyunUser?.balance.toStringAsFixed(2) ?? '0.00'}',
                      onTap: () => _showBalanceDialog(),
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      context,
                      icon: Icons.card_giftcard,
                      title: '我的优惠券',
                      onTap: () => _showCouponsSheet(),
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      context,
                      icon: Icons.stars,
                      title: '积分中心',
                      subtitle: '${_rainyunUser?.points ?? 0} 积分',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PointsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1),
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
              GestureDetector(
                onLongPress: () => _showDebugModeDialog(context),
                child: Container(
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
                      if (DebugLogManager().isDebugMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '调试模式已开启',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
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
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? Colors.blue.shade300),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ],
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

  void _showDebugModeDialog(BuildContext context) async {
    final debugManager = DebugLogManager();
    
    if (debugManager.isDebugMode) {
      // 已开启，显示选项
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('调试模式'),
          content: const Text('调试模式已开启，请选择操作'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'show'),
              child: const Text('显示面板'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'close'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('关闭调试'),
            ),
          ],
        ),
      );
      
      if (result == 'show') {
        debugManager.showPanel();
      } else if (result == 'close') {
        debugManager.disableDebugMode();
        setState(() {});
      }
      return;
    }
    
    // 未开启，输入密码
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开启调试模式'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: '请输入调试密码',
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
      if (debugManager.enableDebugMode(controller.text)) {
        setState(() {});
        if (context.mounted) {
          TDToast.showSuccess('调试模式已开启', context: context);
        }
      } else {
        if (context.mounted) {
          TDToast.showFail('密码错误', context: context);
        }
      }
    }
  }

  List<Color> _getVipColors(int level) {
    switch (level) {
      case 1:
        return [Colors.grey, Colors.grey.shade600];
      case 2:
        return [Colors.green, Colors.green.shade700];
      case 3:
        return [Colors.blue, Colors.blue.shade700];
      case 4:
        return [Colors.purple, Colors.purple.shade700];
      case 5:
        return [Colors.orange, Colors.red];
      default:
        return [Colors.grey, Colors.grey.shade600];
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

  // 余额对话框
  void _showBalanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('我的余额'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.orange.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    '¥${_rainyunUser?.balance.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '充值请前往官网',
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 优惠券列表
  void _showCouponsSheet() async {
    TDToast.showLoading(context: context, text: '加载中...');
    try {
      final response = await _apiService.get('/user/coupons/');
      TDToast.dismissLoading();
      
      if (!mounted) return;
      
      List<Map<String, dynamic>> coupons = [];
      if (response['code'] == 200) {
        coupons = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('我的优惠券', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${coupons.length}张', style: TextStyle(color: Theme.of(context).hintColor)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: coupons.isEmpty
                    ? const Center(child: Text('暂无优惠券'))
                    : GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: coupons.length,
                        itemBuilder: (context, index) => _buildCouponCard(coupons[index]),
                      ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      TDToast.dismissLoading();
      TDToast.showFail('获取优惠券失败', context: context);
    }
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    final name = coupon['friendly_name'] ?? '优惠券';
    final type = coupon['type'] ?? '';
    final value = coupon['value'] ?? 0;
    final expDate = coupon['exp_date'] ?? 0;
    final color = coupon['color'] ?? 'info';
    
    // 格式化到期时间
    String expStr = '永久有效';
    if (expDate > 0) {
      final date = DateTime.fromMillisecondsSinceEpoch(expDate * 1000);
      expStr = '${date.year}/${date.month}/${date.day}到期';
    }
    
    // 获取颜色
    Color cardColor;
    switch (color) {
      case 'success':
        cardColor = Colors.green;
        break;
      case 'warning':
        cardColor = Colors.orange;
        break;
      case 'danger':
        cardColor = Colors.red;
        break;
      default:
        cardColor = Colors.blue;
    }
    
    // 优惠券值描述
    String valueStr = '';
    if (type == 'discount') {
      valueStr = '${(value * 10).toStringAsFixed(1)}折';
    } else if (type == 'reduce') {
      valueStr = '-¥$value';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 优惠券图标
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Icons.card_giftcard, color: cardColor, size: 32),
          ),
          const SizedBox(height: 12),
          // 优惠券名称
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (valueStr.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              valueStr,
              style: TextStyle(color: cardColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
          const SizedBox(height: 8),
          // 到期时间
          Text(
            expStr,
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
