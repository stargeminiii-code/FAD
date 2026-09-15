import '../core/constants.dart';

/// Outward Voucher Detail Item (Dòng chi tiết Phiếu Xuất Kho)
class OutwardDetailModel {
  final String detailId;
  final String outwardId;
  final String inventoryItemId;
  final String inventoryItemCode;
  final String inventoryItemName;
  final String unitName;
  final double quantity;
  final double baseQuantity;
  double costPrice; // Đơn giá vốn xuất kho (tính theo Moving Average / FIFO / Periodic)
  double costAmount; // quantity * costPrice
  final double salePrice; // Đơn giá bán nếu kiêm hóa đơn
  final double saleAmount; // quantity * salePrice
  final String debitAccount; // TK Nợ: 632, 621, 242, 331, 1381
  final String creditAccount; // TK Có: 1561, 152, 155
  final String lotNumber;
  final String? expiryDate;
  final int sortOrder;

  OutwardDetailModel({
    required this.detailId,
    required this.outwardId,
    required this.inventoryItemId,
    required this.inventoryItemCode,
    required this.inventoryItemName,
    required this.unitName,
    required this.quantity,
    double? baseQuantity,
    this.costPrice = 0.0,
    double? costAmount,
    this.salePrice = 0.0,
    double? saleAmount,
    this.debitAccount = AppConstants.accCOGS,
    this.creditAccount = AppConstants.accMerchandise,
    this.lotNumber = '',
    this.expiryDate,
    this.sortOrder = 1,
  })  : baseQuantity = baseQuantity ?? quantity,
        costAmount = costAmount ?? (quantity * costPrice),
        saleAmount = saleAmount ?? (quantity * salePrice);

  Map<String, dynamic> toMap() {
    return {
      'detail_id': detailId,
      'outward_id': outwardId,
      'inventory_item_id': inventoryItemId,
      'inventory_item_code': inventoryItemCode,
      'inventory_item_name': inventoryItemName,
      'unit_name': unitName,
      'quantity': quantity,
      'base_quantity': baseQuantity,
      'cost_price': costPrice,
      'cost_amount': costAmount,
      'sale_price': salePrice,
      'sale_amount': saleAmount,
      'debit_account': debitAccount,
      'credit_account': creditAccount,
      'lot_number': lotNumber,
      'expiry_date': expiryDate,
      'sort_order': sortOrder,
    };
  }

  factory OutwardDetailModel.fromMap(Map<String, dynamic> map) {
    return OutwardDetailModel(
      detailId: map['detail_id'] ?? '',
      outwardId: map['outward_id'] ?? '',
      inventoryItemId: map['inventory_item_id'] ?? '',
      inventoryItemCode: map['inventory_item_code'] ?? '',
      inventoryItemName: map['inventory_item_name'] ?? '',
      unitName: map['unit_name'] ?? 'Cái',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      baseQuantity: (map['base_quantity'] as num?)?.toDouble(),
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      costAmount: (map['cost_amount'] as num?)?.toDouble(),
      salePrice: (map['sale_price'] as num?)?.toDouble() ?? 0.0,
      saleAmount: (map['sale_amount'] as num?)?.toDouble(),
      debitAccount: map['debit_account'] ?? AppConstants.accCOGS,
      creditAccount: map['credit_account'] ?? AppConstants.accMerchandise,
      lotNumber: map['lot_number'] ?? '',
      expiryDate: map['expiry_date'],
      sortOrder: map['sort_order'] ?? 1,
    );
  }
}

/// Outward Voucher Header (Phiếu Xuất Kho)
class OutwardVoucherModel {
  final String outwardId;
  final String voucherNo; // vd: XK00001
  final DateTime voucherDate;
  final DateTime postedDate;
  final int voucherType; // 1: Bán hàng, 2: Sản xuất, 3: Trả NCC, 4: Chuyển kho, 6: Thiếu kiểm kê
  final String accountObjectId; // Khách hàng, NCC, Người nhận
  final String accountObjectName;
  final String receiver;
  final String stockId;
  final String stockName;
  final String journalMemo;
  final double totalQuantity;
  double totalCogsAmount;
  bool isCalculatedCost;
  bool isPosted;
  final List<OutwardDetailModel> details;

  OutwardVoucherModel({
    required this.outwardId,
    required this.voucherNo,
    required this.voucherDate,
    required this.postedDate,
    this.voucherType = AppConstants.outwardSale,
    this.accountObjectId = '',
    this.accountObjectName = '',
    this.receiver = '',
    required this.stockId,
    required this.stockName,
    this.journalMemo = 'Xuất kho bán hàng',
    double? totalQuantity,
    double? totalCogsAmount,
    this.isCalculatedCost = false,
    this.isPosted = true,
    this.details = const [],
  })  : totalQuantity = totalQuantity ?? details.fold(0.0, (sum, item) => sum + item.quantity),
        totalCogsAmount = totalCogsAmount ?? details.fold(0.0, (sum, item) => sum + item.costAmount);

  Map<String, dynamic> toMap() {
    return {
      'outward_id': outwardId,
      'voucher_no': voucherNo,
      'voucher_date': voucherDate.toIso8601String(),
      'posted_date': postedDate.toIso8601String(),
      'voucher_type': voucherType,
      'account_object_id': accountObjectId,
      'account_object_name': accountObjectName,
      'receiver': receiver,
      'stock_id': stockId,
      'stock_name': stockName,
      'journal_memo': journalMemo,
      'total_quantity': totalQuantity,
      'total_cogs_amount': totalCogsAmount,
      'is_calculated_cost': isCalculatedCost,
      'is_posted': isPosted,
      'details': details.map((d) => d.toMap()).toList(),
    };
  }

  factory OutwardVoucherModel.fromMap(Map<String, dynamic> map) {
    return OutwardVoucherModel(
      outwardId: map['outward_id'] ?? '',
      voucherNo: map['voucher_no'] ?? '',
      voucherDate: DateTime.parse(map['voucher_date'] ?? DateTime.now().toIso8601String()),
      postedDate: DateTime.parse(map['posted_date'] ?? DateTime.now().toIso8601String()),
      voucherType: map['voucher_type'] ?? AppConstants.outwardSale,
      accountObjectId: map['account_object_id'] ?? '',
      accountObjectName: map['account_object_name'] ?? '',
      receiver: map['receiver'] ?? '',
      stockId: map['stock_id'] ?? '',
      stockName: map['stock_name'] ?? '',
      journalMemo: map['journal_memo'] ?? '',
      totalQuantity: (map['total_quantity'] as num?)?.toDouble(),
      totalCogsAmount: (map['total_cogs_amount'] as num?)?.toDouble(),
      isCalculatedCost: map['is_calculated_cost'] ?? false,
      isPosted: map['is_posted'] ?? true,
      details: (map['details'] as List<dynamic>?)
              ?.map((d) => OutwardDetailModel.fromMap(d))
              .toList() ??
          [],
    );
  }
}
