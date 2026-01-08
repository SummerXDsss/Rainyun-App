import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/rainyun_api_service.dart';

class RgsPurchaseScreen extends StatefulWidget {
  final Map<String, dynamic> plan;
  
  const RgsPurchaseScreen({super.key, required this.plan});

  @override
  State<RgsPurchaseScreen> createState() => _RgsPurchaseScreenState();
}

class _RgsPurchaseScreenState extends State<RgsPurchaseScreen> {
  final _apiService = RainyunApiService();
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _coupons = [];
  int? _selectedCouponId;
  int _duration = 1; // 购买时长（月）
  
  // 从套餐获取的信息
  late int _planId;
  late double _basePrice;

  @override
  void initState() {
    super.initState();
    _planId = widget.plan['id'] ?? 0;
    _basePrice = (widget.plan['price'] ?? 0).toDouble();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    try {
      final response = await _apiService.get('/user/coupons/');
      if (response['code'] == 200) {
        final data = response['data'] as List? ?? [];
        setState(() {
          // 筛选可用于创建且未过期的优惠券
          _coupons = data.where((c) {
            final scenes = c['usable_scenes']?.toString() ?? '';
            final expDate = c['exp_date'] ?? 0;
            final useDate = c['use_date']; // 已使用的优惠券
            final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            
            // 已使用的优惠券不显示
            if (useDate != null && useDate > 0) return false;
            
            // expDate = 0 表示永久有效，expDate > now 表示未过期
            return scenes.contains('create') && (expDate == 0 || expDate > now);
          }).map((c) => Map<String, dynamic>.from(c)).toList();
        });
      }
    } catch (e) {
      debugPrint('加载优惠券失败: $e');
    }
  }

  // 计算总价
  double get _totalPrice {
    double total = _basePrice * _duration;
    
    // 应用优惠券
    if (_selectedCouponId != null) {
      final coupon = _coupons.firstWhere(
        (c) => c['id'] == _selectedCouponId,
        orElse: () => {},
      );
      if (coupon.isNotEmpty) {
        final type = coupon['type'];
        final value = (coupon['value'] ?? 0).toDouble();
        if (type == 'discount') {
          total = total * value; // 折扣
        } else if (type == 'reduce') {
          total = total - value; // 减免
        }
      }
    }
    
    return total < 0 ? 0 : total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final planName = widget.plan['chinese'] ?? widget.plan['plan_name'] ?? '未命名套餐';

    return Scaffold(
      appBar: AppBar(
        title: Text('购买 $planName'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 套餐信息卡片
            _buildInfoCard(cardColor, theme, planName),
            const SizedBox(height: 16),
            
            // 购买时长选择
            _buildDurationSelector(cardColor, theme),
            const SizedBox(height: 16),
            
            // 优惠券选择
            _buildCouponSelector(cardColor, theme),
            const SizedBox(height: 16),
            
            // 价格详情
            _buildPriceDetails(cardColor, theme),
            const SizedBox(height: 24),
            
            // 购买按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => _purchase(true),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('1 元试用'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _purchase(false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text('立即购买 ¥${_totalPrice.toStringAsFixed(2)}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Color cardColor, ThemeData theme, String planName) {
    final region = widget.plan['region'] ?? '';
    final cpu = widget.plan['cpu'] ?? 0;
    final memory = widget.plan['memory'] ?? 0;
    final netOut = widget.plan['net_out'] ?? 0;
    final stock = widget.plan['available_stock'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports_esports, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(planName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(_getRegionName(region), style: TextStyle(color: theme.hintColor, fontSize: 13)),
                  ],
                ),
              ),
              Text('¥$_basePrice/月', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.hintColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpec('CPU', '$cpu核'),
                _buildSpec('内存', '${(memory / 1024).toStringAsFixed(0)}G'),
                _buildSpec('带宽', '${netOut}M'),
                _buildSpec('库存', '$stock'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpec(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDurationSelector(Color cardColor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('购买时长', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [1, 3, 6, 12].map((d) {
              final isSelected = _duration == d;
              return GestureDetector(
                onTap: () => setState(() => _duration = d),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor : theme.hintColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$d个月',
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSelector(Color cardColor, ThemeData theme) {
    return Container(
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
              const Text('优惠券', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('${_coupons.length}张可用', style: TextStyle(color: theme.hintColor, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          if (_coupons.isEmpty)
            Text('暂无可用优惠券', style: TextStyle(color: theme.hintColor))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 不使用优惠券选项
                GestureDetector(
                  onTap: () => setState(() => _selectedCouponId = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedCouponId == null ? theme.primaryColor : theme.hintColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '不使用',
                      style: TextStyle(
                        color: _selectedCouponId == null ? Colors.white : theme.textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                ..._coupons.map((coupon) {
                  final id = coupon['id'];
                  final name = coupon['friendly_name'] ?? '优惠券';
                  final isSelected = _selectedCouponId == id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCouponId = id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : theme.hintColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(Color cardColor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPriceRow('套餐月费', '¥${_basePrice.toStringAsFixed(2)}', theme),
          _buildPriceRow('购买时长', '$_duration 个月', theme),
          _buildPriceRow('小计', '¥${(_basePrice * _duration).toStringAsFixed(2)}', theme),
          if (_selectedCouponId != null) ...[
            const Divider(),
            _buildPriceRow('优惠券抵扣', '-¥${((_basePrice * _duration) - _totalPrice).toStringAsFixed(2)}', theme, isDiscount: true),
          ],
          const Divider(),
          _buildPriceRow('续费价格', '¥${_basePrice.toStringAsFixed(2)}/月', theme),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('应付金额', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '¥${_totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, ThemeData theme, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.hintColor)),
          Text(value, style: TextStyle(color: isDiscount ? Colors.green : null)),
        ],
      ),
    );
  }

  String _getRegionName(String region) {
    const regionMap = {
      'us-la1': '🇺🇸 美国洛杉矶',
      'cn-sq1': '🇨🇳 宿迁',
      'cn-sy1': '🇨🇳 沈阳',
      'cn-cq1': '🇨🇳 重庆',
      'cn-xy1': '🇨🇳 咸阳',
      'hk-hk1': '🇭🇰 香港',
      'cn-hk1': '🇭🇰 香港',
      'cn-hk2': '🇭🇰 香港',
      'jp-tk1': '🇯🇵 日本东京',
      'mainland_china': '🇨🇳 中国大陆',
    };
    return regionMap[region] ?? region;
  }

  Future<void> _purchase(bool isTrial) async {
    setState(() => _isLoading = true);
    
    try {
      final data = {
        'plan_id': _planId,
        'duration': _duration,
        'try': isTrial,
      };
      
      if (_selectedCouponId != null && !isTrial) {
        data['with_coupon_id'] = _selectedCouponId!;
      }
      
      final response = await _apiService.post('/product/rgs/', data: data);
      
      setState(() => _isLoading = false);
      
      if (response['code'] == 200) {
        if (mounted) {
          TDToast.showSuccess(isTrial ? '试用成功' : '购买成功', context: context);
          Navigator.pop(context, true);
        }
      } else {
        final msg = response['message'] ?? '操作失败';
        if (mounted) {
          TDToast.showFail(msg, context: context);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        TDToast.showFail('请求失败: $e', context: context);
      }
    }
  }
}
