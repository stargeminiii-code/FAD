import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/outward_voucher_model.dart';
import '../../services/inventory_service.dart';

class OutwardVoucherScreen extends StatefulWidget {
  final InventoryService inventoryService;

  const OutwardVoucherScreen({super.key, required this.inventoryService});

  @override
  State<OutwardVoucherScreen> createState() => _OutwardVoucherScreenState();
}

class _OutwardVoucherScreenState extends State<OutwardVoucherScreen> {
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final outwards = widget.inventoryService.getOutwards();

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
                    const Icon(Icons.arrow_upward_rounded, color: Color(0xFFD97706), size: 28),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Danh Sách Phiếu Xuất Kho (IN_OUTWARD)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                        Text('Ghi nhận giảm tồn kho & hạch toán Giá vốn Nợ 632/621 Có 152/156/155',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddOutwardDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Lập Phiếu Xuất Kho (F2)'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Outward Table
            Expanded(
              child: Card(
                child: outwards.isEmpty
                    ? const Center(child: Text('Chưa có phiếu xuất kho nào'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                            columns: const [
                              DataColumn(label: Text('Số Phiếu', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Ngày Hạch Toán', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Khách Hàng / Đối Tượng', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Kho Xuất', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Diễn Giải Nghiệp Vụ', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tổng Số Lượng', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Tổng Tiền Giá Vốn', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Tính Giá Vốn', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Trạng Thái Sổ Cái', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Thao Tác', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: outwards.map((voucher) {
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
                                    Text('${_currencyFormat.format(voucher.totalCogsAmount)} đ',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                                  ),
                                  DataCell(
                                    Chip(
                                      label: Text(
                                        voucher.isCalculatedCost ? 'Đã tính giá' : 'Chưa tính giá',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: voucher.isCalculatedCost ? AppTheme.success : AppTheme.warning,
                                        ),
                                      ),
                                      backgroundColor: voucher.isCalculatedCost ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                      side: BorderSide.none,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  DataCell(
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          widget.inventoryService.toggleOutwardPosting(voucher.outwardId);
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

  void _showAddOutwardDialog(BuildContext context) {
    final stocks = widget.inventoryService.getStocks();
    final items = widget.inventoryService.getItems();
    if (items.isEmpty || stocks.isEmpty) return;

    final voucherNoCtrl = TextEditingController(text: 'XK0000${widget.inventoryService.getOutwards().length + 1}');
    final customerCtrl = TextEditingController(text: 'Khách lẻ Shopee');
    final memoCtrl = TextEditingController(text: 'Xuất kho bán hàng thương mại điện tử');
    String selectedStockId = stocks.first.stockId;
    String selectedStockName = stocks.first.stockName;

    // Line item
    String selectedItemId = items.first.inventoryItemId;
    final qtyCtrl = TextEditingController(text: '2');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final chosenItem = items.firstWhere((i) => i.inventoryItemId == selectedItemId);

            return AlertDialog(
              title: const Text('Lập Phiếu Xuất Kho (Chuẩn MISA)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                              decoration: const InputDecoration(labelText: 'Kho xuất *'),
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
                        controller: customerCtrl,
                        decoration: const InputDecoration(labelText: 'Khách hàng / Người nhận *'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: memoCtrl,
                        decoration: const InputDecoration(labelText: 'Diễn giải lý do xuất kho'),
                      ),
                      const SizedBox(height: 20),
                      const Text('Chi Tiết Mặt Hàng Xuất Kho (Line Item)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedItemId,
                        decoration: const InputDecoration(labelText: 'Chọn VTHH *'),
                        items: items.map((i) {
                          return DropdownMenuItem(
                            value: i.inventoryItemId,
                            child: Text('${i.inventoryItemCode} - ${i.inventoryItemName} (Tồn: ${i.onHandQuantity} ${i.unitName})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedItemId = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Số lượng xuất * (Tồn hiện tại: ${chosenItem.onHandQuantity} ${chosenItem.unitName})',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          children: [
                            const Icon(Icons.calculate, size: 16, color: Color(0xFFD97706)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Đơn giá vốn xuất dự kiến: ${_currencyFormat.format(chosenItem.averageCostPrice)} đ/chiếc (Hạch toán: Nợ TK 632 / Có TK 1561)',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
                              ),
                            ),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
                  onPressed: () {
                    final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1.0;

                    final detail = OutwardDetailModel(
                      detailId: const Uuid().v4(),
                      outwardId: const Uuid().v4(),
                      inventoryItemId: chosenItem.inventoryItemId,
                      inventoryItemCode: chosenItem.inventoryItemCode,
                      inventoryItemName: chosenItem.inventoryItemName,
                      unitName: chosenItem.unitName,
                      quantity: qty,
                      costPrice: chosenItem.averageCostPrice,
                      costAmount: qty * chosenItem.averageCostPrice,
                      debitAccount: chosenItem.cogsAccount,
                      creditAccount: chosenItem.inventoryAccount,
                    );

                    final newVoucher = OutwardVoucherModel(
                      outwardId: detail.outwardId,
                      voucherNo: voucherNoCtrl.text.trim(),
                      voucherDate: DateTime.now(),
                      postedDate: DateTime.now(),
                      voucherType: AppConstants.outwardSale,
                      accountObjectName: customerCtrl.text.trim(),
                      stockId: selectedStockId,
                      stockName: selectedStockName,
                      journalMemo: memoCtrl.text.trim(),
                      isPosted: true,
                      isCalculatedCost: true,
                      details: [detail],
                    );

                    widget.inventoryService.addOutwardVoucher(newVoucher);
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

  void _showViewDetailDialog(BuildContext context, OutwardVoucherModel voucher) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Chi Tiết Phiếu Xuất: ${voucher.voucherNo}'),
          content: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Khách hàng: ${voucher.accountObjectName}'),
                Text('Kho xuất: ${voucher.stockName}'),
                Text('Diễn giải: ${voucher.journalMemo}'),
                const Divider(),
                const Text('Danh sách dòng hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...voucher.details.map((d) {
                  return ListTile(
                    dense: true,
                    title: Text('${d.inventoryItemCode} - ${d.inventoryItemName}'),
                    subtitle: Text('Định khoản Giá Vốn: Nợ ${d.debitAccount} / Có ${d.creditAccount}'),
                    trailing: Text(
                      '${d.quantity} ${d.unitName} x ${_currencyFormat.format(d.costPrice)} = ${_currencyFormat.format(d.costAmount)} đ',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                    ),
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
