import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_widget/home_widget.dart';
import '../../../core/services/rainyun_api_service.dart';
import '../../../core/services/widget_service.dart';

/// 小组件设置页面 - 选择要在桌面显示的服务器
class WidgetSettingsScreen extends StatefulWidget {
  final int? widgetId; // 从小组件点击进入时传入的widgetId
  
  const WidgetSettingsScreen({super.key, this.widgetId});

  @override
  State<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends State<WidgetSettingsScreen> {
  final _apiService = RainyunApiService();
  final _widgetService = WidgetService();
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  bool _isSyncing = false;
  List<Map<String, dynamic>> _servers = [];
  Map<String, String> _serverAliases = {};
  int? _selectedServerId;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _servers.clear();
    
    try {
      // 获取当前选中的服务器
      _selectedServerId = await _widgetService.getSelectedServerId();
      
      // 获取RCS服务器列表
      final rcsResponse = await _apiService.get('/product/rcs/', queryParameters: {'options': '{}'});
      final rcsCode = rcsResponse['code'] ?? rcsResponse['Code'];
      if (rcsCode == 200) {
        final rcsData = rcsResponse['data'] ?? rcsResponse['Data'];
        if (rcsData != null && rcsData['Records'] != null) {
          final rcsList = rcsData['Records'] as List;
          for (final e in rcsList) {
            final item = Map<String, dynamic>.from(e as Map);
            item['type'] = 'RCS';
            _servers.add(item);
          }
        }
      }
      
      // 获取RGS服务器列表
      final rgsResponse = await _apiService.get('/product/rgs/', queryParameters: {'options': '{}'});
      final rgsCode = rgsResponse['code'] ?? rgsResponse['Code'];
      if (rgsCode == 200) {
        final rgsData = rgsResponse['data'] ?? rgsResponse['Data'];
        if (rgsData != null && rgsData['Records'] != null) {
          final rgsList = rgsData['Records'] as List;
          for (final e in rgsList) {
            final item = Map<String, dynamic>.from(e as Map);
            item['type'] = 'RGS';
            _servers.add(item);
          }
        }
      }
      // 加载服务器别名
      await _loadAliases();
    } catch (e) {
      debugPrint('加载服务器列表失败: $e');
    }
    
    setState(() => _isLoading = false);
  }
  
  Future<void> _loadAliases() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      final response = await _supabase
          .from('server_aliases')
          .select()
          .eq('user_id', user.id);
      
