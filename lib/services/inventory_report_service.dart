import '../models/inventory_item_model.dart';
import '../models/inward_voucher_model.dart';
import '../models/outward_voucher_model.dart';

/// Dòng Báo cáo Nhập Xuất Tồn (Mẫu S11-DN)
class InventorySummaryRow {
  final String itemId;
  final String itemCode;
  final String itemName;
  final String unitName;
  final double openingQty;
  final double openingAmount;
  final double inwardQty;
  final double inwardAmount;
  final double outwardQty;
  final double outwardAmount;
  final double closingQty;
  final double closingAmount;

  InventorySummaryRow({
    required this.itemId,
    required this.itemCode,
    required this.itemName,
    required this.unitName,
    required this.openingQty,
    required this.openingAmount,
    required this.inwardQty,
    required this.inwardAmount,
    required this.outwardQty,
    required this.outwardAmount,
    required this.closingQty,
    required this.closingAmount,
  });

  double get averageUnitCost => closingQty > 0 ? closingAmount / closingQty : 0.0;
}

/// Dòng Sổ Chi Tiết Vật Tư Hàng Hóa (Mẫu S10-DN)
class ItemDetailLedgerRow {
  final DateTime date;
  final String voucherNo;
  final String memo;
  final String oppositeAccount; // TK Đối ứng
  final double inwardQty;
  final double inwardUnitPrice;
  final double inwardAmount;
  final double outwardQty;
  final double outwardUnitPrice;
  final double outwardAmount;
  final double balanceQty;
  final double balanceAmount;

  ItemDetailLedgerRow({
    required this.date,
    required this.voucherNo,
    required this.memo,
    this.oppositeAccount = '',
    this.inwardQty = 0.0,
    this.inwardUnitPrice = 0.0,
    this.inwardAmount = 0.0,
    this.outwardQty = 0.0,
    this.outwardUnitPrice = 0.0,
    this.outwardAmount = 0.0,
    required this.balanceQty,
    required this.balanceAmount,
  });
}

