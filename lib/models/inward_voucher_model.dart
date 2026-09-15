import '../core/constants.dart';

/// Inward Voucher Detail Item (Dòng chi tiết Phiếu Nhập Kho)
class InwardDetailModel {
  final String detailId;
  final String inwardId;
  final String inventoryItemId;
  final String inventoryItemCode;
  final String inventoryItemName;
  final String unitName;
  final double quantity;
  final double baseQuantity;
  final double unitPrice;
  final double amount; // quantity * unitPrice
  final double vatRate;
  final double vatAmount;
  final String debitAccount; // TK Nợ: 1561, 152, 155
  final String creditAccount; // TK Có: 331, 1111, 1121, 154, 711
  final String lotNumber;
  final String? expiryDate;
  final int sortOrder;

  InwardDetailModel({
    required this.detailId,
    required this.inwardId,
    required this.inventoryItemId,
    required this.inventoryItemCode,
    required this.inventoryItemName,
    required this.unitName,
    required this.quantity,
    double? baseQuantity,
    required this.unitPrice,
    double? amount,
    this.vatRate = 0.0,
    double? vatAmount,
    this.debitAccount = AppConstants.accMerchandise,
    this.creditAccount = AppConstants.accAP,
    this.lotNumber = '',
    this.expiryDate,
    this.sortOrder = 1,
  })  : baseQuantity = baseQuantity ?? quantity,
        amount = amount ?? (quantity * unitPrice),
        vatAmount = vatAmount ?? ((quantity * unitPrice) * (vatRate / 100.0));

  Map<String, dynamic> toMap() {
    return {
      'detail_id': detailId,
      'inward_id': inwardId,
      'inventory_item_id': inventoryItemId,
      'inventory_item_code': inventoryItemCode,
      'inventory_item_name': inventoryItemName,
      'unit_name': unitName,
      'quantity': quantity,
      'base_quantity': baseQuantity,
      'unit_price': unitPrice,
      'amount': amount,
      'vat_rate': vatRate,
      'vat_amount': vatAmount,
      'debit_account': debitAccount,
      'credit_account': creditAccount,
      'lot_number': lotNumber,
      'expiry_date': expiryDate,
      'sort_order': sortOrder,
    };
  }

  factory InwardDetailModel.fromMap(Map<String, dynamic> map) {
    return InwardDetailModel(
      detailId: map['detail_id'] ?? '',
      inwardId: map['inward_id'] ?? '',
      inventoryItemId: map['inventory_item_id'] ?? '',
      inventoryItemCode: map['inventory_item_code'] ?? '',
      inventoryItemName: map['inventory_item_name'] ?? '',
      unitName: map['unit_name'] ?? 'Cái',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      baseQuantity: (map['base_quantity'] as num?)?.toDouble(),
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      amount: (map['amount'] as num?)?.toDouble(),
      vatRate: (map['vat_rate'] as num?)?.toDouble() ?? 0.0,
      vatAmount: (map['vat_amount'] as num?)?.toDouble(),
      debitAccount: map['debit_account'] ?? AppConstants.accMerchandise,
      creditAccount: map['credit_account'] ?? AppConstants.accAP,
      lotNumber: map['lot_number'] ?? '',
      expiryDate: map['expiry_date'],
      sortOrder: map['sort_order'] ?? 1,
    );
  }
}

/// Inward Voucher Header (Phiếu Nhập Kho)
class InwardVoucherModel {
  final String inwardId;
  final String voucherNo; // vd: NK00001
  final DateTime voucherDate;
  final DateTime postedDate;
  final int voucherType; // 1: Mua trong nước, 2: Nhập khẩu, 3: Sản xuất, 4: Trả lại, 6: Thừa kiểm kê
  final String accountObjectId; // NCC, Khách hàng, Nhân viên
  final String accountObjectName;
  final String deliverer;
  final String stockId;
  final String stockName;
  final String journalMemo;
  final double totalQuantity;
  final double totalAmount;
  final double totalVatAmount;
  bool isPosted;
  final List<InwardDetailModel> details;

  InwardVoucherModel({
    required this.inwardId,
    required this.voucherNo,
    required this.voucherDate,
    required this.postedDate,
    this.voucherType = AppConstants.inwardPurchaseDomestic,
    this.accountObjectId = '',
    this.accountObjectName = '',
    this.deliverer = '',
    required this.stockId,
    required this.stockName,
    this.journalMemo = 'Nhập kho mua hàng',
    double? totalQuantity,
    double? totalAmount,
    double? totalVatAmount,
    this.isPosted = true,
    this.details = const [],
  })  : totalQuantity = totalQuantity ?? details.fold(0.0, (sum, item) => sum + item.quantity),
        totalAmount = totalAmount ?? details.fold(0.0, (sum, item) => sum + item.amount),
        totalVatAmount = totalVatAmount ?? details.fold(0.0, (sum, item) => sum + item.vatAmount);

  Map<String, dynamic> toMap() {
    return {
      'inward_id': inwardId,
      'voucher_no': voucherNo,
      'voucher_date': voucherDate.toIso8601String(),
      'posted_date': postedDate.toIso8601String(),
      'voucher_type': voucherType,
      'account_object_id': accountObjectId,
      'account_object_name': accountObjectName,
      'deliverer': deliverer,
      'stock_id': stockId,
      'stock_name': stockName,
      'journal_memo': journalMemo,
      'total_quantity': totalQuantity,
      'total_amount': totalAmount,
      'total_vat_amount': totalVatAmount,
      'is_posted': isPosted,
      'details': details.map((d) => d.toMap()).toList(),
    };
  }

  factory InwardVoucherModel.fromMap(Map<String, dynamic> map) {
    return InwardVoucherModel(
      inwardId: map['inward_id'] ?? '',
      voucherNo: map['voucher_no'] ?? '',
      voucherDate: DateTime.parse(map['voucher_date'] ?? DateTime.now().toIso8601String()),
      postedDate: DateTime.parse(map['posted_date'] ?? DateTime.now().toIso8601String()),
      voucherType: map['voucher_type'] ?? AppConstants.inwardPurchaseDomestic,
      accountObjectId: map['account_object_id'] ?? '',
      accountObjectName: map['account_object_name'] ?? '',
      deliverer: map['deliverer'] ?? '',
      stockId: map['stock_id'] ?? '',
      stockName: map['stock_name'] ?? '',
      journalMemo: map['journal_memo'] ?? '',
      totalQuantity: (map['total_quantity'] as num?)?.toDouble(),
      totalAmount: (map['total_amount'] as num?)?.toDouble(),
      totalVatAmount: (map['total_vat_amount'] as num?)?.toDouble(),
      isPosted: map['is_posted'] ?? true,
      details: (map['details'] as List<dynamic>?)
              ?.map((d) => InwardDetailModel.fromMap(d))
              .toList() ??
          [],
    );
  }
}
