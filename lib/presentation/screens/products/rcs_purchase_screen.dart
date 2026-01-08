import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/rainyun_api_service.dart';

class RcsPurchaseScreen extends StatefulWidget {
  final Map<String, dynamic> plan;
  
  const RcsPurchaseScreen({super.key, required this.plan});

  @override
  State<RcsPurchaseScreen> createState() => _RcsPurchaseScreenState();
}

class _RcsPurchaseScreenState extends State<RcsPurchaseScreen> {
  final _apiService = RainyunApiService();
  
  bool _isLoading = false;
  bool _isPriceLoading = true;
  List<Map<String, dynamic>> _coupons = [];
  int? _selectedCouponId;
  int _duration = 1; // 购买时长（月）
  double _diskSize = 30; // 硬盘大小（GB）
  bool _isTrial = false; // 是否试用
  bool _withEip = false; // 是否附加独立IP
  int _eipNum = 1; // IP数量（当_withEip为true时有效）
  
  // 从套餐获取的信息
  late int _planId;
  late double _basePrice;
  late double _diskPrice;
  late double _minDisk;
  late double _maxDisk;
  double _eipPrice = 10.0; // 独立IP价格（每个/月），从API获取

  @override
  void initState() {
    super.initState();
    _planId = widget.plan['id'] ?? 0;
    _basePrice = (widget.plan['price'] ?? 0).toDouble();
    
    // 获取硬盘价格（从disk_price字段）
    final diskPriceMap = widget.plan['disk_price'];
    if (diskPriceMap is Map) {
      _diskPrice = (diskPriceMap.values.first ?? 0.2).toDouble();
    } else {
      _diskPrice = 0.2;
    }
    
    // 硬盘范围默认30-100
    _minDisk = 30;
    _maxDisk = 100;
    _diskSize = _minDisk;
    
    _loadCoupons();
    _loadPricing();
  }
  
  Future<void> _loadPricing() async {
    try {
      final response = await _apiService.get('/product/rcs/price');
      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'];
        // 尝试获取独立IP价格
        if (data['eip_price'] != null) {
          setState(() {
            _eipPrice = (data['eip_price'] as num?)?.toDouble() ?? 10.0;
            _isPriceLoading = false;
          });
        } else {
          setState(() => _isPriceLoading = false);
        }
      } else {
        setState(() => _isPriceLoading = false);
      }
    } catch (e) {
      debugPrint('加载价格失败: $e');
      setState(() => _isPriceLoading = false);
    }
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
    // 基础价格 + 额外硬盘价格
    double extraDisk = _diskSize - _minDisk;
    double diskCost = extraDisk * _diskPrice;
    double monthlyPrice = _basePrice + diskCost;
    
    // 独立IP价格
    if (_withEip) {
      monthlyPrice += _eipPrice * _eipNum;
    }
    
    double total = monthlyPrice * _duration;
    
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

