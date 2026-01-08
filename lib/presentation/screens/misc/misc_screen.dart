import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/rainyun_api_service.dart';
import '../points/points_screen.dart';

class MiscScreen extends StatefulWidget {
  const MiscScreen({super.key});

  @override
  State<MiscScreen> createState() => _MiscScreenState();
}

class _MiscScreenState extends State<MiscScreen> {
  final _apiService = RainyunApiService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '杂项',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 积分与奖励
            _buildSectionTitle('积分与奖励'),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildListItem(
                    icon: Icons.stars,
                    iconColor: Colors.orange,
                    title: '积分中心',
                    subtitle: '完成任务赚积分，兑换产品',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PointsScreen()),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildListItem(
                    icon: Icons.card_giftcard,
                    iconColor: Colors.pink,
                    title: '兑换优惠券',
                    subtitle: '使用积分兑换优惠券',
                    onTap: () => _showComingSoon('兑换优惠券'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 推广与邀请
            _buildSectionTitle('推广与邀请'),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildListItem(
                    icon: Icons.share,
                    iconColor: Colors.blue,
                    title: '邀请好友',
                    subtitle: '分享邀请链接，获得奖励',
                    onTap: () => _showInviteDialog(),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildListItem(
                    icon: Icons.people,
                    iconColor: Colors.green,
                    title: '我的邀请',
                    subtitle: '查看邀请记录和奖励',
                    onTap: () => _showComingSoon('我的邀请'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 工具箱
            _buildSectionTitle('工具箱'),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildListItem(
                    icon: Icons.speed,
                    iconColor: Colors.purple,
                    title: '网络测速',
                    subtitle: '测试服务器网络速度',
                    onTap: () => _showComingSoon('网络测速'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildListItem(
                    icon: Icons.dns,
                    iconColor: Colors.teal,
                    title: 'DNS查询',
                    subtitle: '查询域名DNS记录',
                    onTap: () => _showComingSoon('DNS查询'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildListItem(
                    icon: Icons.terminal,
                    iconColor: Colors.grey,
                    title: 'Ping工具',
                    subtitle: '测试服务器连通性',
                    onTap: () => _showComingSoon('Ping工具'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 帮助与支持
            _buildSectionTitle('帮助与支持'),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildListItem(
                    icon: Icons.help_outline,
                    iconColor: Colors.blue,
                    title: '帮助文档',
                    subtitle: '查看使用帮助和常见问题',
                    onTap: () => _launchUrl('https://www.rainyun.com/docs/'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildListItem(
                    icon: Icons.headset_mic,
                    iconColor: Colors.green,
                    title: '联系客服',
                    subtitle: '在线咨询或提交工单',
                    onTap: () => _launchUrl('https://www.rainyun.com/contact/'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildListItem(
                    icon: Icons.group,
                    iconColor: Colors.blue.shade700,
                    title: '加入QQ群',
                    subtitle: '与其他用户交流',
                    onTap: () => _showQQGroupDialog(),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildListItem(
                    icon: Icons.language,
                    iconColor: Colors.orange,
                    title: '访问官网',
                    subtitle: 'www.rainyun.com',
                    onTap: () => _launchUrl('https://www.rainyun.com'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 关于
            _buildSectionTitle('关于'),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildListItem(
                    icon: Icons.info_outline,
                    iconColor: Colors.grey,
                    title: '关于应用',
                    subtitle: 'RainyunApp v0.0.1',
                    onTap: () => _showAboutDialog(),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildListItem(
                    icon: Icons.code,
                    iconColor: Colors.black87,
                    title: '开源地址',
                    subtitle: 'GitHub',
                    onTap: () => _launchUrl('https://github.com'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    TDToast.showText('$feature 功能开发中', context: context);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showInviteDialog() async {
    try {
      final response = await _apiService.getUserInfo();
      String shareCode = '';
      if (response['code'] == 200) {
        shareCode = response['data']['ShareCode'] ?? '';
      }
      
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('邀请好友'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('分享您的邀请链接，好友注册后双方都可获得积分奖励！'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  shareCode.isNotEmpty 
                    ? 'https://www.rainyun.com/$shareCode'
                    : '请先绑定API Key',
                  style: const TextStyle(fontSize: 14),
                ),
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
    } catch (e) {
      TDToast.showFail('获取邀请链接失败', context: context);
    }
  }

  void _showQQGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('加入QQ群'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('雨云官方交流群：'),
            SizedBox(height: 8),
            SelectableText('1群：326077768', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            SelectableText('2群：617115645', style: TextStyle(fontSize: 16)),
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于应用'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RainyunApp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('版本：0.0.1'),
            SizedBox(height: 4),
            Text('雨云第三方客户端'),
            SizedBox(height: 12),
            Text('本应用仅供学习交流使用', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
}
