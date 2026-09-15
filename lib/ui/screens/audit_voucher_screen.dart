import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/audit_voucher_model.dart';
import '../../services/inventory_service.dart';

class AuditVoucherScreen extends StatefulWidget {
  final InventoryService inventoryService;

  const AuditVoucherScreen({super.key, required this.inventoryService});

  @override
  State<AuditVoucherScreen> createState() => _AuditVoucherScreenState();
}

class _AuditVoucherScreenState extends State<AuditVoucherScreen> {
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final audits = widget.inventoryService.getAudits();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.fact_check_rounded, color: Color(0xFF059669), size: 28),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Biên Bản Kiểm Kê Kho (IN_AUDITWARD)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                        Text('Đối chiếu số liệu Sổ kế toán & Thực tế tại kho • Tự động xử lý thừa thiếu',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateAuditDialog(context),
                      icon: const Icon(Icons.add_task, size: 18),
                      label: const Text('Tạo Đợt Kiểm Kê Mới'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Audits List
            Expanded(
              child: Card(
                child: audits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_outlined, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text('Chưa có biên bản kiểm kê kho nào'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _showCreateAuditDialog(context),
                              child: const Text('Tạo Biên Bản Kiểm Kê Đầu Tiên'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: audits.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final audit = audits[index];
                          final hasDiscrepancy = audit.details.any((d) => d.diffQuantity != 0);

                          return ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: audit.isHandled ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                              child: Icon(
                                audit.isHandled ? Icons.check_circle : Icons.warning_amber_rounded,
                                color: audit.isHandled ? AppTheme.success : AppTheme.warning,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(audit.voucherNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                const SizedBox(width: 12),
                                Text(audit.stockName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Chip(
                                  label: Text(
                                    audit.isHandled ? 'Đã xử lý chênh lệch' : 'Chưa xử lý',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: audit.isHandled ? AppTheme.success : AppTheme.warning,
                                    ),
                                  ),
                                  backgroundColor: audit.isHandled ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                  side: BorderSide.none,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            subtitle: Text(
                                'Ngày kiểm kê: ${_dateFormat.format(audit.auditDate)} • Ban kiểm kê: ${audit.leaderName} (Trưởng ban), ${audit.keeperName} (Thủ kho)'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Chi Tiết Kết Quả Kiểm Kê Từng Mặt Hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                                        columns: const [
                                          DataColumn(label: Text('Mã VTHH', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Tên Mặt Hàng', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('ĐVT', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Sổ Sách', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                          DataColumn(label: Text('Thực Tế', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                          DataColumn(label: Text('Chênh Lệch', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                          DataColumn(label: Text('Giá Trị Chênh Lệch', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                                          DataColumn(label: Text('Kết Luận Xử Lý', style: TextStyle(fontWeight: FontWeight.bold))),
                                        ],
                                        rows: audit.details.map((d) {
                                          final isDiff = d.diffQuantity != 0;
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(d.inventoryItemCode, style: const TextStyle(fontWeight: FontWeight.bold))),
                                              DataCell(Text(d.inventoryItemName)),
                                              DataCell(Text(d.unitName)),
                                              DataCell(Text('${d.bookQuantity}')),
                                              DataCell(Text('${d.actualQuantity}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                              DataCell(
                                                Text(
                                                  d.diffQuantity > 0 ? '+${d.diffQuantity}' : '${d.diffQuantity}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: d.diffQuantity > 0
                                                        ? AppTheme.success
                                                        : d.diffQuantity < 0
                                                            ? AppTheme.danger
                                                            : Colors.black54,
                                                  ),
                                                ),
                                              ),
                                              DataCell(Text('${_currencyFormat.format(d.diffAmount)} đ')),
                                              DataCell(
                                                Text(
                                                  d.diffQuantity > 0
                                                      ? 'Thừa -> Nhập kho thừa (TK 3381)'
                                                      : d.diffQuantity < 0
                                                          ? 'Thiếu -> Xuất kho thiếu (TK 1381)'
                                                          : 'Khớp 100%',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDiff ? AppTheme.primary : AppTheme.success,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (hasDiscrepancy && !audit.isHandled)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.auto_fix_high, size: 18),
                                          label: const Text('Tự Động Sinh Phiếu Xử Lý Chênh Lệch (NK/XK)'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF059669),
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              widget.inventoryService.handleAuditDiscrepancies(audit);
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Đã tự động tạo Phiếu Nhập Hàng Thừa (TK 3381) và Phiếu Xuất Hàng Thiếu (TK 1381)!'),
                                                backgroundColor: AppTheme.success,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAuditDialog(BuildContext context) {
    final stocks = widget.inventoryService.getStocks();
    final items = widget.inventoryService.getItems();
    if (stocks.isEmpty || items.isEmpty) return;

    final voucherNoCtrl = TextEditingController(text: 'KK0000${widget.inventoryService.getAudits().length + 1}');
    final leaderCtrl = TextEditingController(text: 'Nguyễn Văn Minh (Kế toán trưởng)');
    final keeperCtrl = TextEditingController(text: 'Lê Văn Nam (Thủ kho)');
    String selectedStockId = stocks.first.stockId;

    // Build detail items with book quantity
    final details = items.map((i) {
      return AuditDetailModel(
        detailId: const Uuid().v4(),
        auditId: const Uuid().v4(),
        inventoryItemId: i.inventoryItemId,
        inventoryItemCode: i.inventoryItemCode,
        inventoryItemName: i.inventoryItemName,
        unitName: i.unitName,
        bookQuantity: i.onHandQuantity,
        actualQuantity: i.onHandQuantity, // Default matches book
        costPrice: i.averageCostPrice,
      );
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final stock = stocks.firstWhere((s) => s.stockId == selectedStockId);

            return AlertDialog(
              title: const Text('Khởi Tạo Đợt Kiểm Kê Kho (Chuẩn MISA)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 750,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: voucherNoCtrl,
                              decoration: const InputDecoration(labelText: 'Số biên bản *'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedStockId,
                              decoration: const InputDecoration(labelText: 'Kho kiểm kê *'),
                              items: stocks.map((s) => DropdownMenuItem(value: s.stockId, child: Text(s.stockName))).toList(),
                              onChanged: (val) {
                                if (val != null) setDialogState(() => selectedStockId = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: leaderCtrl,
                              decoration: const InputDecoration(labelText: 'Trưởng ban kiểm kê'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: keeperCtrl,
                              decoration: const InputDecoration(labelText: 'Thủ kho tham gia'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nhập Số Lượng Thực Tế Kiểm Kê (Tự động tính chênh lệch)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      ...details.map((d) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text('${d.inventoryItemCode} - ${d.inventoryItemName}'),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text('Sổ: ${d.bookQuantity} ${d.unitName}'),
                              ),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: '${d.actualQuantity}',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Thực tế', isDense: true),
                                  onChanged: (val) {
                                    final newActual = double.tryParse(val.trim()) ?? d.bookQuantity;
                                    setDialogState(() {
                                      d.updateActualQuantity(newActual);
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  d.diffQuantity == 0
                                      ? 'Khớp'
                                      : d.diffQuantity > 0
                                          ? '+${d.diffQuantity} (Thừa)'
                                          : '${d.diffQuantity} (Thiếu)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: d.diffQuantity > 0
                                        ? AppTheme.success
                                        : d.diffQuantity < 0
                                            ? AppTheme.danger
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy bỏ')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
                  onPressed: () {
                    final newAudit = AuditVoucherModel(
                      auditId: const Uuid().v4(),
                      voucherNo: voucherNoCtrl.text.trim(),
                      auditDate: DateTime.now(),
                      stockId: stock.stockId,
                      stockName: stock.stockName,
                      leaderName: leaderCtrl.text.trim(),
                      keeperName: keeperCtrl.text.trim(),
                      details: details,
                    );

                    widget.inventoryService.addAuditVoucher(newAudit);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                  child: const Text('Lưu Biên Bản Kiểm Kê'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
