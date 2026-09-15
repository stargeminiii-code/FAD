import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/inventory_item_model.dart';
import '../../services/inventory_service.dart';

class InventoryItemsScreen extends StatefulWidget {
  final InventoryService inventoryService;

  const InventoryItemsScreen({super.key, required this.inventoryService});

  @override
  State<InventoryItemsScreen> createState() => _InventoryItemsScreenState();
}

class _InventoryItemsScreenState extends State<InventoryItemsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final items = widget.inventoryService.getItems().where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return item.inventoryItemCode.toLowerCase().contains(q) ||
          item.inventoryItemName.toLowerCase().contains(q) ||
          item.categoryName.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search & Action Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm theo Mã SKU, Tên mặt hàng, Nhóm VTHH...',
                          prefixIcon: Icon(Icons.search),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showAddItemDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Thêm VTHH Mới (F2)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Items Table / List
            Expanded(
              child: Card(
                child: items.isEmpty
                    ? const Center(child: Text('Không tìm thấy mặt hàng nào'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 56,
                            columns: const [
                              DataColumn(label: Text('Mã VTHH (SKU)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tên Vật Tư Hàng Hóa', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('ĐVT', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Nhóm VTHH', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tồn Kho', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Giá Vốn BQ', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Giá Trị Tồn', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Giá Bán Chuẩn', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('TK Kho', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Phương Pháp Giá', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: items.map((item) {
                              final isLowStock = item.onHandQuantity <= item.minimumStock;
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      item.inventoryItemCode,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        Text(item.inventoryItemName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        if (isLowStock) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEE2E2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('Sắp hết', style: TextStyle(color: AppTheme.danger, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(item.unitName)),
                                  DataCell(Text(item.categoryName)),
                                  DataCell(
                                    Text(
                                      '${item.onHandQuantity}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isLowStock ? AppTheme.danger : AppTheme.textMain,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text('${_currencyFormat.format(item.averageCostPrice)} đ')),
                                  DataCell(
                                    Text(
                                      '${_currencyFormat.format(item.inventoryAmount)} đ',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  DataCell(Text('${_currencyFormat.format(item.salePrice)} đ')),
                                  DataCell(Text(item.inventoryAccount)),
                                  DataCell(
                                    Chip(
                                      label: Text(
                                        item.costMethod == AppConstants.costMethodMovingAverage
                                            ? 'BQ tức thời'
                                            : item.costMethod == AppConstants.costMethodPeriodicAverage
                                                ? 'BQ cuối kỳ'
                                                : 'FIFO',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      side: BorderSide.none,
                                      backgroundColor: const Color(0xFFEFF6FF),
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

  void _showAddItemDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'Chiếc');
    final categoryCtrl = TextEditingController(text: 'Hàng hóa thông dụng');
    final purchasePriceCtrl = TextEditingController(text: '0');
    final salePriceCtrl = TextEditingController(text: '0');
    final minStockCtrl = TextEditingController(text: '5');
    int costMethod = AppConstants.costMethodMovingAverage;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm Mới Vật Tư Hàng Hóa (Chuẩn MISA)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: codeCtrl,
                              decoration: const InputDecoration(labelText: 'Mã VTHH (SKU) *', hintText: 'vd: SP0001'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: unitCtrl,
                              decoration: const InputDecoration(labelText: 'Đơn vị tính chính *', hintText: 'Chiếc, Hộp, Kg...'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Tên Vật Tư Hàng Hóa *'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: categoryCtrl,
                        decoration: const InputDecoration(labelText: 'Nhóm / Loại VTHH'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: purchasePriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Giá mua ngầm định (VND)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: salePriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Giá bán chuẩn (VND)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minStockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Mức tồn tối thiểu cảnh báo'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: costMethod,
                              decoration: const InputDecoration(labelText: 'Phương pháp tính giá xuất'),
                              items: const [
                                DropdownMenuItem(value: AppConstants.costMethodMovingAverage, child: Text('Bình quân tức thời')),
                                DropdownMenuItem(value: AppConstants.costMethodPeriodicAverage, child: Text('Bình quân cuối kỳ')),
                                DropdownMenuItem(value: AppConstants.costMethodFIFO, child: Text('Nhập trước xuất trước (FIFO)')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    costMethod = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy bỏ')),
                ElevatedButton(
                  onPressed: () {
                    if (codeCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) return;

                    final newItem = InventoryItemModel(
                      inventoryItemId: const Uuid().v4(),
                      inventoryItemCode: codeCtrl.text.trim(),
                      inventoryItemName: nameCtrl.text.trim(),
                      unitName: unitCtrl.text.trim(),
                      categoryName: categoryCtrl.text.trim(),
                      purchasePrice: double.tryParse(purchasePriceCtrl.text.trim()) ?? 0.0,
                      salePrice: double.tryParse(salePriceCtrl.text.trim()) ?? 0.0,
                      minimumStock: double.tryParse(minStockCtrl.text.trim()) ?? 5.0,
                      costMethod: costMethod,
                    );

                    widget.inventoryService.addInventoryItem(newItem);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                  child: const Text('Lưu VTHH'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
