import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/rainyun_api_service.dart';

class ServerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> server;

  const ServerDetailScreen({super.key, required this.server});

  @override
  State<ServerDetailScreen> createState() => _ServerDetailScreenState();
}

class _ServerDetailScreenState extends State<ServerDetailScreen> {
  final RainyunApiService _apiService = RainyunApiService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final server = widget.server;
    final type = server['type'] ?? 'RCS';
    final hostName = server['HostName'] ?? '未命名';
    final status = server['Status'] ?? 'unknown';
    final productId = server['ID']?.toString() ?? '';
    final ip = server['MainIPv4'] ?? '';
    final expDate = server['ExpDate'] as int? ?? 0;
    
    // 节点信息
    final node = server['Node'] as Map<String, dynamic>? ?? {};
    final region = node['Region'] ?? '';
    final chineseName = node['ChineseName'] ?? '';
    
    // 配置信息
    final plan = server['Plan'] as Map<String, dynamic>? ?? {};
    final cpu = plan['cpu'] ?? 0;
    final memory = plan['memory'] ?? 0;
    final netIn = server['NetIn'] ?? 0;
    final netOut = server['NetOut'] ?? 0;
    
    // 使用率
    final usageData = server['UsageData'] as Map<String, dynamic>? ?? {};
    final cpuUsage = (usageData['CPU'] as num?)?.toDouble() ?? 0;
    final maxMem = usageData['MaxMem'] as int? ?? 1;
    final freeMem = usageData['FreeMem'] as int? ?? 0;
    final memUsage = maxMem > 0 ? ((maxMem - freeMem) / maxMem * 100) : 0;
    
