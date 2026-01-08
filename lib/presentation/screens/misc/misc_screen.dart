import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              child: _buildListItem(
                icon: Icons.stars,
                iconColor: Colors.orange,
                title: '积分中心',
                subtitle: '完成任务赚积分，兑换产品和优惠券',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PointsScreen()),
                ),
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
                    onTap: () => _showMyInvitesDialog(),
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
                    subtitle: '测试下载速度',
                    onTap: () => _showSpeedTestDialog(),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildListItem(
                    icon: Icons.dns,
                    iconColor: Colors.teal,
                    title: 'DNS查询',
                    subtitle: '查询域名DNS记录',
                    onTap: () => _showDnsDialog(),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildListItem(
                    icon: Icons.terminal,
                    iconColor: Colors.grey,
                    title: 'Ping工具',
                    subtitle: '测试服务器连通性',
                    onTap: () => _showPingDialog(),
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // 邀请好友对话框
  void _showInviteDialog() async {
    try {
      TDToast.showLoading(context: context, text: '加载中...');
      final response = await _apiService.getUserInfo();
      TDToast.dismissLoading();
      
      String shareCode = '';
      String inviteUrl = '';
      if (response['code'] == 200) {
        shareCode = response['data']['ShareCode'] ?? '';
        if (shareCode.isNotEmpty) {
          inviteUrl = 'https://www.rainyun.com/$shareCode';
        }
      }
      
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('邀请好友'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('分享您的邀请链接，好友注册后双方都可获得积分奖励！'),
              const SizedBox(height: 16),
              const Text('邀请码:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  shareCode.isNotEmpty ? shareCode : '请先绑定API Key',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 12),
              const Text('邀请链接:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  inviteUrl.isNotEmpty ? inviteUrl : '请先绑定API Key',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            if (inviteUrl.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: inviteUrl));
                  TDToast.showSuccess('已复制邀请链接', context: context);
                },
                child: const Text('复制链接'),
              ),
          ],
        ),
      );
    } catch (e) {
      TDToast.dismissLoading();
      TDToast.showFail('获取邀请信息失败', context: context);
    }
  }

  // 我的邀请对话框
  void _showMyInvitesDialog() async {
    try {
      TDToast.showLoading(context: context, text: '加载中...');
      
      // 获取用户信息中的邀请数据
      final userResponse = await _apiService.getUserInfo();
      TDToast.dismissLoading();
      
      if (!mounted) return;
      
      List<dynamic> invites = [];
      int totalReward = 0;
      int inviteCount = 0;
      
      if (userResponse['code'] == 200) {
        final userData = userResponse['data'];
        inviteCount = userData['InviteCount'] ?? 0;
        totalReward = userData['InviteReward'] ?? 0;
      }
      
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('我的邀请', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInviteStatCard('邀请人数', '$inviteCount', Icons.people, Colors.blue),
                  _buildInviteStatCard('累计奖励', '$totalReward', Icons.stars, Colors.orange),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('邀请好友注册雨云', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text(
                      '好友消费可获得推广返利',
                      style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    } catch (e) {
      TDToast.dismissLoading();
      TDToast.showFail('获取邀请信息失败', context: context);
    }
  }

  Widget _buildInviteStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
        ],
      ),
    );
  }

  // 网络测速对话框
  void _showSpeedTestDialog() {
    showDialog(
      context: context,
      builder: (context) => _SpeedTestDialog(),
    );
  }

  // DNS查询对话框
  void _showDnsDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _DnsQueryDialog(controller: controller),
    );
  }

  // Ping工具对话框
  void _showPingDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _PingDialog(controller: controller),
    );
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
}

// 网络测速对话框
class _SpeedTestDialog extends StatefulWidget {
  @override
  State<_SpeedTestDialog> createState() => _SpeedTestDialogState();
}

class _SpeedTestDialogState extends State<_SpeedTestDialog> {
  bool _isTesting = false;
  String _status = '点击开始测速';
  double _downloadSpeed = 0;
  int _progress = 0;

  Future<void> _startTest() async {
    setState(() {
      _isTesting = true;
      _status = '正在测试...';
      _downloadSpeed = 0;
      _progress = 0;
    });

    try {
      // 使用HTTP下载测试速度
      final testUrls = [
        'https://speed.cloudflare.com/__down?bytes=10000000', // 10MB
      ];
      
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      
      final stopwatch = Stopwatch()..start();
      int totalBytes = 0;
      
      for (var url in testUrls) {
        try {
          final request = await client.getUrl(Uri.parse(url));
          final response = await request.close();
          
          await for (var data in response) {
            totalBytes += data.length;
            if (stopwatch.elapsedMilliseconds > 0) {
              final speed = (totalBytes / 1024 / 1024) / (stopwatch.elapsedMilliseconds / 1000);
              setState(() {
                _downloadSpeed = speed;
                _progress = (totalBytes / 10000000 * 100).clamp(0, 100).toInt();
                _status = '测速中 $_progress%';
              });
            }
          }
        } catch (e) {
          debugPrint('测速请求失败: $e');
        }
      }
      
      stopwatch.stop();
      client.close();
      
      setState(() {
        _isTesting = false;
        _status = '测试完成';
        _progress = 100;
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _status = '测试失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('网络测速'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _progress / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _downloadSpeed.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('MB/s', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(_status, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
        ElevatedButton(
          onPressed: _isTesting ? null : _startTest,
          child: Text(_isTesting ? '测试中...' : '开始测速'),
        ),
      ],
    );
  }
}

// DNS查询对话框
class _DnsQueryDialog extends StatefulWidget {
  final TextEditingController controller;
  const _DnsQueryDialog({required this.controller});

