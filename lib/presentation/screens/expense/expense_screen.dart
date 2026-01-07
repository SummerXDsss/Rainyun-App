import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
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
      
      // 获取订单列表
      final ordersResponse = await _apiService.get('/pay/order/', queryParameters: {'page': 1, 'page_size': 50});
      final ordersCode = ordersResponse['code'] ?? ordersResponse['Code'];
      if (ordersCode == 200) {
        final ordersData = ordersResponse['data'] ?? ordersResponse['Data'];
        if (ordersData != null && ordersData['Records'] != null) {
          _orders = List<Map<String, dynamic>>.from(ordersData['Records']);
        }
      }
      
      // 获取发票列表
      final invoicesResponse = await _apiService.get('/pay/invoice/', queryParameters: {'page': 1, 'page_size': 50});
      final invoicesCode = invoicesResponse['code'] ?? invoicesResponse['Code'];
      if (invoicesCode == 200) {
        final invoicesData = invoicesResponse['data'] ?? invoicesResponse['Data'];
        if (invoicesData != null && invoicesData['Records'] != null) {
          _invoices = List<Map<String, dynamic>>.from(invoicesData['Records']);
        }
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
                  onPressed: () {
                    TDToast.showText('充值功能开发中', context: context);
                  },
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text('暂无订单记录', style: TextStyle(color: theme.disabledColor)),
          ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text('暂无发票记录', style: TextStyle(color: theme.disabledColor)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                TDToast.showText('申请发票功能开发中', context: context);
              },
              icon: const Icon(Icons.add),
              label: const Text('申请发票'),
            ),
          ],
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
}
