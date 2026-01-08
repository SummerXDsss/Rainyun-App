import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/rainyun_api_service.dart';
import 'rcs_purchase_screen.dart';
import 'rgs_purchase_screen.dart';

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
    {'key': 'rcs', 'name': '云服务器', 'icon': Icons.cloud_outlined, 'color': Colors.blue},
    {'key': 'rgs', 'name': '游戏云', 'icon': Icons.sports_esports_outlined, 'color': Colors.purple},
    {'key': 'rvh', 'name': '虚拟主机', 'icon': Icons.web_outlined, 'color': Colors.green},
    {'key': 'ros', 'name': '对象存储', 'icon': Icons.storage_outlined, 'color': Colors.orange},
    {'key': 'rcdn', 'name': 'CDN加速', 'icon': Icons.speed_outlined, 'color': Colors.red},
  ];

  final Map<String, List<dynamic>> _plansCache = {};
  final Map<String, bool> _loadingStates = {};
  final Map<String, String?> _errorStates = {};
  bool _hideOutOfStock = true; // 默认隐藏缺货项

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
    _loadPlans(_productTypes[0]['key'] as String);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans(String productKey) async {
    if (!_apiService.hasApiKey()) {
      setState(() => _errorStates[productKey] = '请先在"我的"页面绑定API Key');
      return;
    }

    setState(() {
      _loadingStates[productKey] = true;
      _errorStates[productKey] = null;
    });

    try {
      final response = await _apiService.get('/product/$productKey/plans');
      if (response['code'] == 200) {
        setState(() {
          _plansCache[productKey] = List<dynamic>.from(response['data'] ?? []);
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('产品中心', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _hideOutOfStock = !_hideOutOfStock),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _hideOutOfStock ? Icons.check_box : Icons.check_box_outline_blank,
                          size: 20,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '隐藏缺货',
                          style: TextStyle(fontSize: 13, color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab栏
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? theme.cardTheme.color : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: theme.hintColor,
                dividerColor: Colors.transparent,
                tabs: _productTypes.map((t) => Tab(
                  child: Row(
                    children: [
                      Icon(t['icon'] as IconData, size: 16),
                      const SizedBox(width: 4),
                      Text(t['name'] as String),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // 内容区
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _productTypes.map((t) => _buildPlansList(t['key'] as String, t, theme, isDark)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList(String key, Map<String, dynamic> productType, ThemeData theme, bool isDark) {
    final isLoading = _loadingStates[key] ?? false;
    final error = _errorStates[key];
    final plans = _plansCache[key] ?? [];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(error, style: TextStyle(color: theme.hintColor), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => _loadPlans(key), child: const Text('重试')),
          ],
        ),
      );
    }

    if (isLoading && plans.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(productType['icon'] as IconData, size: 48, color: theme.hintColor),
            const SizedBox(height: 12),
            Text('暂无${productType['name']}套餐', style: TextStyle(color: theme.hintColor)),
          ],
        ),
      );
    }

    // 只显示在售的套餐，按地区分组
    final sellingPlans = plans.where((p) => p['is_selling'] == true).toList();
    
    // 按地区分组
    final Map<String, List<dynamic>> plansByRegion = {};
    for (var plan in sellingPlans) {
      final region = plan['region']?.toString() ?? 'unknown';
      plansByRegion.putIfAbsent(region, () => []).add(plan);
    }

    // 获取地区列表
    final regions = plansByRegion.keys.toList();

    return _RegionPlansView(
      regions: regions,
      plansByRegion: plansByRegion,
      productKey: key,
      productType: productType,
      theme: theme,
      cardColor: cardColor,
      onRefresh: () => _loadPlans(key),
      getRegionName: _getRegionName,
      navigateToPurchase: _navigateToPurchase,
      hideOutOfStock: _hideOutOfStock,
    );
  }

  Widget _buildPlanCard(dynamic plan, String productKey, Map<String, dynamic> productType, ThemeData theme, Color cardColor) {
    final name = plan['chinese'] ?? plan['plan_name'] ?? '未命名套餐';
    final price = plan['price'] ?? 0;
    final region = plan['region'] ?? '';
    final stock = plan['available_stock'] ?? 0;
    final color = productType['color'] as Color;

    // 根据产品类型解析配置信息
    String specs = '';
    if (productKey == 'rcs' || productKey == 'rgs') {
      final cpu = plan['cpu'] ?? 0;
      final memory = plan['memory'] ?? 0;
      final netOut = plan['net_out'] ?? 0;
      specs = '${cpu}核 · ${(memory / 1024).toStringAsFixed(0)}G内存 · ${netOut}M带宽';
    } else if (productKey == 'rvh') {
      final disk = plan['disk'] ?? 0;
      final epdb = plan['epdb'] ?? 0;
      specs = '${disk}M空间 · ${epdb}M数据库';
    } else if (productKey == 'ros') {
      final storage = plan['storage_size'] ?? 0;
      final bandwidth = plan['bandwidth'] ?? 0;
      specs = '${storage}G存储 · ${bandwidth}G流量/月';
    } else if (productKey == 'rcdn') {
      final traffic = plan['traffic_in_gb'] ?? 0;
      final domainLimit = plan['domain_limit'] ?? 0;
      specs = '${traffic}G流量 · $domainLimit个域名';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(productType['icon'] as IconData, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getRegionName(region)} $name',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('¥$price/月', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(stock > 0 ? '库存: $stock' : '缺货', 
                      style: TextStyle(color: stock > 0 ? theme.hintColor : Colors.red, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // 配置信息
                if (specs.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.hintColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(specs, style: TextStyle(color: theme.hintColor, fontSize: 12)),
                    ),
                  ),
                // 地区标签
                if (region.isNotEmpty) ...[
                  if (specs.isNotEmpty) const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(_getRegionName(region), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: stock > 0 ? () => _navigateToPurchase(plan, productKey, true) : null,
                    child: const Text('试用'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: stock > 0 ? () => _navigateToPurchase(plan, productKey, false) : null,
                    child: const Text('购买'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRegionName(String region) {
    const regionMap = {
      // 美国
      'us-la1': '🇺🇸 美国洛杉矶',
      'us-sj1': '🇺🇸 美国圣何塞',
      // 中国大陆
      'cn-sq1': '🇨🇳 宿迁',
      'cn-sy1': '🇨🇳 沈阳',
      'cn-cq1': '🇨🇳 重庆',
      'cn-xy1': '🇨🇳 咸阳',
      'cn-bj1': '🇨🇳 北京',
      'cn-sh1': '🇨🇳 上海',
      'cn-gz1': '🇨🇳 广州',
      'cn-sz1': '🇨🇳 深圳',
      'cn-cd1': '🇨🇳 成都',
      'cn-wh1': '🇨🇳 武汉',
      'cn-nb1': '🇨🇳 宁波',
      'mainland_china': '🇨🇳 中国大陆',
      // 香港
      'hk-hk1': '🇭🇰 香港',
      'cn-hk1': '🇭🇰 香港',
      'cn-hk2': '🇭🇰 香港',
      // 台湾
      'tw-tp1': '🇹🇼 台湾',
      // 日本
      'jp-tk1': '🇯🇵 日本东京',
      'jp-os1': '🇯🇵 日本大阪',
      // 韩国
      'kr-se1': '🇰🇷 韩国首尔',
      // 新加坡
      'sg-sg1': '🇸🇬 新加坡',
      // 德国
      'de-fr1': '🇩🇪 德国法兰克福',
    };
    return regionMap[region] ?? region;
  }

  void _navigateToPurchase(dynamic plan, String productKey, bool isTrial) {
    if (productKey == 'rcs') {
      // RCS使用专门的购买页面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RcsPurchaseScreen(plan: Map<String, dynamic>.from(plan)),
        ),
      );
    } else if (productKey == 'rgs') {
      // 游戏云使用专门的购买页面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RgsPurchaseScreen(plan: Map<String, dynamic>.from(plan)),
        ),
      );
    } else {
      // 其他产品暂时显示提示
      TDToast.showText('${isTrial ? "试用" : "购买"}功能开发中', context: context);
    }
  }
}

// 地区分类套餐视图
class _RegionPlansView extends StatefulWidget {
  final List<String> regions;
  final Map<String, List<dynamic>> plansByRegion;
  final String productKey;
  final Map<String, dynamic> productType;
  final ThemeData theme;
  final Color cardColor;
  final Future<void> Function() onRefresh;
  final String Function(String) getRegionName;
  final void Function(dynamic, String, bool) navigateToPurchase;
  final bool hideOutOfStock;

  const _RegionPlansView({
    required this.regions,
    required this.plansByRegion,
    required this.productKey,
    required this.productType,
    required this.theme,
    required this.cardColor,
    required this.onRefresh,
    required this.getRegionName,
    required this.navigateToPurchase,
    required this.hideOutOfStock,
  });

  @override
  State<_RegionPlansView> createState() => _RegionPlansViewState();
}

class _RegionPlansViewState extends State<_RegionPlansView> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _regionKeys = {};
  String? _selectedRegion;
  final Map<String, double> _regionOffsets = {};

  @override
  void initState() {
    super.initState();
    for (var region in widget.regions) {
      _regionKeys[region] = GlobalKey();
    }
    // 初始选中第一个地区
    if (widget.regions.isNotEmpty) {
      _selectedRegion = widget.regions.first;
    }
    // 延迟计算偏移量
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateOffsets());
  }

  void _calculateOffsets() {
    double offset = 0;
    for (var region in widget.regions) {
      _regionOffsets[region] = offset;
      final plans = widget.plansByRegion[region] ?? [];
      // 估算每个地区的高度：标题(60) + 套餐卡片数量 * 卡片高度(约180)
      offset += 60 + plans.length * 180;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToRegion(String region) {
    setState(() => _selectedRegion = region);
    
    // 使用预计算的偏移量滚动
    final offset = _regionOffsets[region];
    if (offset != null && _scrollController.hasClients) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 地区筛选标签
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.regions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final region = widget.regions[index];
              final allPlans = widget.plansByRegion[region] ?? [];
              final planCount = widget.hideOutOfStock 
                  ? allPlans.where((p) => (p['available_stock'] ?? 0) > 0).length
                  : allPlans.length;
              final isSelected = _selectedRegion == region;
              
              // 如果过滤后没有套餐，不显示该地区标签
              if (planCount == 0 && widget.hideOutOfStock) return const SizedBox.shrink();
              
              return GestureDetector(
                onTap: () => _scrollToRegion(region),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? widget.theme.primaryColor 
                        : widget.theme.hintColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.getRegionName(region),
                        style: TextStyle(
                          color: isSelected ? Colors.white : widget.theme.textTheme.bodyMedium?.color,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$planCount',
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : widget.theme.hintColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // 套餐列表
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.regions.length,
              itemBuilder: (context, index) {
                final region = widget.regions[index];
                final allPlans = widget.plansByRegion[region] ?? [];
                // 根据设置过滤缺货项
                final plans = widget.hideOutOfStock 
                    ? allPlans.where((p) => (p['available_stock'] ?? 0) > 0).toList()
                    : allPlans;
                
                // 如果过滤后没有套餐，不显示该地区
                if (plans.isEmpty) return const SizedBox.shrink();
                
                return Column(
                  key: _regionKeys[region],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 地区标题
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            widget.getRegionName(region),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${plans.length}个套餐',
                            style: TextStyle(fontSize: 12, color: widget.theme.hintColor),
                          ),
                        ],
                      ),
                    ),
                    // 套餐卡片
                    ...plans.map((plan) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildPlanCard(plan),
                    )),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(dynamic plan) {
    final name = plan['chinese'] ?? plan['plan_name'] ?? '未命名套餐';
    final price = plan['price'] ?? 0;
    final stock = plan['available_stock'] ?? 0;
    final color = widget.productType['color'] as Color;

    // 根据产品类型解析配置信息
    String specs = '';
    if (widget.productKey == 'rcs' || widget.productKey == 'rgs') {
      final cpu = plan['cpu'] ?? 0;
      final memory = plan['memory'] ?? 0;
      final netOut = plan['net_out'] ?? 0;
      specs = '${cpu}核 · ${(memory / 1024).toStringAsFixed(0)}G内存 · ${netOut}M带宽';
    } else if (widget.productKey == 'rvh') {
      final disk = plan['disk'] ?? 0;
      final epdb = plan['epdb'] ?? 0;
      specs = '${disk}M空间 · ${epdb}M数据库';
    } else if (widget.productKey == 'ros') {
      final storage = plan['storage_size'] ?? 0;
      final bandwidth = plan['bandwidth'] ?? 0;
      specs = '${storage}G存储 · ${bandwidth}G流量/月';
    } else if (widget.productKey == 'rcdn') {
      final traffic = plan['traffic_in_gb'] ?? 0;
      final domainLimit = plan['domain_limit'] ?? 0;
      specs = '${traffic}G流量 · $domainLimit个域名';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.productType['icon'] as IconData, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('¥$price/月', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(stock > 0 ? '库存: $stock' : '缺货', 
                      style: TextStyle(color: stock > 0 ? widget.theme.hintColor : Colors.red, fontSize: 11)),
                  ],
                ),
              ],
            ),
            if (specs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.theme.hintColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(specs, style: TextStyle(color: widget.theme.hintColor, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: stock > 0 ? () => widget.navigateToPurchase(plan, widget.productKey, true) : null,
                    child: const Text('试用'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: stock > 0 ? () => widget.navigateToPurchase(plan, widget.productKey, false) : null,
                    child: const Text('购买'),
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
