import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rainyun_api_service.dart';
import 'package:intl/intl.dart';

/// 桌面小组件服务 - 管理小组件数据更新
class WidgetService {
  // 必须使用完整的类名（包含包名）
  static const String _widgetName = 'ServerWidgetProvider';
  static const String _androidWidgetName = 'com.rainyun.rainyun_app.ServerWidgetProvider';
  static const String _selectedServerKey = 'widget_selected_server_id';
  static const String _selectedServerTypeKey = 'widget_selected_server_type';
  static const String _cardStyleKey = 'card_style'; // 个性化设置中的卡片样式key
  
  final RainyunApiService _apiService = RainyunApiService();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// 初始化小组件
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.com.rainyun.app');
  }
  
  /// 获取当前选中的服务器ID
  Future<int?> getSelectedServerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_selectedServerKey);
  }
  
  /// 获取当前选中的服务器类型
  Future<String?> getSelectedServerType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedServerTypeKey);
  }
  
  /// 获取当前卡片样式设置
  Future<String> getCardStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cardStyleKey) ?? 'list';
  }
  
  /// 设置要显示的服务器
  Future<void> setSelectedServer(int serverId, {String type = 'RCS'}) async {
    debugPrint('📱 [Widget] setSelectedServer - serverId: $serverId, type: $type');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedServerKey, serverId);
    await prefs.setString(_selectedServerTypeKey, type.toLowerCase());
    debugPrint('📱 [Widget] 已保存到SharedPreferences');
    // 立即更新小组件
    await updateWidget();
  }
  
  /// 更新小组件数据
  Future<void> updateWidget() async {
    try {
      final serverId = await getSelectedServerId();
      final serverType = await getSelectedServerType() ?? 'rcs';
      
      debugPrint('📱 [Widget] updateWidget - serverId: $serverId, serverType: $serverType');
      
      if (serverId == null) {
        debugPrint('📱 [Widget] 没有选中服务器');
        final cardStyle = await getCardStyle();
        // 没有选中服务器，显示默认状态
        await _setWidgetData(
          name: '未选择服务器',
          status: '未知',
          ip: '请在设置中选择',
          region: '',
          cpuUsage: 0,
          memUsage: 0,
          specs: '',
          expire: '',
          cardStyle: cardStyle,
        );
        return;
      }
      
      // 获取服务器详情
      final apiPath = '/product/$serverType/$serverId';
      debugPrint('📱 [Widget] 调用API: $apiPath');
      final response = await _apiService.get(apiPath);
      debugPrint('📱 [Widget] API响应: $response');
      
      final code = response['code'] ?? response['Code'];
      if (code == 200) {
        // API返回格式: {data: {Data: {...}}} 需要两层解析
        final dataWrapper = response['data'] ?? response['Data'];
        final server = dataWrapper is Map ? (dataWrapper['Data'] ?? dataWrapper) : dataWrapper;
        debugPrint('📱 [Widget] 服务器数据: $server');
        if (server != null && server is Map<String, dynamic>) {
          await _updateWidgetFromServer(server);
        } else {
          debugPrint('📱 [Widget] 服务器数据为空或格式错误');
        }
      } else {
        debugPrint('📱 [Widget] API返回错误码: $code');
      }
    } catch (e, stack) {
      debugPrint('📱 [Widget] 更新小组件失败: $e');
      debugPrint('📱 [Widget] Stack: $stack');
    }
  }
  
  /// 获取服务器别名
  Future<String?> _getServerAlias(int serverId, String serverType) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      
      final response = await _supabase
          .from('server_aliases')
          .select('alias')
          .eq('user_id', user.id)
          .eq('server_type', serverType.toUpperCase())
          .eq('server_id', serverId)
          .maybeSingle();
      
      return response?['alias'] as String?;
    } catch (e) {
      debugPrint('获取别名失败: $e');
      return null;
    }
  }
  
  /// 从服务器数据更新小组件
  Future<void> _updateWidgetFromServer(Map<String, dynamic> server) async {
    debugPrint('📱 [Widget] _updateWidgetFromServer 开始解析');
    debugPrint('📱 [Widget] server keys: ${server.keys.toList()}');
    
    final serverId = server['ID'] as int? ?? 0;
    final serverType = await getSelectedServerType() ?? 'rcs';
    
    // 尝试获取别名
    final alias = await _getServerAlias(serverId, serverType);
    final defaultName = server['HostName'] ?? server['Name'] ?? '未命名';
    final name = alias ?? defaultName;
    
    final status = server['Status'] ?? 'unknown';
    final ip = server['MainIPv4'] ?? '0.0.0.0';
    
    debugPrint('📱 [Widget] 解析结果: name=$name, status=$status, ip=$ip');
    
    // 地区信息
    final node = server['Node'] as Map<String, dynamic>? ?? {};
    final region = _getRegionWithFlag(node['Region'] ?? '');
    
    // 配置信息
    final plan = server['Plan'] as Map<String, dynamic>? ?? {};
    final cpu = plan['cpu'] ?? 0;
    final memory = plan['memory'] ?? 0;
    final specs = '${cpu}核 ${(memory / 1024).toStringAsFixed(0)}G';
    
    // 到期时间
    final expDate = server['ExpDate'] as int? ?? 0;
    final expire = expDate > 0 
        ? '到期: ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(expDate * 1000))}'
        : '';
    
    // CPU/内存使用率
    final usageData = server['UsageData'] as Map<String, dynamic>? ?? {};
    final cpuUsage = (usageData['CPU'] as num?)?.toInt() ?? 0;
    final freeMem = (usageData['FreeMem'] as num?)?.toInt() ?? 0;
    final totalMemBytes = (memory as num) * 1024 * 1024;
    final memUsage = totalMemBytes > 0 
        ? ((totalMemBytes - freeMem) / totalMemBytes * 100).clamp(0, 100).toInt() 
        : 0;
    
    // 状态文本
    final statusText = switch (status) {
      'running' => '运行中',
      'stopped' => '已停止',
      _ => '未知',
    };
    
    // 获取卡片样式
    final cardStyle = await getCardStyle();
    
    await _setWidgetData(
      name: name,
      status: statusText,
      ip: ip,
      region: region,
      cpuUsage: cpuUsage,
      memUsage: memUsage,
      specs: specs,
      expire: expire,
      cardStyle: cardStyle,
    );
  }
  
  /// 设置小组件数据
  Future<void> _setWidgetData({
    required String name,
    required String status,
    required String ip,
    required String region,
    required int cpuUsage,
    required int memUsage,
    required String specs,
    required String expire,
    required String cardStyle,
  }) async {
    debugPrint('📱 [Widget] 保存小组件数据:');
    debugPrint('  - server_name: $name');
    debugPrint('  - server_status: $status');
    debugPrint('  - server_ip: $ip');
    debugPrint('  - server_region: $region');
    debugPrint('  - cpu_usage: $cpuUsage');
    debugPrint('  - mem_usage: $memUsage');
    debugPrint('  - server_specs: $specs');
    debugPrint('  - server_expire: $expire');
    debugPrint('  - card_style: $cardStyle');
    
    try {
      await HomeWidget.saveWidgetData<String>('server_name', name);
      await HomeWidget.saveWidgetData<String>('server_status', status);
      await HomeWidget.saveWidgetData<String>('server_ip', ip);
      await HomeWidget.saveWidgetData<String>('server_region', region);
      await HomeWidget.saveWidgetData<int>('cpu_usage', cpuUsage);
      await HomeWidget.saveWidgetData<int>('mem_usage', memUsage);
      await HomeWidget.saveWidgetData<String>('server_specs', specs);
      await HomeWidget.saveWidgetData<String>('server_expire', expire);
      await HomeWidget.saveWidgetData<String>('card_style', cardStyle);
      
      debugPrint('📱 [Widget] 数据保存成功，触发更新...');
      
      // 触发小组件更新 - Android必须使用完整类名
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _androidWidgetName,
      );
      
      debugPrint('📱 [Widget] 小组件更新完成');
    } catch (e, stack) {
      debugPrint('📱 [Widget] 保存数据失败: $e');
      debugPrint('📱 [Widget] Stack: $stack');
    }
  }
  
  /// 获取带国旗的地区名称
  String _getRegionWithFlag(String region) {
    if (region.isEmpty) return '';
    
    const regionMap = {
      'cn-sq1': '🇨🇳 宿迁',
      'cn-sy1': '🇨🇳 沈阳',
      'cn-cq1': '🇨🇳 重庆',
      'cn-xy1': '🇨🇳 咸阳',
      'cn-bj1': '🇨🇳 北京',
      'cn-sh1': '🇨🇳 上海',
      'cn-gz1': '🇨🇳 广州',
      'cn-hk1': '🇭🇰 香港',
      'cn-hk2': '🇭🇰 香港',
      'us-la1': '🇺🇸 洛杉矶',
      'us-sj1': '🇺🇸 圣何塞',
      'jp-tk1': '🇯🇵 东京',
      'sg-sg1': '🇸🇬 新加坡',
    };
    
    if (regionMap.containsKey(region)) {
      return regionMap[region]!;
    }
    
    // 根据前缀推断
    if (region.startsWith('cn-')) return '🇨🇳 中国';
    if (region.startsWith('us-')) return '🇺🇸 美国';
    if (region.startsWith('hk-')) return '🇭🇰 香港';
    if (region.startsWith('jp-')) return '🇯🇵 日本';
    if (region.startsWith('sg-')) return '🇸🇬 新加坡';
    
    return region;
  }
}
