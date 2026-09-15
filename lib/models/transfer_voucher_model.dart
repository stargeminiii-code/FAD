/// Transfer Voucher Detail Item (Dòng chi tiết Phiếu Chuyển Kho)
class TransferDetailModel {
  final String detailId;
  final String transferId;
  final String inventoryItemId;
  final String inventoryItemCode;
  final String inventoryItemName;
  final String unitName;
  final double quantity;
  final double baseQuantity;
  double unitPrice; // Giá xuất chuyển
  double amount;
  final String lotNumber;
  final String? expiryDate;

  TransferDetailModel({
    required this.detailId,
    required this.transferId,
    required this.inventoryItemId,
    required this.inventoryItemCode,
    required this.inventoryItemName,
    required this.unitName,
    required this.quantity,
    double? baseQuantity,
    this.unitPrice = 0.0,
    double? amount,
    this.lotNumber = '',
    this.expiryDate,
  })  : baseQuantity = baseQuantity ?? quantity,
        amount = amount ?? (quantity * unitPrice);

  Map<String, dynamic> toMap() {
    return {
      'detail_id': detailId,
      'transfer_id': transferId,
      'inventory_item_id': inventoryItemId,
      'inventory_item_code': inventoryItemCode,
      'inventory_item_name': inventoryItemName,
      'unit_name': unitName,
      'quantity': quantity,
      'base_quantity': baseQuantity,
      'unit_price': unitPrice,
      'amount': amount,
      'lot_number': lotNumber,
      'expiry_date': expiryDate,
    };
  }

  factory TransferDetailModel.fromMap(Map<String, dynamic> map) {
    return TransferDetailModel(
      detailId: map['detail_id'] ?? '',
      transferId: map['transfer_id'] ?? '',
      inventoryItemId: map['inventory_item_id'] ?? '',
      inventoryItemCode: map['inventory_item_code'] ?? '',
      inventoryItemName: map['inventory_item_name'] ?? '',
      unitName: map['unit_name'] ?? 'Cái',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      baseQuantity: (map['base_quantity'] as num?)?.toDouble(),
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      amount: (map['amount'] as num?)?.toDouble(),
      lotNumber: map['lot_number'] ?? '',
      expiryDate: map['expiry_date'],
    );
  }
}

/// Transfer Voucher Header (Phiếu Điều Chuyển Kho - INTransfer)
class TransferVoucherModel {
  final String transferId;
  final String voucherNo; // vd: CK00001
  final DateTime voucherDate;
  final DateTime postedDate;
  final String fromStockId;
  final String fromStockName;
  final String toStockId;
  final String toStockName;
  final bool isInTransit; // True: qua hàng đi đường TK 157, False: chuyển trực tiếp
  final String transporter; // Người vận chuyển
  final String journalMemo;
  final double totalQuantity;
  final double totalAmount;
  bool isPosted;
  final List<TransferDetailModel> details;

  TransferVoucherModel({
    required this.transferId,
    required this.voucherNo,
    required this.voucherDate,
    required this.postedDate,
    required this.fromStockId,
    required this.fromStockName,
    required this.toStockId,
    required this.toStockName,
    this.isInTransit = false,
    this.transporter = '',
    this.journalMemo = 'Điều chuyển kho nội bộ',
    double? totalQuantity,
    double? totalAmount,
    this.isPosted = true,
    this.details = const [],
  })  : totalQuantity = totalQuantity ?? details.fold(0.0, (sum, item) => sum + item.quantity),
        totalAmount = totalAmount ?? details.fold(0.0, (sum, item) => sum + item.amount);

  Map<String, dynamic> toMap() {
    return {
      'transfer_id': transferId,
      'voucher_no': voucherNo,
      'voucher_date': voucherDate.toIso8601String(),
      'posted_date': postedDate.toIso8601String(),
      'from_stock_id': fromStockId,
      'from_stock_name': fromStockName,
      'to_stock_id': toStockId,
      'to_stock_name': toStockName,
      'is_in_transit': isInTransit,
      'transporter': transporter,
      'journal_memo': journalMemo,
      'total_quantity': totalQuantity,
      'total_amount': totalAmount,
      'is_posted': isPosted,
      'details': details.map((d) => d.toMap()).toList(),
    };
  }

  factory TransferVoucherModel.fromMap(Map<String, dynamic> map) {
    return TransferVoucherModel(
      transferId: map['transfer_id'] ?? '',
      voucherNo: map['voucher_no'] ?? '',
      voucherDate: DateTime.parse(map['voucher_date'] ?? DateTime.now().toIso8601String()),
      postedDate: DateTime.parse(map['posted_date'] ?? DateTime.now().toIso8601String()),
      fromStockId: map['from_stock_id'] ?? '',
      fromStockName: map['from_stock_name'] ?? '',
      toStockId: map['to_stock_id'] ?? '',
      toStockName: map['to_stock_name'] ?? '',
      isInTransit: map['is_in_transit'] ?? false,
      transporter: map['transporter'] ?? '',
      journalMemo: map['journal_memo'] ?? '',
      totalQuantity: (map['total_quantity'] as num?)?.toDouble(),
      totalAmount: (map['total_amount'] as num?)?.toDouble(),
      isPosted: map['is_posted'] ?? true,
      details: (map['details'] as List<dynamic>?)
              ?.map((d) => TransferDetailModel.fromMap(d))
              .toList() ??
          [],
    );
  }
}
