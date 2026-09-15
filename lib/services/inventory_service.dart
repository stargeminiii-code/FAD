import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../database/local_database.dart';
import '../models/stock_model.dart';
import '../models/inventory_item_model.dart';
import '../models/inward_voucher_model.dart';
import '../models/outward_voucher_model.dart';
import '../models/transfer_voucher_model.dart';
import '../models/audit_voucher_model.dart';
import 'accounting_posting_service.dart';
import 'cost_calculation_service.dart';

/// Inventory Service (Điều phối toàn bộ Nghiệp vụ Phân hệ Kho)
class InventoryService {
  final LocalDatabase _db = LocalDatabase();
  final AccountingPostingService _postingService = AccountingPostingService();
  final CostCalculationService _costService = CostCalculationService();
  final Uuid _uuid = const Uuid();

  LocalDatabase get db => _db;

  // 1. Quản lý Danh mục Kho & VTHH
  List<StockModel> getStocks() => _db.stocks;
  List<InventoryItemModel> getItems() => _db.items;

  void addInventoryItem(InventoryItemModel item) {
    _db.items.add(item);
    _db.refreshBalances();
  }

  void updateInventoryItem(InventoryItemModel updatedItem) {
    final idx = _db.items.indexWhere((i) => i.inventoryItemId == updatedItem.inventoryItemId);
    if (idx != -1) {
      _db.items[idx] = updatedItem;
      _db.refreshBalances();
    }
  }

  // 2. Nghiệp vụ Nhập Kho
  List<InwardVoucherModel> getInwards() => _db.inwards;

  void addInwardVoucher(InwardVoucherModel voucher) {
    _db.inwards.insert(0, voucher);
    if (voucher.isPosted) {
      final postings = _postingService.generateInwardPostings(voucher);
      _db.glPostings.addAll(postings);
    }
    _db.refreshBalances();
  }

  void toggleInwardPosting(String inwardId) {
    final v = _db.inwards.firstWhere((i) => i.inwardId == inwardId);
    v.isPosted = !v.isPosted;
    // Đồng bộ Sổ Cái
    _db.glPostings.removeWhere((p) => p.voucherId == inwardId);
    if (v.isPosted) {
      _db.glPostings.addAll(_postingService.generateInwardPostings(v));
    }
    _db.refreshBalances();
  }

  // 3. Nghiệp vụ Xuất Kho
  List<OutwardVoucherModel> getOutwards() => _db.outwards;

  void addOutwardVoucher(OutwardVoucherModel voucher) {
    // Tự động tính giá vốn theo Moving Average nếu chưa tính
    if (!voucher.isCalculatedCost) {
      for (final detail in voucher.details) {
        final item = _db.items.firstWhere((i) => i.inventoryItemId == detail.inventoryItemId);
        final unitCost = _costService.calculateMovingAverageCost(
          item: item,
          currentStockQty: item.onHandQuantity,
          currentStockAmount: item.inventoryAmount,
          outwardQty: detail.baseQuantity,
        );
        detail.costPrice = unitCost;
        detail.costAmount = detail.quantity * unitCost;
      }
      voucher.totalCogsAmount = voucher.details.fold(0.0, (s, d) => s + d.costAmount);
      voucher.isCalculatedCost = true;
    }

    _db.outwards.insert(0, voucher);
    if (voucher.isPosted) {
      final postings = _postingService.generateOutwardPostings(voucher);
      _db.glPostings.addAll(postings);
    }
    _db.refreshBalances();
  }

  void toggleOutwardPosting(String outwardId) {
    final v = _db.outwards.firstWhere((i) => i.outwardId == outwardId);
    v.isPosted = !v.isPosted;
    _db.glPostings.removeWhere((p) => p.voucherId == outwardId);
    if (v.isPosted) {
      _db.glPostings.addAll(_postingService.generateOutwardPostings(v));
    }
    _db.refreshBalances();
  }

  // 4. Nghiệp vụ Điều Chuyển Kho
  List<TransferVoucherModel> getTransfers() => _db.transfers;

  void addTransferVoucher(TransferVoucherModel voucher) {
    _db.transfers.insert(0, voucher);
    if (voucher.isPosted) {
      _db.glPostings.addAll(_postingService.generateTransferPostings(voucher));
    }
    _db.refreshBalances();
  }