      final aliases = <String, String>{};
      for (final row in response) {
        final key = '${row['server_type']}_${row['server_id']}';
        aliases[key] = row['alias'] as String;
      }
      _serverAliases = aliases;
    } catch (e) {
      debugPrint('加载别名失败: $e');
    }
  }
  
  String _getDisplayName(Map<String, dynamic> server) {
    final type = server['type'] ?? 'RCS';
    final id = server['ID']?.toString() ?? '';
    final key = '${type}_$id';
    
    if (_serverAliases.containsKey(key)) {
      return _serverAliases[key]!;
    }
    return server['HostName'] ?? server['Name'] ?? '未命名';
  }
  
  Future<void> _selectServer(int serverId, String serverType) async {
    setState(() => _selectedServerId = serverId);
    
    try {
      await _widgetService.setSelectedServer(serverId, type: serverType);
      if (mounted) {
        TDToast.showSuccess('小组件已更新', context: context);
      }
    } catch (e) {
      if (mounted) {
        TDToast.showFail('更新失败', context: context);
      }
    }
  }
  
  /// 强制同步小组件数据
  Future<void> _syncWidget() async {
    if (_isSyncing) return;
    
    setState(() => _isSyncing = true);
    
    try {
      await _widgetService.updateWidget();
      if (mounted) {
        TDToast.showSuccess('同步成功', context: context);
      }
    } catch (e) {
      if (mounted) {
        TDToast.showFail('同步失败: $e', context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }
  
  /// 请求添加小组件到桌面
  Future<void> _requestPinWidget() async {
    try {
      // 使用home_widget请求固定小组件 - Android必须使用完整类名
      await HomeWidget.requestPinWidget(
        name: 'ServerWidgetProvider',
        androidName: 'com.rainyun.rainyun_app.ServerWidgetProvider',
      );
      if (mounted) {
        TDToast.showSuccess('请在桌面确认添加', context: context);
      }
    } catch (e) {
      debugPrint('请求添加小组件失败: $e');
      if (mounted) {
        // 显示手动添加说明
        _showManualAddDialog();
      }
    }
  }
  
  void _showManualAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加小组件'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('请按以下步骤手动添加：'),
            SizedBox(height: 12),
            Text('1. 长按桌面空白处'),
            Text('2. 选择"小组件"或"Widgets"'),
            Text('3. 找到"RainyunApp"'),
            Text('4. 将小组件拖动到桌面'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('桌面小组件'),
        actions: [
          // 同步按钮
          IconButton(
            onPressed: _isSyncing ? null : _syncWidget,
            icon: _isSyncing 
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: '同步小组件',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _servers.isEmpty
              ? _buildEmptyState(theme)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 操作按钮区域
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _requestPinWidget,
                            icon: const Icon(Icons.add_to_home_screen, size: 20),
                            label: const Text('添加小组件到桌面'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isSyncing ? null : _syncWidget,
                          icon: _isSyncing 
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.sync, size: 20),
                          label: const Text('同步'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 说明信息
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '选择一个服务器，在桌面小组件中显示其状态信息',
                              style: TextStyle(color: Colors.blue[700], fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 服务器列表
                    Text(
                      '选择服务器',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ...List.generate(_servers.length, (index) {
                      final server = _servers[index];
                      return _buildServerItem(server, cardColor, theme);
                    }),
                    
                    const SizedBox(height: 24),
                    
                    // 使用说明
                    Text(
                      '使用说明',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStep('1', '点击上方"添加小组件"按钮'),
                          const SizedBox(height: 8),
                          _buildStep('2', '选择要显示的服务器'),
                          const SizedBox(height: 8),
                          _buildStep('3', '小组件会自动显示服务器状态'),
                          const SizedBox(height: 8),
                          _buildStep('4', '点击"同步"可手动刷新数据'),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 64, color: theme.hintColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('暂无服务器', style: TextStyle(color: theme.hintColor)),
          const SizedBox(height: 8),
          Text('请先购买或试用服务器', style: TextStyle(color: theme.hintColor, fontSize: 12)),
        ],
      ),
    );
  }
  
  Widget _buildServerItem(Map<String, dynamic> server, Color cardColor, ThemeData theme) {
    final id = server['ID'] as int? ?? 0;
    final name = _getDisplayName(server);
    final status = server['Status'] ?? 'unknown';
    final ip = server['MainIPv4'] ?? '';
    final serverType = server['type'] ?? 'RCS';
    final isSelected = _selectedServerId == id;
    
    // 配置信息
    final plan = server['Plan'] as Map<String, dynamic>? ?? {};
    final cpu = plan['cpu'] ?? 0;
    final memory = plan['memory'] ?? 0;
    final specs = '${cpu}核 ${(memory / 1024).toStringAsFixed(0)}G';
    
    // 状态
    final statusColor = status == 'running' ? Colors.green : Colors.red;
    final statusText = status == 'running' ? '运行中' : '已停止';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
            ? Border.all(color: theme.primaryColor, width: 2)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isSelected ? theme.primaryColor : Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.cloud,
            color: isSelected ? theme.primaryColor : Colors.blue,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontSize: 11),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '$ip · $specs',
          style: TextStyle(color: theme.hintColor, fontSize: 12),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.primaryColor)
            : const Icon(Icons.circle_outlined, color: Colors.grey),
        onTap: () => _selectServer(id, serverType),
      ),
    );
  }
  
  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
