import '../core/constants.dart';
import '../models/inventory_item_model.dart';
import '../models/inward_voucher_model.dart';
import '../models/outward_voucher_model.dart';

/// Calculation Result for Cost Calculation Engine
class CostCalculationResult {
  final int updatedVouchersCount;
  final int updatedItemsCount;
  final double totalCogsCalculated;
  final List<String> warnings;

  CostCalculationResult({
    required this.updatedVouchersCount,
    required this.updatedItemsCount,
    required this.totalCogsCalculated,
    this.warnings = const [],
  });
}

/// Inventory Cost Calculation Service (Tính Giá Xuất Kho Chuẩn MISA)
class CostCalculationService {
  /// 1. Phương pháp Bình Quân Gia Quyền Tức Thời (Moving Average)
  /// Tính đơn giá xuất kho ngay tại thời điểm xuất dựa trên tồn kho trước xuất
  double calculateMovingAverageCost({
    required InventoryItemModel item,
    required double currentStockQty,
    required double currentStockAmount,
    required double outwardQty,
  }) {
    if (currentStockQty <= 0) {
      // Trường hợp xuất âm kho hoặc hết tồn, tạm lấy giá mua gần nhất
      return item.purchasePrice > 0 ? item.purchasePrice : 0.0;
    }
    final unitCost = currentStockAmount / currentStockQty;
    return unitCost > 0 ? unitCost : item.purchasePrice;
  }

  /// 2. Phương pháp Bình Quân Gia Quyền Cuối Kỳ (Monthly Periodic Average)
  /// Đơn giá BQ = (Tồn ĐK tiền + Tổng nhập kỳ tiền) / (Tồn ĐK lượng + Tổng nhập kỳ lượng)
  CostCalculationResult calculateMonthlyPeriodicAverage({
    required List<InventoryItemModel> items,
    required List<InwardVoucherModel> periodInwards,
    required List<OutwardVoucherModel> periodOutwards,
    required Map<String, double> openingQuantities,
    required Map<String, double> openingAmounts,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final warnings = <String>[];
    int updatedVouchers = 0;
    int updatedItems = 0;
    double totalCogs = 0.0;

    // Tính đơn giá bình quân cho từng mặt hàng trong kỳ
    final Map<String, double> unitCostMap = {};

    for (final item in items) {
      final itemId = item.inventoryItemId;
      final openingQty = openingQuantities[itemId] ?? 0.0;
      final openingAmt = openingAmounts[itemId] ?? 0.0;

      // Tổng nhập trong kỳ của mặt hàng
      double periodInwardQty = 0.0;
      double periodInwardAmt = 0.0;

      for (final inward in periodInwards) {
        if (!inward.isPosted) continue;
        for (final d in inward.details) {
          if (d.inventoryItemId == itemId) {
            periodInwardQty += d.baseQuantity;
            periodInwardAmt += d.amount;
          }
        }
      }

      final totalAvailableQty = openingQty + periodInwardQty;
      final totalAvailableAmt = openingAmt + periodInwardAmt;

      double unitCost = 0.0;
      if (totalAvailableQty > 0) {
        unitCost = totalAvailableAmt / totalAvailableQty;
      } else {
        unitCost = item.purchasePrice;
        if (periodOutwards.any((v) => v.details.any((d) => d.inventoryItemId == itemId))) {
          warnings.add('VTHH "${item.inventoryItemName}" không có tồn đầu kỳ và không có nhập trong kỳ. Áp dụng giá mua gần nhất ($unitCost VND).');
        }
      }

      unitCostMap[itemId] = unitCost;
    }

    // Cập nhật lại đơn giá vốn và thành tiền cho tất cả phiếu xuất kho trong kỳ
    for (final outward in periodOutwards) {
      if (!outward.isPosted) continue;
      bool voucherChanged = false;
      double voucherCogs = 0.0;

      for (final detail in outward.details) {
        final unitCost = unitCostMap[detail.inventoryItemId] ?? detail.costPrice;
        detail.costPrice = unitCost;
        detail.costAmount = detail.quantity * unitCost;
        voucherCogs += detail.costAmount;
        voucherChanged = true;
      }

      if (voucherChanged) {
        outward.totalCogsAmount = voucherCogs;
        outward.isCalculatedCost = true;
        updatedVouchers++;
        totalCogs += voucherCogs;
      }
    }

    updatedItems = unitCostMap.length;

    return CostCalculationResult(
      updatedVouchersCount: updatedVouchers,
      updatedItemsCount: updatedItems,
      totalCogsCalculated: totalCogs,
      warnings: warnings,
    );
  }

  /// 3. Phương pháp Nhập Trước Xuất Trước (FIFO)
  /// Xuất lần lượt theo các tầng nhập kho cũ nhất
  double calculateFIFOCost({
    required String itemId,
    required double requestQty,
    required List<InwardDetailModel> sortedAvailableInwardBatches,
  }) {
    if (sortedAvailableInwardBatches.isEmpty) return 0.0;

    double remainingQtyToCost = requestQty;
    double totalCostAmount = 0.0;

    for (final batch in sortedAvailableInwardBatches) {
      if (batch.inventoryItemId != itemId) continue;
      if (remainingQtyToCost <= 0) break;

      final takeQty = batch.quantity >= remainingQtyToCost ? remainingQtyToCost : batch.quantity;
      totalCostAmount += takeQty * batch.unitPrice;
      remainingQtyToCost -= takeQty;
    }

    return requestQty > 0 ? totalCostAmount / requestQty : 0.0;
  }
}