    // 系统信息
    final osName = server['OsName'] ?? '';
    final osInfo = server['OsInfo'] as Map<String, dynamic>? ?? {};
    final osChineseName = osInfo['chinese_name'] ?? osName;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(hostName),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态卡片
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: status == 'running'
                      ? [Colors.green, Colors.green.shade700]
                      : [Colors.red, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    status == 'running' ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status == 'running' ? '运行中' : '已停止',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'IP: $ip',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 操作按钮
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.play_arrow,
                      label: '开机',
                      color: Colors.green,
                      enabled: status != 'running',
                      onTap: () => _performAction(productId, 'start', type),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.stop,
                      label: '关机',
                      color: Colors.red,
                      enabled: status == 'running',
                      onTap: () => _performAction(productId, 'stop', type),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.refresh,
                      label: '重启',
                      color: Colors.orange,
                      enabled: status == 'running',
                      onTap: () => _performAction(productId, 'restart', type),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 资源使用率
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '资源使用率',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildUsageBar('CPU', cpuUsage, Colors.blue),
                  const SizedBox(height: 12),
                  _buildUsageBar('内存', memUsage.toDouble(), Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 服务器信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '服务器信息',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('节点', chineseName),
                  _buildInfoRow('地区', _getRegionWithFlag(region)),
                  _buildInfoRow('系统', osChineseName),
                  _buildInfoRow('配置', '$cpu核 / ${(memory / 1024).toStringAsFixed(0)}GB'),
                  _buildInfoRow('带宽', '${netIn}M / ${netOut}M'),
                  _buildInfoRow('到期时间', _formatExpDate(expDate)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 高级选项
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '高级选项',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildAdvancedOption(
                    icon: Icons.swap_horiz,
                    color: Colors.purple,
                    title: '更换IP',
                    subtitle: '更换服务器公网IP地址',
                    onTap: () => _showChangeIpDialog(productId, ip, type),
                  ),
                  const Divider(height: 1),
                  _buildAdvancedOption(
                    icon: Icons.delete_outline,
                    color: Colors.orange,
                    title: '放弃IP',
                    subtitle: '释放当前公网IP',
                    onTap: () => _showReleaseIpDialog(productId, ip, type),
                  ),
                  const Divider(height: 1),
                  _buildAdvancedOption(
                    icon: Icons.shield_outlined,
                    color: Colors.blue,
                    title: '防火墙规则',
                    subtitle: '管理服务器防火墙规则',
                    onTap: () => _showFirewallDialog(productId, type),
                  ),
                  const Divider(height: 1),
                  _buildAdvancedOption(
                    icon: Icons.apps,
                    color: Colors.green,
                    title: '快速安装应用',
                    subtitle: '一键安装常用应用程序',
                    onTap: () => _showAppInstallDialog(productId, type),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled && !_isLoading ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: enabled ? color : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: enabled ? color : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600])),
            Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _getRegionWithFlag(String region) {
    if (region.contains('hk') || region.contains('HK')) {
      return '🇭🇰 香港';
    } else if (region.contains('tw') || region.contains('TW')) {
      return '🇹🇼 台湾';
    } else if (region.contains('jp') || region.contains('JP')) {
      return '🇯🇵 日本';
    } else if (region.contains('kr') || region.contains('KR')) {
      return '🇰🇷 韩国';
    } else if (region.contains('sg') || region.contains('SG')) {
      return '🇸🇬 新加坡';
    } else if (region.contains('us') || region.contains('US')) {
      return '🇺🇸 美国';
    } else if (region.contains('de') || region.contains('DE')) {
      return '🇩🇪 德国';
    } else if (region.contains('cn') && !region.contains('hk') && !region.contains('tw')) {
      return '🇨🇳 中国大陆';
    }
    return region;
  }

  String _formatExpDate(int timestamp) {
    if (timestamp == 0) return '未知';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    
    String dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    if (diff < 0) {
      return '$dateStr (已过期)';
    } else if (diff <= 7) {
      return '$dateStr (${diff}天后到期)';
    }
    return dateStr;
  }

  Future<void> _performAction(String productId, String action, String type) async {
    setState(() => _isLoading = true);
    TDToast.showLoading(context: context, text: '执行中...');

    try {
      Map<String, dynamic> response;
      if (type == 'RCS') {
        if (action == 'start') {
          response = await _apiService.rcsStart(productId);
        } else if (action == 'stop') {
          response = await _apiService.rcsStop(productId);
        } else {
          response = await _apiService.rcsRestart(productId);
        }
      } else {
        throw Exception('暂不支持该类型服务器操作');
      }

      if (mounted) {
        TDToast.dismissLoading();
        final code = response['code'] ?? response['Code'];
        if (code == 200) {
          TDToast.showSuccess('操作成功', context: context);
        } else {
          TDToast.showFail(response['message'] ?? '操作失败', context: context);
        }
      }
    } catch (e) {
      if (mounted) {
        TDToast.dismissLoading();
        TDToast.showFail('操作失败：$e', context: context);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildAdvancedOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // 更换IP对话框
  void _showChangeIpDialog(String productId, String currentIp, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更换IP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前IP: $currentIp'),
            const SizedBox(height: 12),
            const Text('确定要更换IP吗？更换后原IP将无法使用。', style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _changeIp(productId, currentIp, type);
            },
            child: const Text('确认更换'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeIp(String productId, String currentIp, String type) async {
    TDToast.showLoading(context: context, text: '更换中...');
    try {
      final response = await _apiService.post(
        '/product/rcs/$productId/eip/change',
        data: {'ip': currentIp},
      );
      if (mounted) {
        TDToast.dismissLoading();
        if (response['code'] == 200) {
          TDToast.showSuccess('更换IP成功', context: context);
        } else {
          TDToast.showFail(response['message'] ?? '更换失败', context: context);
        }
      }
    } catch (e) {
      if (mounted) {
        TDToast.dismissLoading();
        TDToast.showFail('更换失败: $e', context: context);
      }
    }
  }

  // 放弃IP对话框
  void _showReleaseIpDialog(String productId, String currentIp, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('放弃IP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前IP: $currentIp'),
            const SizedBox(height: 12),
            const Text('确定要放弃此IP吗？放弃后将无法恢复。', style: TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _releaseIp(productId, currentIp, type);
            },
            child: const Text('确认放弃'),
          ),
        ],
      ),
    );
  }

  Future<void> _releaseIp(String productId, String currentIp, String type) async {
    TDToast.showLoading(context: context, text: '处理中...');
    try {
      final response = await _apiService.post(
        '/product/rcs/$productId/eip/release',
        data: {'ip': currentIp},
      );
      if (mounted) {
        TDToast.dismissLoading();
        if (response['code'] == 200) {
          TDToast.showSuccess('放弃IP成功', context: context);
        } else {
          TDToast.showFail(response['message'] ?? '操作失败', context: context);
        }
      }
    } catch (e) {
      if (mounted) {
        TDToast.dismissLoading();
        TDToast.showFail('操作失败: $e', context: context);
      }
    }
  }

  // 防火墙规则对话框
  void _showFirewallDialog(String productId, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FirewallSheet(productId: productId, apiService: _apiService),
    );
  }

  // 快速安装应用对话框
  void _showAppInstallDialog(String productId, String type) {
    TDToast.showText('快速安装应用功能开发中', context: context);
  }
}

// 防火墙规则管理Sheet
class _FirewallSheet extends StatefulWidget {
  final String productId;
  final RainyunApiService apiService;

  const _FirewallSheet({required this.productId, required this.apiService});