/// Inventory Report Service (Hệ Thống Báo Cáo Kho Chuẩn MISA & BTC)
class InventoryReportService {
  /// 1. Bảng Tổng Hợp Nhập - Xuất - Tồn (Mẫu số S11-DN)
  List<InventorySummaryRow> generateInventorySummaryReport({
    required List<InventoryItemModel> items,
    required List<InwardVoucherModel> inwards,
    required List<OutwardVoucherModel> outwards,
    required Map<String, double> openingQuantities,
    required Map<String, double> openingAmounts,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final reportRows = <InventorySummaryRow>[];

    for (final item in items) {
      final itemId = item.inventoryItemId;
      final openingQty = openingQuantities[itemId] ?? 0.0;
      final openingAmt = openingAmounts[itemId] ?? 0.0;

      double inQty = 0.0;
      double inAmt = 0.0;
      double outQty = 0.0;
      double outAmt = 0.0;

      // Tính tổng nhập
      for (final voucher in inwards) {
        if (!voucher.isPosted) continue;
        if (fromDate != null && voucher.postedDate.isBefore(fromDate)) continue;
        if (toDate != null && voucher.postedDate.isAfter(toDate)) continue;

        for (final detail in voucher.details) {
          if (detail.inventoryItemId == itemId) {
            inQty += detail.baseQuantity;
            inAmt += detail.amount;
          }
        }
      }

      // Tính tổng xuất
      for (final voucher in outwards) {
        if (!voucher.isPosted) continue;
        if (fromDate != null && voucher.postedDate.isBefore(fromDate)) continue;
        if (toDate != null && voucher.postedDate.isAfter(toDate)) continue;

        for (final detail in voucher.details) {
          if (detail.inventoryItemId == itemId) {
            outQty += detail.baseQuantity;
            outAmt += detail.costAmount;
          }
        }
      }

      final closeQty = openingQty + inQty - outQty;
      final closeAmt = openingAmt + inAmt - outAmt;

      reportRows.add(
        InventorySummaryRow(
          itemId: itemId,
          itemCode: item.inventoryItemCode,
          itemName: item.inventoryItemName,
          unitName: item.unitName,
          openingQty: openingQty,
          openingAmount: openingAmt,
          inwardQty: inQty,
          inwardAmount: inAmt,
          outwardQty: outQty,
          outwardAmount: outAmt,
          closingQty: closeQty,
          closingAmount: closeAmt,
        ),
      );
    }

    return reportRows;
  }

  /// 2. Sổ Chi Tiết Vật Tư Hàng Hóa (Mẫu số S10-DN)
  List<ItemDetailLedgerRow> generateItemDetailLedger({
    required InventoryItemModel item,
    required List<InwardVoucherModel> inwards,
    required List<OutwardVoucherModel> outwards,
    double openingQty = 0.0,
    double openingAmount = 0.0,
  }) {
    final rows = <ItemDetailLedgerRow>[];

    // Dòng số dư đầu kỳ
    double currentQty = openingQty;
    double currentAmount = openingAmount;

    rows.add(
      ItemDetailLedgerRow(
        date: DateTime(2026, 1, 1),
        voucherNo: 'SODU-DK',
        memo: 'Số dư đầu kỳ',
        balanceQty: currentQty,
        balanceAmount: currentAmount,
      ),
    );

    // Gom tất cả các giao dịch nhập & xuất của mặt hàng này theo thứ tự thời gian
    final transactions = <Map<String, dynamic>>[];

    for (final voucher in inwards) {
      if (!voucher.isPosted) continue;
      for (final d in voucher.details) {
        if (d.inventoryItemId == item.inventoryItemId) {
          transactions.add({
            'date': voucher.postedDate,
            'voucherNo': voucher.voucherNo,
            'memo': voucher.journalMemo,
            'type': 'IN',
            'qty': d.baseQuantity,
            'unitPrice': d.unitPrice,
            'amount': d.amount,
            'oppositeAccount': d.creditAccount,
          });
        }
      }
    }

    for (final voucher in outwards) {
      if (!voucher.isPosted) continue;
      for (final d in voucher.details) {
        if (d.inventoryItemId == item.inventoryItemId) {
          transactions.add({
            'date': voucher.postedDate,
            'voucherNo': voucher.voucherNo,
            'memo': voucher.journalMemo,
            'type': 'OUT',
            'qty': d.baseQuantity,
            'unitPrice': d.costPrice,
            'amount': d.costAmount,
            'oppositeAccount': d.debitAccount,
          });
        }
      }
    }

    // Sắp xếp theo ngày tăng dần
    transactions.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    for (final t in transactions) {
      final isInput = t['type'] == 'IN';
      final qty = t['qty'] as double;
      final amt = t['amount'] as double;
      final price = t['unitPrice'] as double;

      if (isInput) {
        currentQty += qty;
        currentAmount += amt;
        rows.add(
          ItemDetailLedgerRow(
            date: t['date'] as DateTime,
            voucherNo: t['voucherNo'] as String,
            memo: t['memo'] as String,
            oppositeAccount: t['oppositeAccount'] as String,
            inwardQty: qty,
            inwardUnitPrice: price,
            inwardAmount: amt,
            balanceQty: currentQty,
            balanceAmount: currentAmount,
          ),
        );
      } else {
        currentQty -= qty;
        currentAmount -= amt;
        rows.add(
          ItemDetailLedgerRow(
            date: t['date'] as DateTime,
            voucherNo: t['voucherNo'] as String,
            memo: t['memo'] as String,
            oppositeAccount: t['oppositeAccount'] as String,
            outwardQty: qty,
            outwardUnitPrice: price,
            outwardAmount: amt,
            balanceQty: currentQty,
            balanceAmount: currentAmount,
          ),
        );
      }
    }

    return rows;
  }

  /// 3. Cảnh Báo Hàng Tồn Dưới Mức Tối Thiểu
  List<InventoryItemModel> getLowStockAlerts(List<InventoryItemModel> items) {
    return items.where((item) => item.onHandQuantity <= item.minimumStock).toList();
  }
}