  // 续期价格（不含优惠券）
  double get _renewPrice {
    double extraDisk = _diskSize - _minDisk;
    double diskCost = extraDisk * _diskPrice;
    double price = _basePrice + diskCost;
    if (_withEip) {
      price += _eipPrice * _eipNum;
    }
    return price;
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
            
            // 硬盘大小选择
            _buildDiskSelector(cardColor, theme),
            const SizedBox(height: 16),
            
            // 独立IP选择
            _buildEipSelector(cardColor, theme),
            const SizedBox(height: 16),
            
            // 优惠券选择
            _buildCouponSelector(cardColor, theme),
            const SizedBox(height: 16),
            
            // 价格详情
            _buildPriceDetails(cardColor, theme),
            const SizedBox(height: 24),
            
            // 只显示试用按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _purchase(true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('1 元试用'),
              ),
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cloud, color: Colors.blue),
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
              Text('¥$_basePrice/月', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
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
                    border: Border.all(
                      color: isSelected ? theme.primaryColor : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    '$d个月',
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
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

  Widget _buildDiskSelector(Color cardColor, ThemeData theme) {
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
              const Text('系统硬盘', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                '${_diskSize.toInt()}G  (+¥${((_diskSize - _minDisk) * _diskPrice).toStringAsFixed(1)}/月)',
                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '硬盘单价: ¥$_diskPrice/G/月',
            style: TextStyle(fontSize: 12, color: theme.hintColor),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('${_minDisk.toInt()}G', style: TextStyle(fontSize: 12, color: theme.hintColor)),
              Expanded(
                child: Slider(
                  value: _diskSize,
                  min: _minDisk,
                  max: _maxDisk,
                  divisions: (_maxDisk - _minDisk).toInt(),
                  label: '${_diskSize.toInt()}G',
                  onChanged: (v) => setState(() => _diskSize = v),
                ),
              ),
              Text('${_maxDisk.toInt()}G', style: TextStyle(fontSize: 12, color: theme.hintColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEipSelector(Color cardColor, ThemeData theme) {
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
              const Text('独立IP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Switch(
                value: _withEip,
                onChanged: (v) => setState(() => _withEip = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isPriceLoading
              ? Text(
                  '正在加载价格...',
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                )
              : Text(
                  '附加独立IPv4地址（¥${_eipPrice.toStringAsFixed(0)}/个/月）',
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
          if (_withEip) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('IP数量', style: TextStyle(fontSize: 14)),
                Row(
                  children: [
                    IconButton(
                      onPressed: _eipNum > 1 ? () => setState(() => _eipNum--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 28,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$_eipNum',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                    ),
                    IconButton(
                      onPressed: _eipNum < 5 ? () => setState(() => _eipNum++) : null,
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 28,
                    ),
                  ],
                ),
              ],
            ),
            Text(
              '费用: +¥${(_eipPrice * _eipNum).toStringAsFixed(1)}/月',
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500),
            ),
          ],
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
              Text('${_coupons.length}张可用', style: TextStyle(fontSize: 12, color: theme.hintColor)),
            ],
          ),
          const SizedBox(height: 12),
          if (_coupons.isEmpty)
            Text('暂无可用优惠券', style: TextStyle(color: theme.hintColor, fontSize: 13))
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
                      color: _selectedCouponId == null 
                          ? theme.primaryColor.withOpacity(0.1) 
                          : theme.hintColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _selectedCouponId == null ? theme.primaryColor : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      '不使用',
                      style: TextStyle(
                        fontSize: 13,
                        color: _selectedCouponId == null ? theme.primaryColor : theme.hintColor,
                      ),
                    ),
                  ),
                ),
                // 优惠券列表
                ..._coupons.map((c) {
                  final id = c['id'];
                  final name = c['friendly_name'] ?? '优惠券';
                  final type = c['type'];
                  final value = c['value'];
                  final isSelected = _selectedCouponId == id;
                  
                  String label = name;
                  if (type == 'discount') {
                    label = '$name (${(value * 10).toStringAsFixed(1)}折)';
                  } else if (type == 'reduce') {
                    label = '$name (-¥$value)';
                  }
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCouponId = id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange.withOpacity(0.1) : theme.hintColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.orange : theme.textTheme.bodyMedium?.color,
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
    final extraDisk = _diskSize - _minDisk;
    final diskCost = extraDisk * _diskPrice;
    final eipCost = _withEip ? _eipPrice * _eipNum : 0;
    final monthlyBase = _basePrice + diskCost + eipCost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('价格详情', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _buildPriceRow('套餐基础价', '¥$_basePrice/月'),
          if (extraDisk > 0)
            _buildPriceRow('额外硬盘 (+${extraDisk.toInt()}G)', '+¥${diskCost.toStringAsFixed(1)}/月'),
          if (_withEip)
            _buildPriceRow('独立IP (${_eipNum}个)', '+¥${eipCost.toStringAsFixed(1)}/月'),
          _buildPriceRow('月费小计', '¥${monthlyBase.toStringAsFixed(1)}/月'),
          _buildPriceRow('购买时长', '$_duration个月'),
          const Divider(height: 20),
          _buildPriceRow('原价', '¥${(monthlyBase * _duration).toStringAsFixed(2)}'),
          if (_selectedCouponId != null) ...[
            _buildPriceRow('优惠券抵扣', '-¥${((monthlyBase * _duration) - _totalPrice).toStringAsFixed(2)}', valueColor: Colors.green),
          ],
          const Divider(height: 20),
          _buildPriceRow('应付金额', '¥${_totalPrice.toStringAsFixed(2)}', isBold: true, valueColor: Colors.red),
          const SizedBox(height: 8),
          _buildPriceRow('续期价格', '¥${_renewPrice.toStringAsFixed(1)}/月', valueColor: theme.hintColor),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 15 : 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getRegionName(String region) {
    const regionMap = {
      'us-la1': '🇺🇸 美国洛杉矶',
      'cn-sq1': '🇨🇳 宿迁',
      'cn-sy1': '🇨🇳 沈阳',
      'hk-hk1': '🇭🇰 香港',
      'jp-tk1': '🇯🇵 日本东京',
      'mainland_china': '🇨🇳 中国大陆',
    };
    return regionMap[region] ?? region;
  }

  Future<void> _purchase(bool isTrial) async {
    setState(() => _isLoading = true);
    
    try {
      final Map<String, dynamic> data = {
        'plan_id': _planId,
        'duration': _duration,
        'os_id': 1, // 默认系统，实际应该让用户选择
        'add_disk_size': (_diskSize - _minDisk).toInt(),
        'try': isTrial,
      };
      
      // 独立IP参数
      if (_withEip) {
        data['with_eip_num'] = _eipNum;
        data['with_eip_type'] = 'IPv4';
      }
      
      if (_selectedCouponId != null && !isTrial) {
        data['with_coupon_id'] = _selectedCouponId!;
      }

      final response = await _apiService.post('/product/rcs/', data: data);
      
      if (response['code'] == 200) {
        if (mounted) {
          TDToast.showSuccess(isTrial ? '试用成功' : '购买成功', context: context);
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response['message'] ?? '操作失败');
      }
    } catch (e) {
      if (mounted) {
        TDToast.showFail('$e', context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
