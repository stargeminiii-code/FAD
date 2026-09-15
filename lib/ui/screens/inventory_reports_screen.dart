import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../services/inventory_report_service.dart';
import '../../services/inventory_service.dart';

class InventoryReportsScreen extends StatefulWidget {
  final InventoryService inventoryService;

  const InventoryReportsScreen({super.key, required this.inventoryService});

  @override
  State<InventoryReportsScreen> createState() => _InventoryReportsScreenState();
}

class _InventoryReportsScreenState extends State<InventoryReportsScreen> {
  final InventoryReportService _reportService = InventoryReportService();
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');

  @override
  Widget build(BuildContext context) {
    final db = widget.inventoryService.db;
    final reportData = _reportService.generateInventorySummaryReport(
      items: db.items,
      inwards: db.inwards,
      outwards: db.outwards,
      openingQuantities: db.openingQuantities,
      openingAmounts: db.openingAmounts,
    );

    // Totals
    final totalOpeningAmt = reportData.fold(0.0, (sum, r) => sum + r.openingAmount);
    final totalInwardAmt = reportData.fold(0.0, (sum, r) => sum + r.inwardAmount);
    final totalOutwardAmt = reportData.fold(0.0, (sum, r) => sum + r.outwardAmount);
    final totalClosingAmt = reportData.fold(0.0, (sum, r) => sum + r.closingAmount);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Report Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.assessment_rounded, color: AppTheme.primary, size: 32),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BẢNG TỔNG HỢP NHẬP - XUẤT - TỒN (MẪU S11-DN)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ban hành theo Thông tư số 200/2014/TT-BTC & TT 133/2016/TT-BTC của Bộ Tài Chính',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đang chuẩn bị mẫu in Báo cáo S11-DN...'), backgroundColor: AppTheme.primary),
                        );
                      },
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('In Báo Cáo'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xuất dữ liệu ra bảng tính Excel thành công!'), backgroundColor: AppTheme.success),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Xuất Excel'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // S11-DN Table
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(const Color(0xFFE2E8F0)),
                      border: TableBorder.all(color: const Color(0xFFCBD5E1), width: 0.5),
                      columns: const [
                        DataColumn(label: Text('Mã VTHH', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tên Vật Tư Hàng Hóa', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ĐVT', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tồn ĐK (Lượng)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                        DataColumn(label: Text('Tồn ĐK (Tiền)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                        DataColumn(label: Text('Nhập (Lượng)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                        DataColumn(label: Text('Nhập (Tiền)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                        DataColumn(label: Text('Xuất (Lượng)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                        DataColumn(label: Text('Xuất (Tiền)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                        DataColumn(label: Text('Tồn CK (Lượng)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                        DataColumn(label: Text('Tồn CK (Tiền)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      ],
                      rows: [
                        // Data rows
                        ...reportData.map((row) {
                          return DataRow(
                            cells: [
                              DataCell(Text(row.itemCode, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                              DataCell(Text(row.itemName)),
                              DataCell(Text(row.unitName)),
                              DataCell(Text('${row.openingQty}')),
                              DataCell(Text('${_currencyFormat.format(row.openingAmount)} đ')),
                              DataCell(Text('${row.inwardQty}')),
                              DataCell(Text('${_currencyFormat.format(row.inwardAmount)} đ')),
                              DataCell(Text('${row.outwardQty}')),
                              DataCell(Text('${_currencyFormat.format(row.outwardAmount)} đ')),
                              DataCell(Text('${row.closingQty}', style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(
                                Text(
                                  '${_currencyFormat.format(row.closingAmount)} đ',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                                ),
                              ),
                            ],
                          );
                        }),
                        // Total summary row
                        DataRow(
                          color: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                          cells: [
                            const DataCell(Text('TỔNG CỘNG', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                            DataCell(Text('${_currencyFormat.format(totalOpeningAmt)} đ', style: const TextStyle(fontWeight: FontWeight.bold))),
                            const DataCell(Text('')),
                            DataCell(Text('${_currencyFormat.format(totalInwardAmt)} đ', style: const TextStyle(fontWeight: FontWeight.bold))),
                            const DataCell(Text('')),
                            DataCell(Text('${_currencyFormat.format(totalOutwardAmt)} đ', style: const TextStyle(fontWeight: FontWeight.bold))),
                            const DataCell(Text('')),
                            DataCell(
                              Text(
                                '${_currencyFormat.format(totalClosingAmt)} đ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
