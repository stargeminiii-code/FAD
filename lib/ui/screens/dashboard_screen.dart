import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/inventory_service.dart';

class DashboardScreen extends StatelessWidget {
  final InventoryService inventoryService;
  final Function(int) onNavigate;

  const DashboardScreen({
    super.key,
    required this.inventoryService,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###', 'vi_VN');
    final db = inventoryService.db;

    final totalInventoryAmount = db.items.fold(0.0, (sum, i) => sum + i.inventoryAmount);
    final totalItemCount = db.items.length;
    final lowStockItems = db.items.where((i) => i.onHandQuantity <= i.minimumStock).toList();
    final totalVouchers = db.inwards.length + db.outwards.length + db.transfers.length;
    final totalGLPostings = db.glPostings.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner chào mừng & chi nhánh
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.warehouse_rounded, color: Colors.white, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hệ Thống Quản Lý Kho & Kế Toán Kho (BizOne ERP - FAD)',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đơn vị: CÔNG TY CỔ PHẦN BIZONE • Chuẩn kế toán: Thông tư 200/2014/TT-BTC & TT 133/2016/TT-BTC',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // KPI Stat Cards Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 1.9 : 1.3,
                  children: [
                    _buildKpiCard(
                      title: 'Tổng Giá Trị Tồn Kho',
                      value: '${currencyFormatter.format(totalInventoryAmount)} đ',
                      subtext: 'Theo giá vốn bình quân',
                      icon: Icons.monetization_on,
                      color: AppTheme.primary,
                    ),
                    _buildKpiCard(
                      title: 'Số Mặt Hàng (SKU)',
                      value: '$totalItemCount VTHH',
                      subtext: 'Đang theo dõi quản lý',
                      icon: Icons.category,
                      color: AppTheme.secondary,
                    ),
                    _buildKpiCard(
                      title: 'Cảnh Báo Hết Hàng',
                      value: '${lowStockItems.length} mặt hàng',
                      subtext: 'Dưới mức tồn tối thiểu',
                      icon: Icons.warning_amber_rounded,
                      color: lowStockItems.isNotEmpty ? AppTheme.warning : AppTheme.success,
                    ),
                    _buildKpiCard(
                      title: 'Bút Toán Sổ Cái GL',
                      value: '$totalGLPostings bút toán',
                      subtext: 'Đã sinh từ $totalVouchers chứng từ',
                      icon: Icons.account_balance_wallet,
                      color: const Color(0xFF7C3AED),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Operations Buttons
            const Text(
              'Nghiệp Vụ Thao Tác Nhanh (MISA Quick Actions)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Lập Phiếu Nhập Kho',
                  color: AppTheme.primary,
                  onPressed: () => onNavigate(2),
                ),
                _buildActionButton(
                  icon: Icons.remove_circle_outline,
                  label: 'Lập Phiếu Xuất Kho',
                  color: const Color(0xFFD97706),
                  onPressed: () => onNavigate(3),
                ),
                _buildActionButton(
                  icon: Icons.swap_horiz,
                  label: 'Điều Chuyển Kho',
                  color: AppTheme.secondary,
                  onPressed: () => onNavigate(4),
                ),
                _buildActionButton(
                  icon: Icons.fact_check,
                  label: 'Kiểm Kê Kho',
                  color: const Color(0xFF059669),
                  onPressed: () => onNavigate(5),
                ),
                _buildActionButton(
                  icon: Icons.calculate,
                  label: 'Tính Giá Xuất Kho',
                  color: const Color(0xFF4F46E5),
                  onPressed: () => onNavigate(6),
                ),
                _buildActionButton(
                  icon: Icons.table_chart,
                  label: 'Xem Báo Cáo S11-DN',
                  color: const Color(0xFF2563EB),
                  onPressed: () => onNavigate(7),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Cảnh báo tồn kho tối thiểu nếu có
            if (lowStockItems.isNotEmpty) ...[
              Card(
                color: const Color(0xFFFFFBEB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFFDE68A)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notification_important, color: AppTheme.warning, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Cảnh báo tồn kho dưới mức tối thiểu (${lowStockItems.length} mặt hàng cần nhập bổ sung)',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: lowStockItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text('${item.inventoryItemCode} - ${item.inventoryItemName}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                ),
                                Text(
                                  'Tồn: ${item.onHandQuantity} ${item.unitName} (Tối thiểu: ${item.minimumStock})',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.danger, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Bảng danh sách chứng từ gần đây
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chứng Từ Kho Gần Đây',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                        ),
                        TextButton.icon(
                          onPressed: () => onNavigate(2),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Xem tất cả'),
                        ),
                      ],
                    ),
                    const Divider(),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ...db.inwards.take(2).map((inward) {
                          return ListTile(
                            dense: true,
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFDCFCE7),
                              child: Icon(Icons.arrow_downward, color: AppTheme.success, size: 18),
                            ),
                            title: Text('${inward.voucherNo} • ${inward.journalMemo}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(
                                '${DateFormat('dd/MM/yyyy HH:mm').format(inward.voucherDate)} • Đối tượng: ${inward.accountObjectName}'),
                            trailing: Text(
                              '+${currencyFormatter.format(inward.totalAmount)} đ',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success, fontSize: 13),
                            ),
                          );
                        }),
                        ...db.outwards.take(2).map((outward) {
                          return ListTile(
                            dense: true,
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFFEF3C7),
                              child: Icon(Icons.arrow_upward, color: Color(0xFFD97706), size: 18),
                            ),
                            title: Text('${outward.voucherNo} • ${outward.journalMemo}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(
                                '${DateFormat('dd/MM/yyyy HH:mm').format(outward.voucherDate)} • Người nhận: ${outward.accountObjectName}'),
                            trailing: Text(
                              '-${currencyFormatter.format(outward.totalCogsAmount)} đ',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706), fontSize: 13),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtext,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
