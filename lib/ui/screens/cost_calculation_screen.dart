import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/cost_calculation_service.dart';
import '../../services/inventory_service.dart';

class CostCalculationScreen extends StatefulWidget {
  final InventoryService inventoryService;

  const CostCalculationScreen({super.key, required this.inventoryService});

  @override
  State<CostCalculationScreen> createState() => _CostCalculationScreenState();
}

class _CostCalculationScreenState extends State<CostCalculationScreen> {
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  int _selectedMethod = AppConstants.costMethodPeriodicAverage;
  String _selectedPeriod = 'Tháng 08/2026';
  bool _isProcessing = false;
  CostCalculationResult? _lastResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calculate_rounded, color: Color(0xFF4F46E5), size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tính Giá Xuất Kho Kỳ Kế Toán (IN_CALCULATE_PRICE)',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tự động tính đơn giá bình quân gia quyền & áp ngược lại toàn bộ Phiếu Xuất Kho, đồng bộ Sổ Cái Nợ 632 / Có 156',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Calculation Options Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tham Số Kỳ Tính Giá', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPeriod,
                            decoration: const InputDecoration(labelText: 'Kỳ kế toán *'),
                            items: const [
                              DropdownMenuItem(value: 'Tháng 07/2026', child: Text('Tháng 07/2026')),
                              DropdownMenuItem(value: 'Tháng 08/2026', child: Text('Tháng 08/2026')),
                              DropdownMenuItem(value: 'Tháng 09/2026', child: Text('Tháng 09/2026')),
                              DropdownMenuItem(value: 'Quý 3/2026', child: Text('Quý 3/2026')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedPeriod = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedMethod,
                            decoration: const InputDecoration(labelText: 'Phương pháp tính giá *'),
                            items: const [
                              DropdownMenuItem(
                                value: AppConstants.costMethodPeriodicAverage,
                                child: Text('Bình quân gia quyền cuối kỳ (Chuẩn MISA)'),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.costMethodMovingAverage,
                                child: Text('Bình quân gia quyền tức thời (Moving Average)'),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.costMethodFIFO,
                                child: Text('Nhập trước xuất trước (FIFO)'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedMethod = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Explanation container
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Công thức áp dụng theo Thông tư 200 & 133:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Đơn giá BQ tháng = (Giá trị tồn đầu kỳ + Tổng giá trị nhập trong kỳ) / (Số lượng tồn đầu kỳ + Tổng số lượng nhập trong kỳ)',
                            style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Sau khi tính, tất cả các phiếu xuất kho trong kỳ sẽ được tự động điền đơn giá vốn và cập nhật bút toán Nợ 632 / Có 156 trên Sổ Cái.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _runCalculation,
                        icon: _isProcessing
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.play_arrow_rounded, size: 20),
                        label: Text(_isProcessing ? 'Đang Tính Giá...' : 'Thực Hiện Tính Giá Xuất Kho'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Calculation Results
            if (_lastResult != null) ...[
              Card(
                color: const Color(0xFFF0FDF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFBBF7D0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppTheme.success, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Hoàn Tất Tính Giá Xuất Kho Thành Công!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildResultItem('Số mặt hàng đã tính giá:', '${_lastResult!.updatedItemsCount} VTHH'),
                          _buildResultItem('Số phiếu xuất đã cập nhật:', '${_lastResult!.updatedVouchersCount} phiếu'),
                          _buildResultItem('Tổng giá vốn đã ghi nhận:', '${_currencyFormat.format(_lastResult!.totalCogsCalculated)} đ'),
                        ],
                      ),
                      if (_lastResult!.warnings.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Divider(),
                        const Text('Cảnh báo & Ghi chú:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warning)),
                        ..._lastResult!.warnings.map((w) => Text('• $w', style: const TextStyle(fontSize: 12, color: Colors.black87))),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF15803D))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
        ],
      ),
    );
  }

  void _runCalculation() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Smooth simulation
    final result = widget.inventoryService.runPeriodicCostCalculation();
    setState(() {
      _lastResult = result;
      _isProcessing = false;
    });
  }
}
