import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/inward_voucher_model.dart';
import '../../services/inventory_service.dart';

class InwardVoucherScreen extends StatefulWidget {
  final InventoryService inventoryService;

  const InwardVoucherScreen({super.key, required this.inventoryService});

  @override
  State<InwardVoucherScreen> createState() => _InwardVoucherScreenState();
}

class _InwardVoucherScreenState extends State<InwardVoucherScreen> {
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final inwards = widget.inventoryService.getInwards();

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
                    const Icon(Icons.arrow_downward_rounded, color: AppTheme.success, size: 28),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Danh Sách Phiếu Nhập Kho (IN_INWARD)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                        Text('Ghi nhận tăng tồn kho & hạch toán Nợ 152/156/155 Có 331/111/112',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddInwardDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Lập Phiếu Nhập Kho (F2)'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Inward Vouchers Table
            Expanded(
              child: Card(
                child: inwards.isEmpty
                    ? const Center(child: Text('Chưa có phiếu nhập kho nào'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                            columns: const [
                              DataColumn(label: Text('Số Phiếu', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Ngày Hạch Toán', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Đối Tượng / Nhà Cung Cấp', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Kho Nhập', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Diễn Giải Nghiệp Vụ', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tổng Số Lượng', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Tổng Tiền Hàng', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Trạng Thái Sổ Cái', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Thao Tác', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: inwards.map((voucher) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(voucher.voucherNo,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                  ),
                                  DataCell(Text(_dateFormat.format(voucher.postedDate))),
                                  DataCell(Text(voucher.accountObjectName)),
                                  DataCell(Text(voucher.stockName)),
                                  DataCell(Text(voucher.journalMemo)),
                                  DataCell(Text('${voucher.totalQuantity}')),
                                  DataCell(
                                    Text('${_currencyFormat.format(voucher.totalAmount)} đ',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  DataCell(
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          widget.inventoryService.toggleInwardPosting(voucher.inwardId);
                                        });
                                      },
                                      child: Chip(
                                        avatar: Icon(
                                          voucher.isPosted ? Icons.check_circle : Icons.pause_circle_outline,
                                          size: 14,
                                          color: voucher.isPosted ? AppTheme.success : Colors.grey,
                                        ),
                                        label: Text(
                                          voucher.isPosted ? 'Đã ghi sổ' : 'Bỏ ghi sổ',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: voucher.isPosted ? AppTheme.success : Colors.black54,
                                          ),
                                        ),
                                        backgroundColor: voucher.isPosted ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                        side: BorderSide.none,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: AppTheme.primary),
                                      onPressed: () => _showViewDetailDialog(context, voucher),
                                      tooltip: 'Xem chi tiết dòng hàng & hạch toán',
                                    ),
                                  ),
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

  void _showAddInwardDialog(BuildContext context) {
    final stocks = widget.inventoryService.getStocks();
    final items = widget.inventoryService.getItems();
    if (items.isEmpty || stocks.isEmpty) return;

    final voucherNoCtrl = TextEditingController(text: 'NK0000${widget.inventoryService.getInwards().length + 1}');
    final supplierCtrl = TextEditingController(text: 'CÔNG TY CỔ PHẦN MISA');
    final memoCtrl = TextEditingController(text: 'Nhập kho mua hàng');
    String selectedStockId = stocks.first.stockId;
    String selectedStockName = stocks.first.stockName;

    // Line item state
    String selectedItemId = items.first.inventoryItemId;
    final qtyCtrl = TextEditingController(text: '10');
    final priceCtrl = TextEditingController(text: '${items.first.purchasePrice.toInt()}');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Lập Phiếu Nhập Kho (Chuẩn MISA)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 650,
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
                              decoration: const InputDecoration(labelText: 'Số phiếu *'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedStockId,
                              decoration: const InputDecoration(labelText: 'Kho nhập *'),
                              items: stocks.map((s) {
                                return DropdownMenuItem(value: s.stockId, child: Text(s.stockName));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    selectedStockId = val;
                                    selectedStockName = stocks.firstWhere((s) => s.stockId == val).stockName;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: supplierCtrl,
                        decoration: const InputDecoration(labelText: 'Nhà cung cấp / Đối tượng *'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: memoCtrl,
                        decoration: const InputDecoration(labelText: 'Diễn giải lý do nhập kho'),
                      ),
                      const SizedBox(height: 20),
                      const Text('Chi Tiết Mặt Hàng Nhập Kho (Line Item)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedItemId,
                        decoration: const InputDecoration(labelText: 'Chọn VTHH *'),
                        items: items.map((i) {
                          return DropdownMenuItem(value: i.inventoryItemId, child: Text('${i.inventoryItemCode} - ${i.inventoryItemName}'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedItemId = val;
                              final chosen = items.firstWhere((i) => i.inventoryItemId == val);
                              priceCtrl.text = '${chosen.purchasePrice.toInt()}';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: qtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Số lượng nhập *'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Đơn giá mua (VND) *'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text('Tự động hạch toán Kế toán: Nợ TK 1561 / Có TK 331 (Theo TT 200)',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMain, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy bỏ')),
                ElevatedButton(
                  onPressed: () {
                    final chosenItem = items.firstWhere((i) => i.inventoryItemId == selectedItemId);
                    final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1.0;
                    final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;

                    final detail = InwardDetailModel(
                      detailId: const Uuid().v4(),
                      inwardId: const Uuid().v4(),
                      inventoryItemId: chosenItem.inventoryItemId,
                      inventoryItemCode: chosenItem.inventoryItemCode,
                      inventoryItemName: chosenItem.inventoryItemName,
                      unitName: chosenItem.unitName,
                      quantity: qty,
                      unitPrice: price,
                      debitAccount: chosenItem.inventoryAccount,
                      creditAccount: AppConstants.accAP,
                    );

                    final newVoucher = InwardVoucherModel(
                      inwardId: detail.inwardId,
                      voucherNo: voucherNoCtrl.text.trim(),
                      voucherDate: DateTime.now(),
                      postedDate: DateTime.now(),
                      voucherType: AppConstants.inwardPurchaseDomestic,
                      accountObjectName: supplierCtrl.text.trim(),
                      stockId: selectedStockId,
                      stockName: selectedStockName,
                      journalMemo: memoCtrl.text.trim(),
                      isPosted: true,
                      details: [detail],
                    );

                    widget.inventoryService.addInwardVoucher(newVoucher);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                  child: const Text('Lưu & Ghi Sổ (F9)'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showViewDetailDialog(BuildContext context, InwardVoucherModel voucher) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Chi Tiết Phiếu Nhập: ${voucher.voucherNo}'),
          content: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nhà cung cấp: ${voucher.accountObjectName}'),
                Text('Kho nhập: ${voucher.stockName}'),
                Text('Diễn giải: ${voucher.journalMemo}'),
                const Divider(),
                const Text('Danh sách dòng hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...voucher.details.map((d) {
                  return ListTile(
                    dense: true,
                    title: Text('${d.inventoryItemCode} - ${d.inventoryItemName}'),
                    subtitle: Text('Định khoản: Nợ ${d.debitAccount} / Có ${d.creditAccount}'),
                    trailing: Text('${d.quantity} ${d.unitName} x ${_currencyFormat.format(d.unitPrice)} = ${_currencyFormat.format(d.amount)} đ',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
          ],
        );
      },
    );
  }
}
