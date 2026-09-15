/// General Ledger Posting Entry (Bút toán hạch toán Sổ Cái)
class GLPostingModel {
  final String postingId;
  final String voucherId;
  final String voucherNo;
  final String voucherType; // IN_INWARD, IN_OUTWARD, IN_TRANSFER
  final DateTime voucherDate;
  final DateTime postedDate;
  final String debitAccount; // TK Nợ (vd: 1561, 632, 1111, 331...)
  final String creditAccount; // TK Có
  final double amount; // Số tiền hạch toán VND
  final String currency;
  final String accountObjectId; // Đối tượng: Khách hàng / Nhà cung cấp / Nhân viên
  final String accountObjectName;
  final String stockId; // Kho liên quan
  final String stockName;
  final String inventoryItemId; // Vật tư hàng hóa
  final String inventoryItemName;
  final String journalMemo;

  GLPostingModel({
    required this.postingId,
    required this.voucherId,
    required this.voucherNo,
    required this.voucherType,
    required this.voucherDate,
    required this.postedDate,
    required this.debitAccount,
    required this.creditAccount,
    required this.amount,
    this.currency = 'VND',
    this.accountObjectId = '',
    this.accountObjectName = '',
    this.stockId = '',
    this.stockName = '',
    this.inventoryItemId = '',
    this.inventoryItemName = '',
    this.journalMemo = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'posting_id': postingId,
      'voucher_id': voucherId,
      'voucher_no': voucherNo,
      'voucher_type': voucherType,
      'voucher_date': voucherDate.toIso8601String(),
      'posted_date': postedDate.toIso8601String(),
      'debit_account': debitAccount,
      'credit_account': creditAccount,
      'amount': amount,
      'currency': currency,
      'account_object_id': accountObjectId,
      'account_object_name': accountObjectName,
      'stock_id': stockId,
      'stock_name': stockName,
      'inventory_item_id': inventoryItemId,
      'inventory_item_name': inventoryItemName,
      'journal_memo': journalMemo,
    };
  }

  factory GLPostingModel.fromMap(Map<String, dynamic> map) {
    return GLPostingModel(
      postingId: map['posting_id'] ?? '',
      voucherId: map['voucher_id'] ?? '',
      voucherNo: map['voucher_no'] ?? '',
      voucherType: map['voucher_type'] ?? '',
      voucherDate: DateTime.parse(map['voucher_date'] ?? DateTime.now().toIso8601String()),
      postedDate: DateTime.parse(map['posted_date'] ?? DateTime.now().toIso8601String()),
      debitAccount: map['debit_account'] ?? '',
      creditAccount: map['credit_account'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'VND',
      accountObjectId: map['account_object_id'] ?? '',
      accountObjectName: map['account_object_name'] ?? '',
      stockId: map['stock_id'] ?? '',
      stockName: map['stock_name'] ?? '',
      inventoryItemId: map['inventory_item_id'] ?? '',
      inventoryItemName: map['inventory_item_name'] ?? '',
      journalMemo: map['journal_memo'] ?? '',
    );
  }
}
