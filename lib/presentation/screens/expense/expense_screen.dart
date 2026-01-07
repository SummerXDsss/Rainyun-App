import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/rainyun_api_service.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> with SingleTickerProviderStateMixin {
  final RainyunApiService _apiService = RainyunApiService();
  late TabController _tabController;
  
  bool _isLoading = true;
  String? _error;
  
  // 订单数据
  List<Map<String, dynamic>> _orders = [];
  // 发票数据
  List<Map<String, dynamic>> _invoices = [];
  // 用户余额
  double _balance = 0;
  
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
    if (!_apiService.hasApiKey()) {
      setState(() {
        _isLoading = false;
        _error = '请先绑定 API Key';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // 获取用户信息（包含余额）
      final userResponse = await _apiService.getUserInfo();
      final userCode = userResponse['code'] ?? userResponse['Code'];
      if (userCode == 200) {
        final userData = userResponse['data'] ?? userResponse['Data'];
        if (userData != null) {
          _balance = (userData['Money'] ?? 0).toDouble();
        }
      }
      
      // 注：订单和发票API暂不可用，跳过获取
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // 只有获取用户信息失败才显示错误
        if (_balance == 0) {
          _error = e.toString();
        }
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
      appBar: AppBar(
        title: const Text('费用管理'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '订单记录'),
            Tab(text: '发票管理'),
          ],
          labelColor: theme.primaryColor,
          unselectedLabelColor: theme.textTheme.bodyMedium?.color,
          indicatorColor: theme.primaryColor,
        ),
      ),
      body: Column(
        children: [
          // 余额卡片
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '账户余额',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¥ ${_balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showRechargeDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('充值'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 内容区域
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                            const SizedBox(height: 16),
                            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrdersList(cardColor, theme),
                          _buildInvoicesList(cardColor, theme),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrdersList(Color cardColor, ThemeData theme) {
    if (_orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long_outlined, size: 48, color: theme.primaryColor),
              ),
              const SizedBox(height: 24),
              const Text(
                '订单记录',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '您可以在雨云官网查看完整的订单记录',
                style: TextStyle(color: theme.hintColor, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse('https://rainyun.com/account/bindmoney');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_browser, size: 18),
                label: const Text('前往官网查看'),
              ),
            ],
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order, cardColor, theme);
        },
      ),
    );
  }
  
  Widget _buildOrderCard(Map<String, dynamic> order, Color cardColor, ThemeData theme) {
    final orderId = order['OrderID']?.toString() ?? order['ID']?.toString() ?? '';
    final amount = (order['Amount'] ?? order['Money'] ?? 0).toDouble();
    final status = order['Status'] ?? order['PayStatus'] ?? 0;
    final createTime = order['CreateTime'] ?? order['CreatedAt'] ?? '';
    final productName = order['ProductName'] ?? order['Name'] ?? '未知产品';
    
    String statusText = '未知';
    Color statusColor = Colors.grey;
    if (status == 1 || status == 'paid') {
      statusText = '已支付';
      statusColor = Colors.green;
    } else if (status == 0 || status == 'pending') {
      statusText = '待支付';
      statusColor = Colors.orange;
    } else if (status == -1 || status == 'cancelled') {
      statusText = '已取消';
      statusColor = Colors.red;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
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
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '订单号: $orderId',
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
              ),
              Text(
                '¥ ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '创建时间: ${_formatTime(createTime)}',
            style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInvoicesList(Color cardColor, ThemeData theme) {
    if (_invoices.isEmpty) {
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
                child: const Icon(Icons.description_outlined, size: 48, color: Colors.orange),
              ),
              const SizedBox(height: 24),
              const Text(
                '发票管理',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '您可以在雨云官网申请和查看发票',
                style: TextStyle(color: theme.hintColor, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse('https://rainyun.com/account/bindmoney');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_browser, size: 18),
                label: const Text('前往官网申请'),
              ),
            ],
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _invoices.length,
        itemBuilder: (context, index) {
          final invoice = _invoices[index];
          return _buildInvoiceCard(invoice, cardColor, theme);
        },
      ),
    );
  }
  
  Widget _buildInvoiceCard(Map<String, dynamic> invoice, Color cardColor, ThemeData theme) {
    final invoiceId = invoice['ID']?.toString() ?? '';
    final amount = (invoice['Amount'] ?? 0).toDouble();
    final status = invoice['Status'] ?? 0;
    final createTime = invoice['CreateTime'] ?? invoice['CreatedAt'] ?? '';
    
    String statusText = '处理中';
    Color statusColor = Colors.orange;
    if (status == 1) {
      statusText = '已开具';
      statusColor = Colors.green;
    } else if (status == -1) {
      statusText = '已拒绝';
      statusColor = Colors.red;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description, color: theme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '发票 #$invoiceId',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '金额: ¥${amount.toStringAsFixed(2)}',
                  style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
                ),
                Text(
                  '申请时间: ${_formatTime(createTime)}',
                  style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
                ),
              ],
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
              style: TextStyle(color: statusColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(dynamic time) {
    if (time == null || time == '') return '未知';
    if (time is int) {
      final dt = DateTime.fromMillisecondsSinceEpoch(time * 1000);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return time.toString();
  }

  void _showRechargeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('充值'),
        content: const Text('请前往雨云官网完成充值操作'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final url = Uri.parse('https://rainyun.com/account/bindmoney');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: const Text('前往官网充值'),
          ),
        ],
      ),
    );
  }
}
