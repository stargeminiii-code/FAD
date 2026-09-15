/// Unit Convert Model (Đơn vị tính quy đổi)
class UnitConvertModel {
  final String convertId;
  final String inventoryItemId;
  final String unitName; // Tên đơn vị chuyển đổi (ví dụ: Thùng)
  final double convertRate; // Tỷ lệ quy đổi so với Base UOM (ví dụ: 24)
  final int operator; // 1: Phép nhân (*), 2: Phép chia (/)
  final double salePrice; // Đơn giá bán theo ĐVT này
  final String description;

  UnitConvertModel({
    required this.convertId,
    required this.inventoryItemId,
    required this.unitName,
    required this.convertRate,
    this.operator = 1,
    this.salePrice = 0.0,
    this.description = '',
  });

  /// Tính số lượng quy đổi ra Base UOM
  double toBaseQuantity(double quantity) {
    if (operator == 2 && convertRate != 0) {
      return quantity / convertRate;
    }
    return quantity * convertRate;
  }

  Map<String, dynamic> toMap() {
    return {
      'convert_id': convertId,
      'inventory_item_id': inventoryItemId,
      'unit_name': unitName,
      'convert_rate': convertRate,
      'operator': operator,
      'sale_price': salePrice,
      'description': description,
    };
  }

  factory UnitConvertModel.fromMap(Map<String, dynamic> map) {
    return UnitConvertModel(
      convertId: map['convert_id'] ?? '',
      inventoryItemId: map['inventory_item_id'] ?? '',
      unitName: map['unit_name'] ?? '',
      convertRate: (map['convert_rate'] as num?)?.toDouble() ?? 1.0,
      operator: map['operator'] ?? 1,
      salePrice: (map['sale_price'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
    );
  }
}
