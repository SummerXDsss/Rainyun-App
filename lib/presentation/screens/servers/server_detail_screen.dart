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
  
  // 带宽监控数据
  double _bandwidthUsage = 0;
  List<Map<String, dynamic>> _monitorData = [];
  bool _isLoadingMonitor = false;

  @override
  void initState() {
    super.initState();
    final productId = widget.server['ID']?.toString() ?? '';
    if (productId.isNotEmpty) {
      _loadMonitorData(productId);
    }
  }

  Future<void> _loadMonitorData(String productId) async {
    if (_isLoadingMonitor) return;
    setState(() => _isLoadingMonitor = true);
    
    try {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final start = now - 43200; // 12小时前
      
      final response = await _apiService.get(
        '/product/rcs/$productId/monitor',
        queryParameters: {'start_date': start, 'end_date': now},
      );
      
      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'] as List? ?? [];
        setState(() {
          _monitorData = data.map((e) => Map<String, dynamic>.from(e)).toList();
          // 计算当前带宽使用率
          if (_monitorData.isNotEmpty) {
            final latest = _monitorData.last;
            final netOut = widget.server['NetOut'] ?? 50;
            final currentBw = (latest['net_out'] ?? 0) / 1024 / 1024 * 8; // Mbps
            _bandwidthUsage = (currentBw / netOut * 100).clamp(0, 100);
          }
        });
      }
    } catch (e) {
      debugPrint('加载监控数据失败: $e');
    } finally {
      if (mounted) setState(() => _isLoadingMonitor = false);
    }
  }

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
                  const SizedBox(height: 12),
                  _buildUsageBar('带宽', _bandwidthUsage, Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 资源监控图表（12小时）
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '资源监控 (12小时)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: () => _loadMonitorData(productId),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMonitorCharts(theme, netOut),
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
                  const Divider(height: 1),
                  _buildAdvancedOption(
                    icon: Icons.autorenew,
                    color: Colors.blue,
                    title: '续费服务',
                    subtitle: '延长服务器到期时间',
                    onTap: () => _showRenewOptionsSheet(productId, type),
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

  Widget _buildMonitorCharts(ThemeData theme, int maxBandwidth) {
    if (_isLoadingMonitor) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_monitorData.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 40, color: theme.hintColor),
              const SizedBox(height: 8),
              Text('暂无监控数据', style: TextStyle(color: theme.hintColor)),
            ],
          ),
        ),
      );
    }

    // 计算各项峰值
    double maxCpu = 0, maxMem = 0, maxNetIn = 0, maxNetOut = 0;
    for (var data in _monitorData) {
      final cpu = (data['cpu'] ?? 0).toDouble();
      final mem = (data['mem'] ?? 0).toDouble();
      final netIn = ((data['net_in'] ?? 0) / 1024 / 1024 * 8).toDouble();
      final netOut = ((data['net_out'] ?? 0) / 1024 / 1024 * 8).toDouble();
      if (cpu > maxCpu) maxCpu = cpu;
      if (mem > maxMem) maxMem = mem;
      if (netIn > maxNetIn) maxNetIn = netIn;
      if (netOut > maxNetOut) maxNetOut = netOut;
    }

    return Column(
      children: [
        // CPU 图表
        _buildChartSection(
          title: 'CPU 使用率',
          color: Colors.blue,
          dataKey: 'cpu',
          maxValue: 100,
          unit: '%',
          peakValue: maxCpu,
          theme: theme,
        ),
        const SizedBox(height: 16),
        
        // 内存图表
        _buildChartSection(
          title: '内存使用率',
          color: Colors.purple,
          dataKey: 'mem',
          maxValue: 100,
          unit: '%',
          peakValue: maxMem,
          theme: theme,
        ),
        const SizedBox(height: 16),
        
        // 带宽图表
        _buildBandwidthSection(theme, maxNetIn, maxNetOut, maxBandwidth),
      ],
    );
  }

  Widget _buildChartSection({
    required String title,
    required Color color,
    required String dataKey,
    required double maxValue,
    required String unit,
    required double peakValue,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
            Text('峰值: ${peakValue.toStringAsFixed(1)}$unit', style: TextStyle(fontSize: 11, color: theme.hintColor)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: CustomPaint(
            size: const Size(double.infinity, 60),
            painter: _SingleLineChartPainter(
              data: _monitorData,
              dataKey: dataKey,
              maxValue: maxValue,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBandwidthSection(ThemeData theme, double maxIn, double maxOut, int maxBandwidth) {
    final maxValue = (maxIn > maxOut ? maxIn : maxOut).clamp(1.0, double.infinity);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                const Text('网络带宽', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
            Row(
              children: [
                _buildLegend('入站', Colors.blue),
                const SizedBox(width: 12),
                _buildLegend('出站', Colors.green),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: CustomPaint(
            size: const Size(double.infinity, 60),
            painter: _BandwidthChartPainter(
              data: _monitorData,
              maxValue: maxValue,
              inColor: Colors.blue,
              outColor: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('12小时前', style: TextStyle(fontSize: 9, color: theme.hintColor)),
            Text('入峰: ${maxIn.toStringAsFixed(1)}M  出峰: ${maxOut.toStringAsFixed(1)}M', 
              style: TextStyle(fontSize: 9, color: theme.hintColor)),
            Text('现在', style: TextStyle(fontSize: 9, color: theme.hintColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 3, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
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
        '/product/rcs/$productId/eip/discard',
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _AppInstallSheet(
        productId: productId,
        productType: type.toLowerCase(),
        apiService: _apiService,
      ),
    );
  }

  // 续费服务选项
  void _showRenewOptionsSheet(String productId, String type) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('续费服务', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('选择续费方式', style: TextStyle(color: theme.hintColor)),
            const SizedBox(height: 20),
            
            // 余额续费
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.blue),
              ),
              title: const Text('余额续费'),
              subtitle: const Text('使用账户余额续费'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _showBalanceRenewDialog(productId, type);
              },
            ),
            const Divider(),
            
            // 积分续费
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.stars, color: Colors.amber),
              ),
              title: const Text('积分续费'),
              subtitle: const Text('开发中...'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('敬请期待', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 余额续费对话框
  void _showBalanceRenewDialog(String productId, String type) {
    showDialog(
      context: context,
      builder: (context) => _RenewDialog(
        apiService: _apiService,
        productId: productId,
        productType: type.toLowerCase(),
      ),
    );
  }
}

// 续费对话框
class _RenewDialog extends StatefulWidget {
  final RainyunApiService apiService;
  final String productId;
  final String productType;

  const _RenewDialog({
    required this.apiService,
    required this.productId,
    required this.productType,
  });

  @override
  State<_RenewDialog> createState() => _RenewDialogState();
}

class _RenewDialogState extends State<_RenewDialog> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  double _userBalance = 0;
  double _monthlyPrice = 0;  // 单月价格
  int _selectedDuration = 1;  // 默认1个月
  String? _error;

  // 续费时长选项：1、3、6、12个月
  final List<int> _durationOptions = [1, 3, 6, 12];

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      // 获取用户余额
      final userResponse = await widget.apiService.getUserInfo();
      if (userResponse['code'] == 200) {
        final userData = userResponse['data'];
        _userBalance = (userData['Money'] as num?)?.toDouble() ?? 0;
      }

      // 获取续费价格（API返回单月价格 {Price: 30}）
      final priceResponse = await widget.apiService.get(
        '/product/${widget.productType}/${widget.productId}/renew/',
      );
      if (priceResponse['code'] == 200) {
        final data = priceResponse['data'] ?? {};
        _monthlyPrice = (data['Price'] as num?)?.toDouble() ?? 0;
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = '加载失败: $e';
      });
    }
  }

  // 计算选中时长的总价
  double _getPriceForDuration(int duration) {
    return _monthlyPrice * duration;
  }

  double get _price => _getPriceForDuration(_selectedDuration);

  bool get _canRenew => _userBalance >= _price && _monthlyPrice > 0;

  Future<void> _doRenew() async {
    if (!_canRenew) {
      TDToast.showText('余额不足', context: context);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await widget.apiService.post(
        '/product/${widget.productType}/${widget.productId}/renew/',
        data: {
          'duration': _selectedDuration,
        },
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (response['code'] == 200) {
          TDToast.showSuccess('续费成功！延长了$_selectedDuration个月', context: context);
          Navigator.pop(context, true);
        } else {
          TDToast.showFail(response['message'] ?? '续费失败', context: context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        TDToast.showFail('续费失败: $e', context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.autorenew, color: Colors.blue),
          SizedBox(width: 8),
          Text('续费'),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : _error != null
              ? Text(_error!, style: const TextStyle(color: Colors.red))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 当前余额
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('当前余额'),
                          Text(
                            '¥${_userBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 续费时长选择
                    const Text('选择续费时长', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _durationOptions.map((duration) {
                        final isSelected = _selectedDuration == duration;
                        final price = _getPriceForDuration(duration);
                        final canAfford = _userBalance >= price && _monthlyPrice > 0;
                        
                        return GestureDetector(
                          onTap: canAfford ? () => setState(() => _selectedDuration = duration) : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primaryColor
                                  : canAfford
                                      ? theme.hintColor.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$duration个月',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : canAfford
                                            ? null
                                            : Colors.grey,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _monthlyPrice > 0 ? '¥${price.toStringAsFixed(0)}' : '-',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? Colors.white70
                                        : canAfford
                                            ? theme.hintColor
                                            : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 费用明细
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.hintColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('续费时长'),
                              Text('$_selectedDuration 个月'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('需支付', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '¥${_price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: _canRenew ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (!_canRenew && _price > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '余额不足，还需 ¥${(_price - _userBalance).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _isSubmitting || !_canRenew ? null : _doRenew,
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('确认续费'),
        ),
      ],
    );
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
          'action': action.toUpperCase(), // API要求大写
          'protocol': protocol.isNotEmpty ? protocol : null,
          'dest_port': port.isNotEmpty ? port : null,
          'source_address': source.isNotEmpty ? source : null,
          'is_enable': true,
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
    final currentIndex = _rules.indexOf(rule);
    if (ruleId == null || currentIndex < 0) return;

    // 计算新位置
    int newPos;
    if (direction == 'up' && currentIndex > 0) {
      newPos = currentIndex - 1;
    } else if (direction == 'down' && currentIndex < _rules.length - 1) {
      newPos = currentIndex + 1;
    } else {
      return; // 无法移动
    }

    TDToast.showLoading(context: context, text: '移动中...');
    try {
      final response = await widget.apiService.put(
        '/product/rcs/${widget.productId}/firewall/rule/$ruleId/pos',
        data: {'newPos': newPos},
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

// 带宽图表绘制器
class _BandwidthChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxValue;
  final Color inColor;
  final Color outColor;

  _BandwidthChartPainter({
    required this.data,
    required this.maxValue,
    required this.inColor,
    required this.outColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final inPaint = Paint()
      ..color = inColor.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final outPaint = Paint()
      ..color = outColor.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final inPath = Path();
    final outPath = Path();

    final step = size.width / (data.length - 1).clamp(1, double.infinity);

    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final netIn = ((data[i]['net_in'] ?? 0) / 1024 / 1024 * 8).toDouble();
      final netOut = ((data[i]['net_out'] ?? 0) / 1024 / 1024 * 8).toDouble();

      final yIn = size.height - (netIn / maxValue * size.height).clamp(0, size.height);
      final yOut = size.height - (netOut / maxValue * size.height).clamp(0, size.height);

      if (i == 0) {
        inPath.moveTo(x, yIn);
        outPath.moveTo(x, yOut);
      } else {
        inPath.lineTo(x, yIn);
        outPath.lineTo(x, yOut);
      }
    }

    canvas.drawPath(inPath, inPaint);
    canvas.drawPath(outPath, outPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 单线图表绘制器（用于CPU、内存）
class _SingleLineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final String dataKey;
  final double maxValue;
  final Color color;

  _SingleLineChartPainter({
    required this.data,
    required this.dataKey,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // 绘制背景网格
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;
    
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 绘制折线
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 绘制填充区域
    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final linePath = Path();
    final fillPath = Path();

    final step = size.width / (data.length - 1).clamp(1, double.infinity);

    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final value = (data[i][dataKey] ?? 0).toDouble();
      final y = size.height - (value / maxValue * size.height).clamp(0, size.height);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // 完成填充路径
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 快速安装应用Sheet
class _AppInstallSheet extends StatefulWidget {
  final String productId;
  final String productType;
  final RainyunApiService apiService;

  const _AppInstallSheet({
    required this.productId,
    required this.productType,
    required this.apiService,
  });

  @override
  State<_AppInstallSheet> createState() => _AppInstallSheetState();
}

class _AppInstallSheetState extends State<_AppInstallSheet> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _apps = [];

  // 预定义的常用应用列表
  final List<Map<String, String>> _defaultApps = [
    {'name': 'Docker', 'icon': '🐳', 'desc': '容器化平台'},
    {'name': 'Nginx', 'icon': '🌐', 'desc': 'Web服务器'},
    {'name': 'MySQL', 'icon': '🗄️', 'desc': '关系型数据库'},
    {'name': 'Redis', 'icon': '⚡', 'desc': '缓存数据库'},
    {'name': 'Node.js', 'icon': '💚', 'desc': 'JavaScript运行时'},
    {'name': 'Python', 'icon': '🐍', 'desc': 'Python环境'},
    {'name': 'PHP', 'icon': '🐘', 'desc': 'PHP环境'},
    {'name': 'Java', 'icon': '☕', 'desc': 'Java环境'},
    {'name': 'MongoDB', 'icon': '🍃', 'desc': 'NoSQL数据库'},
    {'name': 'PostgreSQL', 'icon': '🐘', 'desc': '关系型数据库'},
    {'name': 'Git', 'icon': '📦', 'desc': '版本控制'},
    {'name': 'Vim', 'icon': '📝', 'desc': '文本编辑器'},
  ];

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final response = await widget.apiService.get(
        '/fast-install-app',
        queryParameters: {'product_type': widget.productType},
      );
      
      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'] as List? ?? [];
        setState(() {
          _apps = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } else {
        // API不可用时使用默认列表
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _installApp(String appName) async {
    TDToast.showLoading(context: context, text: '正在安装 $appName...');
    
    try {
      final response = await widget.apiService.post(
        '/product/rcs/${widget.productId}/fai-send',
        data: {'app_name': appName},
      );
      
      if (mounted) {
        TDToast.dismissLoading();
        if (response['code'] == 200) {
          TDToast.showSuccess('安装任务已发送', context: context);
        } else {
          TDToast.showFail(response['message'] ?? '安装失败', context: context);
        }
      }
    } catch (e) {
      if (mounted) {
        TDToast.dismissLoading();
        TDToast.showFail('安装失败: $e', context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayApps = _apps.isNotEmpty ? _apps : _defaultApps;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('快速安装应用', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${displayApps.length}个应用', style: TextStyle(color: theme.hintColor)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: displayApps.length,
                    itemBuilder: (context, index) {
                      final app = displayApps[index];
                      final name = app['name'] ?? '';
                      final icon = app['icon'] ?? '📦';
                      final desc = app['desc'] ?? app['description'] ?? '';
                      
                      return GestureDetector(
                        onTap: () => _showInstallConfirm(name),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(icon, style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (desc.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  desc,
                                  style: TextStyle(fontSize: 10, color: theme.hintColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showInstallConfirm(String appName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('安装 $appName'),
        content: Text('确定要在服务器上安装 $appName 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _installApp(appName);
            },
            child: const Text('确认安装'),
          ),
        ],
      ),
    );
  }
}
