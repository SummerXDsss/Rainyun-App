import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/rainyun_api_service.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = RainyunApiService();

  final List<Map<String, dynamic>> _categories = [
    {'name': '云服务器', 'key': 'rcs', 'icon': Icons.cloud_outlined},
    {'name': '游戏云', 'key': 'rgs', 'icon': Icons.sports_esports_outlined},
    {'name': '虚拟主机', 'key': 'rvh', 'icon': Icons.web_outlined},
    {'name': '对象存储', 'key': 'ros', 'icon': Icons.storage_outlined},
    {'name': 'CDN加速', 'key': 'rcdn', 'icon': Icons.speed_outlined},
  ];

  final Map<String, List<Map<String, dynamic>>> _packagesCache = {};
  final Map<String, bool> _loadingStates = {};
  final Map<String, String?> _errorStates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final category = _categories[_tabController.index]['key'] as String;
        if (!_packagesCache.containsKey(category)) {
          _loadPackages(category);
        }
      }
    });
    _loadPackages(_categories[0]['key'] as String);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages(String categoryKey) async {
    if (!_apiService.hasApiKey()) {
      setState(() {
        _errorStates[categoryKey] = '请先在"我的"页面绑定API Key';
      });
      return;
    }

    debugPrint('🔄 加载 $categoryKey 套餐列表...');
    setState(() {
      _loadingStates[categoryKey] = true;
      _errorStates[categoryKey] = null;
    });

    try {
      Map<String, dynamic> response;
      switch (categoryKey) {
        case 'rcs':
          response = await _apiService.getRcsPackages();
          break;
        case 'rgs':
          response = await _apiService.getRgsPackages();
          break;
        case 'rvh':
          response = await _apiService.getRvhPackages();
          break;
        case 'ros':
          response = await _apiService.getRosPackages();
          break;
        case 'rcdn':
          response = await _apiService.getRcdnPackages();
          break;
        default:
          throw Exception('未知的产品类型');
      }

      debugPrint('✅ $categoryKey 套餐数据: ${response['Code']}');

      if (response['Code'] == 200 && response['Data'] != null) {
        final data = response['Data'];
        List<Map<String, dynamic>> packages = [];

        if (data is List) {
          packages = data.cast<Map<String, dynamic>>();
        } else if (data is Map) {
          if (data.containsKey('packages')) {
            packages = (data['packages'] as List).cast<Map<String, dynamic>>();
          } else {
            packages = [data as Map<String, dynamic>];
          }
        }

        setState(() {
          _packagesCache[categoryKey] = packages;
          _loadingStates[categoryKey] = false;
        });
      } else {
        throw Exception(response['Message'] ?? '获取套餐列表失败');
      }
    } catch (e) {
      debugPrint('❌ 加载 $categoryKey 套餐失败: $e');
      setState(() {
        _errorStates[categoryKey] = e.toString();
        _loadingStates[categoryKey] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[700],
                dividerColor: Colors.transparent,
                tabs: _categories.map((cat) {
                  return Tab(
                    child: Row(
                      children: [
                        Icon(cat['icon'] as IconData, size: 18),
                        const SizedBox(width: 6),
                        Text(cat['name'] as String),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  return _buildProductList(category['key'] as String, category['name'] as String);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(String categoryKey, String categoryName) {
    final isLoading = _loadingStates[categoryKey] ?? false;
    final error = _errorStates[categoryKey];
    final packages = _packagesCache[categoryKey] ?? [];

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                error,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadPackages(categoryKey),
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (isLoading && packages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载套餐列表中...'),
          ],
        ),
      );
    }

    if (packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '暂无$categoryName套餐',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '请稍后再试或访问雨云官网查看',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse('https://rainyun.com');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('访问雨云官网'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPackages(categoryKey),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          return _buildPackageCard(package, categoryKey, categoryName);
        },
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package, String categoryKey, String categoryName) {
    final name = package['Name'] ?? package['name'] ?? '未命名套餐';
    final cpu = package['CPU'] ?? package['cpu'] ?? 0;
    final memory = package['Memory'] ?? package['memory'] ?? 0;
    final disk = package['Disk'] ?? package['disk'] ?? 0;
    final bandwidth = package['Bandwidth'] ?? package['bandwidth'] ?? 0;
    final price = package['Price'] ?? package['price'] ?? 0.0;
    final packageId = package['PackageID']?.toString() ?? package['package_id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
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
              ],
            ),
            const SizedBox(height: 12),
            if (cpu > 0 || memory > 0 || disk > 0)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (cpu > 0) _buildSpec(Icons.memory, '$cpu核'),
                  if (memory > 0) _buildSpec(Icons.sd_card, '${memory}G'),
                  if (disk > 0) _buildSpec(Icons.storage, '${disk}G'),
                  if (bandwidth > 0) _buildSpec(Icons.speed, '${bandwidth}M'),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (price > 0)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(text: '¥'),
                        TextSpan(
                          text: price.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const TextSpan(
                          text: '/月',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ElevatedButton(
                  onPressed: () => _showPurchaseDialog(name, categoryName, packageId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('立即购买'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpec(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
      ],
    );
  }

  void _showPurchaseDialog(String packageName, String categoryName, String packageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('购买产品'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('产品名称: $packageName'),
            const SizedBox(height: 8),
            Text('产品类型: $categoryName'),
            const SizedBox(height: 16),
            const Text(
              '购买功能需要跳转到雨云官网完成',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final url = Uri.parse('https://rainyun.com');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: const Text('前往官网'),
          ),
        ],
      ),
    );
  }
}