  @override
  State<_DnsQueryDialog> createState() => _DnsQueryDialogState();
}

class _DnsQueryDialogState extends State<_DnsQueryDialog> {
  bool _isQuerying = false;
  List<String> _results = [];
  String? _error;

  Future<void> _query() async {
    final domain = widget.controller.text.trim();
    if (domain.isEmpty) {
      TDToast.showText('请输入域名', context: context);
      return;
    }

    setState(() {
      _isQuerying = true;
      _results = [];
      _error = null;
    });

    try {
      final addresses = await InternetAddress.lookup(domain);
      setState(() {
        _results = addresses.map((a) => '${a.type.name}: ${a.address}').toList();
        _isQuerying = false;
      });
    } catch (e) {
      setState(() {
        _error = '查询失败: $e';
        _isQuerying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('DNS查询'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.controller,
              decoration: const InputDecoration(
                labelText: '域名',
                hintText: '例如: www.rainyun.com',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _query(),
            ),
            const SizedBox(height: 16),
            if (_isQuerying)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_results.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SelectableText(_results[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
        ElevatedButton(
          onPressed: _isQuerying ? null : _query,
          child: const Text('查询'),
        ),
      ],
    );
  }
}

// Ping工具对话框
class _PingDialog extends StatefulWidget {
  final TextEditingController controller;
  const _PingDialog({required this.controller});

  @override
  State<_PingDialog> createState() => _PingDialogState();
}

class _PingDialogState extends State<_PingDialog> {
  bool _isPinging = false;
  List<String> _results = [];
  String? _error;
  int _successCount = 0;
  int _failCount = 0;
  List<int> _times = [];

  Future<void> _ping() async {
    final host = widget.controller.text.trim();
    if (host.isEmpty) {
      TDToast.showText('请输入地址', context: context);
      return;
    }

    setState(() {
      _isPinging = true;
      _results = [];
      _error = null;
      _successCount = 0;
      _failCount = 0;
      _times = [];
    });

    try {
      // 先解析域名
      final addresses = await InternetAddress.lookup(host);
      if (addresses.isEmpty) {
        throw Exception('无法解析域名');
      }
      final ip = addresses.first.address;
      
      // 进行4次ping测试（使用Socket连接测试）
      for (int i = 0; i < 4; i++) {
        if (!mounted) break;
        
        final stopwatch = Stopwatch()..start();
        try {
          final socket = await Socket.connect(ip, 80, timeout: const Duration(seconds: 3));
          stopwatch.stop();
          socket.destroy();
          
          final time = stopwatch.elapsedMilliseconds;
          _times.add(time);
          _successCount++;
          setState(() {
            _results.add('来自 $ip 的回复: 时间=${time}ms');
          });
        } catch (e) {
          stopwatch.stop();
          _failCount++;
          setState(() {
            _results.add('请求超时');
          });
        }
        
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      // 添加统计
      if (_times.isNotEmpty) {
        final avg = _times.reduce((a, b) => a + b) / _times.length;
        final min = _times.reduce((a, b) => a < b ? a : b);
        final max = _times.reduce((a, b) => a > b ? a : b);
        setState(() {
          _results.add('---');
          _results.add('统计: 发送=4, 接收=$_successCount, 丢失=$_failCount');
          _results.add('往返时间: 最小=${min}ms, 最大=${max}ms, 平均=${avg.toStringAsFixed(0)}ms');
        });
      }
      
      setState(() => _isPinging = false);
    } catch (e) {
      setState(() {
        _error = '测试失败: $e';
        _isPinging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ping工具'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.controller,
              decoration: const InputDecoration(
                labelText: '地址',
                hintText: '例如: www.rainyun.com',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _ping(),
            ),
            const SizedBox(height: 16),
            if (_isPinging)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('正在测试...'),
                ],
              )
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_results.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) => Text(
                    _results[index],
                    style: const TextStyle(color: Colors.green, fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
        ElevatedButton(
          onPressed: _isPinging ? null : _ping,
          child: const Text('Ping'),
        ),
      ],
    );
  }
}
