import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/rainyun_api_service.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> with SingleTickerProviderStateMixin {
  final _apiService = RainyunApiService();
  late TabController _tabController;
  
  bool _isLoading = true;
  String? _error;
  int _userPoints = 0;
  List<Map<String, dynamic>> _tasks = [];
  Map<String, List<dynamic>> _products = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 获取用户积分
      final userResponse = await _apiService.getUserInfo();
      if (userResponse['code'] == 200) {
        final userData = userResponse['data'];
        _userPoints = userData['Points'] ?? 0;
      }

      // 获取积分任务列表
      final tasksResponse = await _apiService.get('/user/reward/tasks');
      if (tasksResponse['code'] == 200) {
        _tasks = List<Map<String, dynamic>>.from(tasksResponse['data'] ?? []);
      }

      // 获取可兑换产品列表
      final productsResponse = await _apiService.get('/user/reward/products');
      if (productsResponse['code'] == 200) {
        _products = Map<String, List<dynamic>>.from(
          (productsResponse['data'] as Map).map((k, v) => MapEntry(k.toString(), List<dynamic>.from(v)))
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _completeTask(String taskName) async {
    try {
      TDToast.showLoading(context: context, text: '领取中...');
      final response = await _apiService.post('/user/reward/tasks', data: {'task_name': taskName});
      TDToast.dismissLoading();
      
      if (response['code'] == 200) {
        TDToast.showSuccess('领取成功', context: context);
        _loadData(); // 刷新数据
      } else {
        TDToast.showFail(response['message'] ?? '领取失败', context: context);
      }
    } catch (e) {
      TDToast.dismissLoading();
      TDToast.showFail('领取失败: $e', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('积分中心'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadData,
            icon: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // 积分卡片
          _buildPointsCard(theme),
          
          // Tab栏
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? theme.cardTheme.color : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: theme.hintColor,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '积分任务'),
                Tab(text: '积分兑换'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 内容区
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorView(theme)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTasksList(theme, isDark),
                          _buildProductsList(theme, isDark),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '我的积分',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_userPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '完成任务赚积分',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '积分可兑换产品',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: theme.hintColor)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(ThemeData theme, bool isDark) {
    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: theme.hintColor),
            const SizedBox(height: 16),
            Text('暂无任务', style: TextStyle(color: theme.hintColor)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return _buildTaskCard(task, theme, isDark);
        },
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, ThemeData theme, bool isDark) {
    final name = task['Name'] ?? '';
    final detail = task['Detail'] ?? '';
    final points = task['Points'] ?? 0;
    final status = task['Status'] ?? 0;
    // Status: 0=未完成, 1=可领取, 2=已完成

    Color statusColor;
    String statusText;
    bool canClaim = false;

    switch (status) {
      case 0:
        statusColor = Colors.grey;
        statusText = '未完成';
        break;
      case 1:
        statusColor = Colors.green;
        statusText = '可领取';
        canClaim = true;
        break;
      case 2:
        statusColor = Colors.blue;
        statusText = '已完成';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '未知';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: canClaim ? Border.all(color: Colors.green.withOpacity(0.5), width: 1.5) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.task_alt, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+$points 积分',
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (canClaim)
                      ElevatedButton(
                        onPressed: () => _completeTask(name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('领取', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ThemeData theme, bool isDark) {
    // 检查是否有可兑换产品
    bool hasProducts = false;
    for (var list in _products.values) {
      if (list.isNotEmpty) {
        hasProducts = true;
        break;
      }
    }

    if (!hasProducts) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.redeem, size: 48, color: Colors.orange),
              ),
              const SizedBox(height: 24),
              const Text(
                '积分商城',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '暂无可兑换的产品\n请关注雨云官网了解最新活动',
                style: TextStyle(color: theme.hintColor, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 显示产品列表
    List<Widget> productWidgets = [];
    _products.forEach((category, items) {
      if (items.isNotEmpty) {
        productWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _getCategoryName(category),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
        for (var item in items) {
          productWidgets.add(_buildProductCard(item, category, theme, isDark));
        }
      }
    });

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        children: productWidgets,
      ),
    );
  }

  String _getCategoryName(String key) {
    switch (key) {
      case 'rcs': return '云服务器';
      case 'rgs': return '游戏云';
      case 'rvh': return '虚拟主机';
      case 'ros': return '对象存储';
      case 'rbm': return '裸金属';
      default: return key.toUpperCase();
    }
  }

  Widget _buildProductCard(dynamic product, String category, ThemeData theme, bool isDark) {
    final name = product['Name'] ?? '未命名产品';
    final points = product['Points'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.redeem, color: theme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$points 积分',
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              TDToast.showText('请前往官网兑换', context: context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: const Text('兑换', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