  @override
  State<_FirewallSheet> createState() => _FirewallSheetState();
}

class _FirewallSheetState extends State<_FirewallSheet> {
  List<Map<String, dynamic>> _rules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get(
        '/product/rcs/${widget.productId}/firewall/rule',
        queryParameters: {'options': '{}'},
      );
      if (response['code'] == 200) {
        final data = response['data'];
        if (data is List) {
          setState(() => _rules = data.map((e) => Map<String, dynamic>.from(e)).toList());
        }
      }
    } catch (e) {
      debugPrint('加载防火墙规则失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('防火墙规则', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddRuleDialog(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadRules,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _rules.isEmpty
                    ? const Center(child: Text('暂无防火墙规则'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _rules.length,
                        itemBuilder: (context, index) => _buildRuleItem(_rules[index], index),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(Map<String, dynamic> rule, int index) {
    final action = rule['action'] ?? 'accept';
    final protocol = rule['protocol'] ?? 'tcp';
    final port = rule['port'] ?? '';
    final source = rule['source'] ?? '0.0.0.0/0';
    final isAccept = action == 'accept';

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isAccept ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isAccept ? Icons.check : Icons.block,
          color: isAccept ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      title: Text('$protocol ${port.isEmpty ? "所有端口" : port}'),
      subtitle: Text('来源: $source'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_upward, size: 20),
            onPressed: index > 0 ? () => _moveRule(rule, 'up') : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward, size: 20),
            onPressed: index < _rules.length - 1 ? () => _moveRule(rule, 'down') : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            onPressed: () => _deleteRule(rule),
          ),
        ],
      ),
    );
  }

  void _showAddRuleDialog() {
    String action = 'accept';
    String protocol = 'tcp';
    String port = '';
    String source = '0.0.0.0/0';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加防火墙规则'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: action,
                  decoration: const InputDecoration(labelText: '动作'),
                  items: const [
                    DropdownMenuItem(value: 'accept', child: Text('允许')),
                    DropdownMenuItem(value: 'drop', child: Text('拒绝')),
                  ],
                  onChanged: (v) => setDialogState(() => action = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: protocol,
                  decoration: const InputDecoration(labelText: '协议'),
                  items: const [
                    DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                    DropdownMenuItem(value: 'udp', child: Text('UDP')),
                    DropdownMenuItem(value: 'icmp', child: Text('ICMP')),
                  ],
                  onChanged: (v) => setDialogState(() => protocol = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: '端口 (如: 80 或 8080-8090)', hintText: '留空表示所有端口'),
                  onChanged: (v) => port = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: source,
                  decoration: const InputDecoration(labelText: '来源IP (CIDR格式)'),
                  onChanged: (v) => source = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _addRule(action, protocol, port, source);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addRule(String action, String protocol, String port, String source) async {
    TDToast.showLoading(context: context, text: '添加中...');
    try {
      final response = await widget.apiService.post(
        '/product/rcs/${widget.productId}/firewall/rule',
        data: {
          'action': action,
          'protocol': protocol,
          'port': port,
          'source': source,
        },
      );
      if (mounted) {
        TDToast.dismissLoading();
        if (response['code'] == 200) {
          TDToast.showSuccess('添加成功', context: context);
          _loadRules();
        } else {
          TDToast.showFail(response['message'] ?? '添加失败', context: context);
        }
      }
    } catch (e) {
      if (mounted) {
        TDToast.dismissLoading();
        TDToast.showFail('添加失败: $e', context: context);
      }
    }
  }

  Future<void> _deleteRule(Map<String, dynamic> rule) async {
    final ruleId = rule['id'];
    if (ruleId == null) return;

    TDToast.showLoading(context: context, text: '删除中...');
    try {
      final response = await widget.apiService.delete(
        '/product/rcs/${widget.productId}/firewall/rule/$ruleId',
      );
      if (mounted) {
        TDToast.dismissLoading();
        if (response['code'] == 200) {
          TDToast.showSuccess('删除成功', context: context);
          _loadRules();
        } else {
          TDToast.showFail(response['message'] ?? '删除失败', context: context);
        }
      }
    } catch (e) {
      if (mounted) {
        TDToast.dismissLoading();
        TDToast.showFail('删除失败: $e', context: context);
      }
    }
  }

  Future<void> _moveRule(Map<String, dynamic> rule, String direction) async {
    final ruleId = rule['id'];
    if (ruleId == null) return;

    TDToast.showLoading(context: context, text: '移动中...');
    try {
      final response = await widget.apiService.put(
        '/product/rcs/${widget.productId}/firewall/rule/$ruleId/move',
        data: {'direction': direction},
      );
      if (mounted) {
        TDToast.dismissLoading();
        if (response['code'] == 200) {
          TDToast.showSuccess('移动成功', context: context);
          _loadRules();
        } else {
          TDToast.showFail(response['message'] ?? '移动失败', context: context);
        }
      }
    } catch (e) {
      if (mounted) {
        TDToast.dismissLoading();
        TDToast.showFail('移动失败: $e', context: context);
      }
    }
  }
}
