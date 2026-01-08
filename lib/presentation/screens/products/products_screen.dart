import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/rainyun_api_service.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> with SingleTickerProviderStateMixin {
  final _apiService = RainyunApiService();
  late TabController _tabController;

  // 产品类型配置
  final List<Map<String, dynamic>> _productTypes = [
    {'key': 'rcs', 'name': '云服务器', 'icon': Icons.cloud_outlined},
    {'key': 'rgs', 'name': '游戏云', 'icon': Icons.sports_esports_outlined},
    {'key': 'rvh', 'name': '虚拟主机', 'icon': Icons.web_outlined},
    {'key': 'ros', 'name': '对象存储', 'icon': Icons.storage_outlined},
    {'key': 'rcdn', 'name': 'CDN加速', 'icon': Icons.speed_outlined},
  ];

  final Map<String, List<dynamic>> _plansCache = {};
  final Map<String, bool> _loadingStates = {};
  final Map<String, String?> _errorStates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _productTypes.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final key = _productTypes[_tabController.index]['key'] as String;
        if (!_plansCache.containsKey(key)) {
          _loadPlans(key);
        }
      }
    });
    // 加载第一个Tab的数据
    _loadPlans(_productTypes[0]['key'] as String);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans(String productKey) async {
    if (!_apiService.hasApiKey()) {
      setState(() {
        _errorStates[productKey] = '请先在"我的"页面绑定API Key';
      });
      return;
    }

    setState(() {
      _loadingStates[productKey] = true;
      _errorStates[productKey] = null;
    });

    try {
      final response = await _apiService.get('/product/$productKey/plans');
      final code = response['code'] ?? response['Code'];
      if (code == 200) {
        final data = response['data'] ?? response['Data'];
        setState(() {
          _plansCache[productKey] = List<dynamic>.from(data ?? []);
          _loadingStates[productKey] = false;
        });
      } else {
        throw Exception(response['message'] ?? '获取套餐列表失败');
      }
    } catch (e) {
      setState(() {
        _loadingStates[productKey] = false;
        _errorStates[productKey] = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

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
                    '产品中心',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _isLoading ? null : _loadProductStats,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh),
                      ),
                      IconButton(
                        onPressed: () async {
                          final url = Uri.parse('https://rainyun.com');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_browser),
                        tooltip: '访问雨云官网',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildContent(theme, cardColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, Color cardColor) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: theme.hintColor), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadProductStats,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载产品信息中...'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProductStats,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // 产品统计网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: _productTypes.length,
            itemBuilder: (context, index) {
              final product = _productTypes[index];
              return _buildProductCard(product, theme, cardColor);
            },
          ),
          const SizedBox(height: 24),
          
          // 购买新产品入口
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '购买新产品',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '前往雨云官网选购更多产品',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse('https://rainyun.com');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.primaryColor,
                  ),
                  child: const Text('立即购买'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ThemeData theme, Color cardColor) {
    final key = product['key'] as String;
    final name = product['name'] as String;
    final icon = product['icon'] as IconData;
    final color = product['color'] as Color;
    final url = product['url'] as String;

    // 从统计数据获取产品数量
    int count = 0;
    if (_productStats.containsKey(key)) {
      final stats = _productStats[key];
      if (stats is Map) {
        count = stats['TotalCount'] ?? stats['totalCount'] ?? 0;
      } else if (stats is int) {
        count = stats;
      }
    }

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count 个',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  count > 0 ? '已拥有' : '点击购买',
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
