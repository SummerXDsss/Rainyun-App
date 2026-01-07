import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/rainyun_api_service.dart';

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
      final productResponse = await _apiService.getProductList();
      
      // API返回小写字段名
      final code = productResponse['code'] ?? productResponse['Code'];
      final responseData = productResponse['data'] ?? productResponse['Data'];
      
      if (code == 200 && responseData != null) {
        final data = responseData as Map<String, dynamic>;
        final List<Map<String, dynamic>> allServers = [];

        if (data['RCS'] != null) {
          final rcsList = data['RCS'] as List;
          allServers.addAll(rcsList.map((e) => {
            ...e as Map<String, dynamic>,
            'type': 'RCS',
          }));
        }

        if (data['RGS'] != null) {
          final rgsList = data['RGS'] as List;
          allServers.addAll(rgsList.map((e) => {
            ...e as Map<String, dynamic>,
            'type': 'RGS',
          }));
        }

        if (data['NAT'] != null) {
          final natList = data['NAT'] as List;
          allServers.addAll(natList.map((e) => {
            ...e as Map<String, dynamic>,
            'type': 'NAT',
          }));
        }

        setState(() {
          _servers = allServers;
          _isLoading = false;
        });
      } else {
        throw Exception(productResponse['message'] ?? productResponse['Message'] ?? '获取服务器列表失败');
      }
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
    final type = server['type'] ?? 'Unknown';
    final name = server['Name'] ?? '未命名服务器';
    final status = server['Status'] ?? 'unknown';
    final productId = server['ProductID']?.toString() ?? '';
    final region = server['Region'] ?? '';
    final ip = server['IP'] ?? '';

    Color statusColor = Colors.grey;
    String statusText = '未知';
    if (status == 'running' || status == 'Running') {
      statusColor = Colors.green;
      statusText = '运行中';
    } else if (status == 'stopped' || status == 'Stopped') {
      statusColor = Colors.red;
      statusText = '已停止';
    }

    return Container(
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
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: theme.hintColor),
                const SizedBox(width: 4),
                Text(region, style: TextStyle(color: theme.hintColor)),
                const SizedBox(width: 16),
                Icon(Icons.computer, size: 16, color: theme.hintColor),
                const SizedBox(width: 4),
                Text(ip, style: TextStyle(color: theme.hintColor)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TDButton(
                    text: '开机',
                    size: TDButtonSize.small,
                    type: TDButtonType.outline,
                    theme: TDButtonTheme.primary,
                    disabled: status == 'running' || status == 'Running',
                    onTap: () => _performAction(productId, 'start', type),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TDButton(
                    text: '关机',
                    size: TDButtonSize.small,
                    type: TDButtonType.outline,
                    theme: TDButtonTheme.danger,
                    disabled: status == 'stopped' || status == 'Stopped',
                    onTap: () => _performAction(productId, 'stop', type),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TDButton(
                    text: '重启',
                    size: TDButtonSize.small,
                    type: TDButtonType.outline,
                    theme: TDButtonTheme.defaultTheme,
                    onTap: () => _performAction(productId, 'restart', type),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
