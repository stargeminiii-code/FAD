/// Inventory Audit Detail Item (Dòng chi tiết Kiểm kê kho)
class AuditDetailModel {
  final String detailId;
  final String auditId;
  final String inventoryItemId;
  final String inventoryItemCode;
  final String inventoryItemName;
  final String unitName;
  final double bookQuantity; // Số lượng tồn trên sổ sách
  double actualQuantity; // Số lượng kiểm kê thực tế
  double diffQuantity; // actual - book (Dương = Thừa, Âm = Thiếu)
  final double costPrice;
  double diffAmount; // diffQuantity * costPrice
  String diffReason; // Nguyên nhân thừa/thiếu
  int handleSolution; // 1: Chờ xử lý TK 1381/3381, 2: Xử lý ngay tạo phiếu nhập/xuất

  AuditDetailModel({
    required this.detailId,
    required this.auditId,
    required this.inventoryItemId,
    required this.inventoryItemCode,
    required this.inventoryItemName,
    required this.unitName,
    required this.bookQuantity,
    required this.actualQuantity,
    double? diffQuantity,
    this.costPrice = 0.0,
    double? diffAmount,
    this.diffReason = '',
    this.handleSolution = 1,
  })  : diffQuantity = diffQuantity ?? (actualQuantity - bookQuantity),
        diffAmount = diffAmount ?? ((actualQuantity - bookQuantity) * costPrice);

  void updateActualQuantity(double newActual) {
    actualQuantity = newActual;
    diffQuantity = actualQuantity - bookQuantity;
    diffAmount = diffQuantity * costPrice;
  }

  Map<String, dynamic> toMap() {
    return {
      'detail_id': detailId,
      'audit_id': auditId,
      'inventory_item_id': inventoryItemId,
      'inventory_item_code': inventoryItemCode,
      'inventory_item_name': inventoryItemName,
      'unit_name': unitName,
      'book_quantity': bookQuantity,
      'actual_quantity': actualQuantity,
      'diff_quantity': diffQuantity,
      'cost_price': costPrice,
      'diff_amount': diffAmount,
      'diff_reason': diffReason,
      'handle_solution': handleSolution,
    };
  }

  factory AuditDetailModel.fromMap(Map<String, dynamic> map) {
    return AuditDetailModel(
      detailId: map['detail_id'] ?? '',
      auditId: map['audit_id'] ?? '',
      inventoryItemId: map['inventory_item_id'] ?? '',
      inventoryItemCode: map['inventory_item_code'] ?? '',
      inventoryItemName: map['inventory_item_name'] ?? '',
      unitName: map['unit_name'] ?? 'Cái',
      bookQuantity: (map['book_quantity'] as num?)?.toDouble() ?? 0.0,
      actualQuantity: (map['actual_quantity'] as num?)?.toDouble() ?? 0.0,
      diffQuantity: (map['diff_quantity'] as num?)?.toDouble(),
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      diffAmount: (map['diff_amount'] as num?)?.toDouble(),
      diffReason: map['diff_reason'] ?? '',
      handleSolution: map['handle_solution'] ?? 1,
    );
  }
}

/// Inventory Audit Voucher Header (Biên bản kiểm kê kho - INAuditward)
class AuditVoucherModel {
  final String auditId;
  final String voucherNo; // vd: KK00001
  final DateTime auditDate;
  final String stockId;
  final String stockName;
  final String leaderName; // Trưởng ban kiểm kê
  final String accountantName; // Kế toán kho
  final String keeperName; // Thủ kho
  final String journalMemo;
  bool isHandled; // Đã xử lý chênh lệch kiểm kê hay chưa
  final List<AuditDetailModel> details;

  AuditVoucherModel({
    required this.auditId,
    required this.voucherNo,
    required this.auditDate,
    required this.stockId,
    required this.stockName,
    this.leaderName = '',
    this.accountantName = '',
    this.keeperName = '',
    this.journalMemo = 'Kiểm kê kho định kỳ',
    this.isHandled = false,
    this.details = const [],
  });

  double get totalBookQuantity => details.fold(0.0, (sum, item) => sum + item.bookQuantity);
  double get totalActualQuantity => details.fold(0.0, (sum, item) => sum + item.actualQuantity);
  double get totalDiffQuantity => details.fold(0.0, (sum, item) => sum + item.diffQuantity);
  double get totalDiffAmount => details.fold(0.0, (sum, item) => sum + item.diffAmount);

  Map<String, dynamic> toMap() {
    return {
      'audit_id': auditId,
      'voucher_no': voucherNo,
      'audit_date': auditDate.toIso8601String(),
      'stock_id': stockId,
      'stock_name': stockName,
      'leader_name': leaderName,
      'accountant_name': accountantName,
      'keeper_name': keeperName,
      'journal_memo': journalMemo,
      'is_handled': isHandled,
      'details': details.map((d) => d.toMap()).toList(),
    };
  }

  factory AuditVoucherModel.fromMap(Map<String, dynamic> map) {
    return AuditVoucherModel(
      auditId: map['audit_id'] ?? '',
      voucherNo: map['voucher_no'] ?? '',
      auditDate: DateTime.parse(map['audit_date'] ?? DateTime.now().toIso8601String()),
      stockId: map['stock_id'] ?? '',
      stockName: map['stock_name'] ?? '',
      leaderName: map['leader_name'] ?? '',
      accountantName: map['accountant_name'] ?? '',
      keeperName: map['keeper_name'] ?? '',
      journalMemo: map['journal_memo'] ?? '',
      isHandled: map['is_handled'] ?? false,
      details: (map['details'] as List<dynamic>?)
              ?.map((d) => AuditDetailModel.fromMap(d))
              .toList() ??
          [],
    );
  }
}
