import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/product_card.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = [
    '云服务器',
    '游戏云',
    '裸金属',
    '虚拟主机',
    '云应用',
    '对象存储',
    'CDN加速',
    '域名注册',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '产品中心',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                splashFactory: NoSplash.splashFactory,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                tabs: _categories.map((cat) => Tab(text: cat)).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const ClampingScrollPhysics(),
                children: _categories.map((category) {
                  return _buildProductList(category);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(String category) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const ClampingScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return ProductCard(
          name: '$category 套餐 ${index + 1}',
          type: category,
          specs: '2核4G 50G SSD',
          price: 49.99 + (index * 20),
          region: index % 2 == 0 ? '香港' : '美国',
          stock: 10 - index,
          hasPublicIp: index % 2 == 0,
          onOrder: () {
            _showOrderDialog(category, index);
          },
        );
      },
    );
  }

  void _showOrderDialog(String category, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认下单'),
        content: Text('确认购买 $category 套餐 ${index + 1} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('下单成功'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