  // 5. Nghiệp vụ Kiểm Kê Kho
  List<AuditVoucherModel> getAudits() => _db.audits;

  void addAuditVoucher(AuditVoucherModel voucher) {
    _db.audits.insert(0, voucher);
  }

  /// Xử lý chênh lệch kiểm kê: Tự sinh Phiếu Nhập thừa (NK) hoặc Xuất thiếu (XK)
  void handleAuditDiscrepancies(AuditVoucherModel audit) {
    if (audit.isHandled) return;

    final surplusDetails = <InwardDetailModel>[];
    final deficitDetails = <OutwardDetailModel>[];

    for (final detail in audit.details) {
      if (detail.diffQuantity > 0) {
        // Hàng thừa: Sinh dòng nhập kho thừa
        surplusDetails.add(
          InwardDetailModel(
            detailId: _uuid.v4(),
            inwardId: 'surplus_${audit.auditId}',
            inventoryItemId: detail.inventoryItemId,
            inventoryItemCode: detail.inventoryItemCode,
            inventoryItemName: detail.inventoryItemName,
            unitName: detail.unitName,
            quantity: detail.diffQuantity,
            unitPrice: detail.costPrice,
            debitAccount: AppConstants.accMerchandise,
            creditAccount: AppConstants.accSurplusSuspense, // TK 3381
          ),
        );
      } else if (detail.diffQuantity < 0) {
        // Hàng thiếu: Sinh dòng xuất kho hao hụt / mất mát
        final absQty = detail.diffQuantity.abs();
        deficitDetails.add(
          OutwardDetailModel(
            detailId: _uuid.v4(),
            outwardId: 'deficit_${audit.auditId}',
            inventoryItemId: detail.inventoryItemId,
            inventoryItemCode: detail.inventoryItemCode,
            inventoryItemName: detail.inventoryItemName,
            unitName: detail.unitName,
            quantity: absQty,
            costPrice: detail.costPrice,
            debitAccount: AppConstants.accClaimSuspense, // TK 1381
            creditAccount: AppConstants.accMerchandise,
          ),
        );
      }
    }

    if (surplusDetails.isNotEmpty) {
      final surplusVoucher = InwardVoucherModel(
        inwardId: 'surplus_${audit.auditId}',
        voucherNo: 'NK-THUA-${audit.voucherNo}',
        voucherDate: DateTime.now(),
        postedDate: DateTime.now(),
        voucherType: AppConstants.inwardSurplusAudit,
        stockId: audit.stockId,
        stockName: audit.stockName,
        journalMemo: 'Nhập kho hàng thừa sau kiểm kê ${audit.voucherNo}',
        isPosted: true,
        details: surplusDetails,
      );
      addInwardVoucher(surplusVoucher);
    }

    if (deficitDetails.isNotEmpty) {
      final deficitVoucher = OutwardVoucherModel(
        outwardId: 'deficit_${audit.auditId}',
        voucherNo: 'XK-THIEU-${audit.voucherNo}',
        voucherDate: DateTime.now(),
        postedDate: DateTime.now(),
        voucherType: AppConstants.outwardDeficitAudit,
        stockId: audit.stockId,
        stockName: audit.stockName,
        journalMemo: 'Xuất kho hàng thiếu sau kiểm kê ${audit.voucherNo}',
        isCalculatedCost: true,
        isPosted: true,
        details: deficitDetails,
      );
      addOutwardVoucher(deficitVoucher);
    }

    audit.isHandled = true;
    _db.refreshBalances();
  }

  // 6. Chạy Tính Giá Xuất Kho Kỳ Kế Toán
  CostCalculationResult runPeriodicCostCalculation() {
    final result = _costService.calculateMonthlyPeriodicAverage(
      items: _db.items,
      periodInwards: _db.inwards,
      periodOutwards: _db.outwards,
      openingQuantities: _db.openingQuantities,
      openingAmounts: _db.openingAmounts,
    );

    // Cập nhật lại toàn bộ Sổ Cái cho các phiếu xuất kho đã tính lại giá
    _db.glPostings.removeWhere((p) => p.voucherType == 'IN_OUTWARD');
    for (final outward in _db.outwards) {
      if (outward.isPosted) {
        _db.glPostings.addAll(_postingService.generateOutwardPostings(outward));
      }
    }

    _db.refreshBalances();
    return result;
  }
}
