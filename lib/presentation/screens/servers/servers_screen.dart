import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/rainyun_api_service.dart';
import 'server_detail_screen.dart';

class ServersScreen extends ConsumerStatefulWidget {
  const ServersScreen({super.key});

  @override
  ConsumerState<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends ConsumerState<ServersScreen> {
  final _apiService = RainyunApiService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _servers = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    if (!_apiService.hasApiKey()) {
      setState(() {
        _error = '请先在"我的"页面绑定API Key';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<Map<String, dynamic>> allServers = [];
      
      // 获取RCS云服务器列表（需要options参数）
      try {
        final rcsResponse = await _apiService.get('/product/rcs/', queryParameters: {'options': '{}'});
        final rcsCode = rcsResponse['code'] ?? rcsResponse['Code'];
        if (rcsCode == 200) {
          final rcsData = rcsResponse['data'] ?? rcsResponse['Data'];
          if (rcsData != null && rcsData['Records'] != null) {
            final rcsList = rcsData['Records'] as List;
            for (final e in rcsList) {
              final item = Map<String, dynamic>.from(e as Map);
              item['type'] = 'RCS';
              allServers.add(item);
            }
          }
        }
      } catch (e) {
        debugPrint('获取RCS列表失败: $e');
      }
      
      // 获取RGS游戏服务器列表（需要options参数）
      try {
        final rgsResponse = await _apiService.get('/product/rgs/', queryParameters: {'options': '{}'});
        final rgsCode = rgsResponse['code'] ?? rgsResponse['Code'];
        if (rgsCode == 200) {
          final rgsData = rgsResponse['data'] ?? rgsResponse['Data'];
          if (rgsData != null && rgsData['Records'] != null) {
            final rgsList = rgsData['Records'] as List;
            for (final e in rgsList) {
              final item = Map<String, dynamic>.from(e as Map);
              item['type'] = 'RGS';
              allServers.add(item);
            }
          }
        }
      } catch (e) {
        debugPrint('获取RGS列表失败: $e');
      }

      setState(() {
        _servers = allServers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _performAction(String productId, String action, String type) async {
    try {
      TDToast.showLoading(context: context);
      
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

      if (context.mounted) {
        TDToast.dismissLoading();
        final opCode = response['code'] ?? response['Code'];
        if (opCode == 200) {
          TDToast.showSuccess('操作成功', context: context);
          await Future.delayed(const Duration(seconds: 2));
          _loadServers();
        } else {
          TDToast.showFail(response['message'] ?? response['Message'] ?? '操作失败', context: context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        TDToast.dismissLoading();
        TDToast.showFail('操作失败：$e', context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '我的服务器',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : _loadServers,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.key_outlined, size: 80, color: theme.colorScheme.tertiary),
              const SizedBox(height: 24),
              const Text(
                '需要绑定 API Key',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadServers,
                icon: const Icon(Icons.refresh),
                label: const Text('重新加载'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading && _servers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载服务器列表中...'),
          ],
        ),
      );
    }

    if (_servers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dns_outlined, size: 64, color: theme.hintColor),
            const SizedBox(height: 16),
            Text(
              '暂无服务器',
              style: TextStyle(color: theme.hintColor, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '请先购买服务器产品',
              style: TextStyle(color: theme.hintColor, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _servers.length,
      itemBuilder: (context, index) {
        final server = _servers[index];
        return _buildServerCard(server, theme);
      },
    );
  }

  Widget _buildServerCard(Map<String, dynamic> server, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    
    final type = server['type'] ?? 'RCS';
    final hostName = server['HostName'] ?? '未命名';
    final status = server['Status'] ?? 'unknown';
    final ip = server['MainIPv4'] ?? '';
    final expDate = server['ExpDate'] as int? ?? 0;
    
    // 节点信息
    final node = server['Node'] as Map<String, dynamic>? ?? {};
    final region = node['Region'] ?? '';
    final zone = server['Zone'] ?? '';
    
    // 配置信息
    final plan = server['Plan'] as Map<String, dynamic>? ?? {};
    final cpu = plan['cpu'] ?? 0;
    final memory = plan['memory'] ?? 0;
    final netIn = server['NetIn'] ?? 0;
    final netOut = server['NetOut'] ?? 0;

    Color statusColor = Colors.grey;
    String statusText = '未知';
    if (status == 'running') {
      statusColor = Colors.green;
      statusText = '运行中';
    } else if (status == 'stopped') {
      statusColor = Colors.red;
      statusText = '已停止';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServerDetailScreen(server: server),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：类型、名称、状态
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hostName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 第二行：地区和IP
              Row(
                children: [
                  Text(_getRegionWithFlag(region), style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 8),
                  Text(zone, style: TextStyle(color: theme.hintColor, fontSize: 13)),
                  const Spacer(),
                  Text(ip, style: TextStyle(color: theme.hintColor, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              
              // 第三行：配置和带宽
              Row(
                children: [
                  _buildInfoChip(Icons.memory, '$cpu核 ${(memory / 1024).toStringAsFixed(0)}G', theme),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.speed, '${netIn}M/${netOut}M', theme),
                  const Spacer(),
                  Text(
                    '到期: ${_formatExpDate(expDate)}',
                    style: TextStyle(
                      color: _isExpiringSoon(expDate) ? Colors.orange : theme.hintColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.hintColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.hintColor),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: theme.hintColor)),
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
      return '🇨🇳 中国';
    }
    return region;
  }

  String _formatExpDate(int timestamp) {
    if (timestamp == 0) return '未知';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}年${date.month}月${date.day}日';
  }

  bool _isExpiringSoon(int timestamp) {
    if (timestamp == 0) return false;
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final diff = date.difference(DateTime.now()).inDays;
    return diff <= 7;
  }
}
