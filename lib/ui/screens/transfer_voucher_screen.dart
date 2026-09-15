import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/transfer_voucher_model.dart';
import '../../services/inventory_service.dart';

class TransferVoucherScreen extends StatefulWidget {
  final InventoryService inventoryService;

  const TransferVoucherScreen({super.key, required this.inventoryService});

  @override
  State<TransferVoucherScreen> createState() => _TransferVoucherScreenState();
}

class _TransferVoucherScreenState extends State<TransferVoucherScreen> {
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final transfers = widget.inventoryService.getTransfers();

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
                    const Icon(Icons.swap_horiz_rounded, color: AppTheme.secondary, size: 28),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phiếu Điều Chuyển Kho Nội Bộ (IN_TRANSFER)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                        Text('Luân chuyển hàng hóa giữa các kho & hạch toán Nợ 156 (Kho nhận) / Có 156 (Kho xuất)',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddTransferDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Lập Phiếu Điều Chuyển'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Transfer Table
            Expanded(
              child: Card(
                child: transfers.isEmpty
                    ? const Center(child: Text('Chưa có phiếu điều chuyển kho nào'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                            columns: const [
                              DataColumn(label: Text('Số Phiếu', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Ngày Chuyển', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Từ Kho (Kho Xuất)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Đến Kho (Kho Nhập)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Hình Thức Chuyển', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tổng Số Lượng', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Giá Trị Chuyển', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Đơn Vị Vận Chuyển', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: transfers.map((voucher) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(voucher.voucherNo,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                  ),
                                  DataCell(Text(_dateFormat.format(voucher.postedDate))),
                                  DataCell(Text(voucher.fromStockName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(voucher.toStockName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(
                                    Chip(
                                      label: Text(
                                        voucher.isInTransit ? 'Qua hàng đi đường (157)' : 'Chuyển trực tiếp',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      side: BorderSide.none,
                                      backgroundColor: const Color(0xFFE0F2FE),
                                    ),
                                  ),
                                  DataCell(Text('${voucher.totalQuantity}')),
                                  DataCell(
                                    Text('${_currencyFormat.format(voucher.totalAmount)} đ',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  DataCell(Text(voucher.transporter.isEmpty ? 'Nội bộ công ty' : voucher.transporter)),
                                ],
                              );
                            }).toList(),
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

  void _showAddTransferDialog(BuildContext context) {
    final stocks = widget.inventoryService.getStocks();
    final items = widget.inventoryService.getItems();
    if (stocks.length < 2 || items.isEmpty) return;

    final voucherNoCtrl = TextEditingController(text: 'CK0000${widget.inventoryService.getTransfers().length + 1}');
    final transporterCtrl = TextEditingController(text: 'Viettel Post');
    final memoCtrl = TextEditingController(text: 'Điều chuyển hàng hóa giữa các kho chi nhánh');
    String fromStockId = stocks[0].stockId;
    String toStockId = stocks[1].stockId;
    bool isInTransit = false;

    String selectedItemId = items.first.inventoryItemId;
    final qtyCtrl = TextEditingController(text: '5');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final fromStock = stocks.firstWhere((s) => s.stockId == fromStockId);
            final toStock = stocks.firstWhere((s) => s.stockId == toStockId);
            final chosenItem = items.firstWhere((i) => i.inventoryItemId == selectedItemId);

            return AlertDialog(
              title: const Text('Lập Phiếu Điều Chuyển Kho (Chuẩn MISA)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 650,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: voucherNoCtrl,
                              decoration: const InputDecoration(labelText: 'Số phiếu *'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: transporterCtrl,
                              decoration: const InputDecoration(labelText: 'Đơn vị vận chuyển'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: fromStockId,
                              decoration: const InputDecoration(labelText: 'Từ kho (Kho xuất) *'),
                              items: stocks.map((s) => DropdownMenuItem(value: s.stockId, child: Text(s.stockName))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() => fromStockId = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: toStockId,
                              decoration: const InputDecoration(labelText: 'Đến kho (Kho nhập) *'),
                              items: stocks.map((s) => DropdownMenuItem(value: s.stockId, child: Text(s.stockName))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() => toStockId = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Chuyển kho qua Hàng đi trên đường (TK 157)'),
                        subtitle: const Text('Sử dụng khi kho xuất và kho nhập cách xa nhau (vài ngày vận chuyển)'),
                        value: isInTransit,
                        onChanged: (val) {
                          setDialogState(() => isInTransit = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: memoCtrl,
                        decoration: const InputDecoration(labelText: 'Diễn giải điều chuyển'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Mặt Hàng Điều Chuyển', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedItemId,
                        decoration: const InputDecoration(labelText: 'Chọn VTHH *'),
                        items: items.map((i) {
                          return DropdownMenuItem(value: i.inventoryItemId, child: Text('${i.inventoryItemCode} - ${i.inventoryItemName}'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedItemId = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Số lượng điều chuyển *'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy bỏ')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, foregroundColor: Colors.white),
                  onPressed: () {
                    final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1.0;
                    final price = chosenItem.averageCostPrice;

                    final detail = TransferDetailModel(
                      detailId: const Uuid().v4(),
                      transferId: const Uuid().v4(),
                      inventoryItemId: chosenItem.inventoryItemId,
                      inventoryItemCode: chosenItem.inventoryItemCode,
                      inventoryItemName: chosenItem.inventoryItemName,
                      unitName: chosenItem.unitName,
                      quantity: qty,
                      unitPrice: price,
                      amount: qty * price,
                    );

                    final newVoucher = TransferVoucherModel(
                      transferId: detail.transferId,
                      voucherNo: voucherNoCtrl.text.trim(),
                      voucherDate: DateTime.now(),
                      postedDate: DateTime.now(),
                      fromStockId: fromStock.stockId,
                      fromStockName: fromStock.stockName,
                      toStockId: toStock.stockId,
                      toStockName: toStock.stockName,
                      isInTransit: isInTransit,
                      transporter: transporterCtrl.text.trim(),
                      journalMemo: memoCtrl.text.trim(),
                      isPosted: true,
                      details: [detail],
                    );

                    widget.inventoryService.addTransferVoucher(newVoucher);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                  child: const Text('Lưu & Ghi Sổ'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
