/// Stock / Warehouse Model (Danh mục Kho)
class StockModel {
  final String stockId;
  final String stockCode;
  final String stockName;
  final String branchId;
  final String accountId; // Default inventory account e.g. 1561, 152, 155
  final String address;
  final String keeperName;
  final bool isInactive;

  StockModel({
    required this.stockId,
    required this.stockCode,
    required this.stockName,
    this.branchId = 'BRANCH_MAIN',
    this.accountId = '1561',
    this.address = '',
    this.keeperName = '',
    this.isInactive = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'stock_id': stockId,
      'stock_code': stockCode,
      'stock_name': stockName,
      'branch_id': branchId,
      'account_id': accountId,
      'address': address,
      'keeper_name': keeperName,
      'is_inactive': isInactive,
    };
  }

  factory StockModel.fromMap(Map<String, dynamic> map) {
    return StockModel(
      stockId: map['stock_id'] ?? '',
      stockCode: map['stock_code'] ?? '',
      stockName: map['stock_name'] ?? '',
      branchId: map['branch_id'] ?? 'BRANCH_MAIN',
      accountId: map['account_id'] ?? '1561',
      address: map['address'] ?? '',
      keeperName: map['keeper_name'] ?? '',
      isInactive: map['is_inactive'] ?? false,
    );
  }
}
