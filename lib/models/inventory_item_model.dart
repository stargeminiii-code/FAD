import '../core/constants.dart';

/// Inventory Item Model (Danh mục Vật tư Hàng hóa - VTHH)
class InventoryItemModel {
  final String inventoryItemId;
  final String inventoryItemCode;
  final String inventoryItemName;
  final String inventoryItemNameSearch;
  final int inventoryItemType; // 1: Hàng hóa, 2: NVL, 3: Thành phẩm, 4: CCDC, 5: Dịch vụ
  final String categoryName;
  final String unitName; // Base UOM (Đơn vị tính chính: Cái, Hộp, Kg, Thùng...)
  final String inventoryAccount; // TK ngầm định: 1561, 152, 155, 153
  final String cogsAccount; // TK giá vốn: 632
  final String revenueAccount; // TK doanh thu: 5111, 5112
  final int costMethod; // 1: BQ tức thời, 2: BQ cuối kỳ, 3: FIFO, 4: Đích danh
  final double purchasePrice; // Đơn giá mua gần nhất
  final double salePrice; // Đơn giá bán
  final double vatRate; // % thuế GTGT: 0, 5, 8, 10
  final double minimumStock; // Tồn tối thiểu cảnh báo
  final double maximumStock; // Tồn tối đa
  final bool isFollowSerial;
  final bool isFollowLot;
  final bool isInactive;

  // Running Inventory Balance (Tồn tức thời)
  double onHandQuantity;
  double inventoryAmount;

  InventoryItemModel({
    required this.inventoryItemId,
    required this.inventoryItemCode,
    required this.inventoryItemName,
    String? inventoryItemNameSearch,
    this.inventoryItemType = AppConstants.itemTypeProduct,
    this.categoryName = 'Hàng hóa thông dụng',
    this.unitName = 'Cái',
    this.inventoryAccount = AppConstants.accMerchandise,
    this.cogsAccount = AppConstants.accCOGS,
    this.revenueAccount = AppConstants.accRevenue,
    this.costMethod = AppConstants.costMethodMovingAverage,
    this.purchasePrice = 0.0,
    this.salePrice = 0.0,
    this.vatRate = 10.0,
    this.minimumStock = 5.0,
    this.maximumStock = 1000.0,
    this.isFollowSerial = false,
    this.isFollowLot = false,
    this.isInactive = false,
    this.onHandQuantity = 0.0,
    this.inventoryAmount = 0.0,
  }) : inventoryItemNameSearch = inventoryItemNameSearch ?? inventoryItemName.toLowerCase();

  double get averageCostPrice => onHandQuantity > 0 ? inventoryAmount / onHandQuantity : purchasePrice;

  Map<String, dynamic> toMap() {
    return {
      'inventory_item_id': inventoryItemId,
      'inventory_item_code': inventoryItemCode,
      'inventory_item_name': inventoryItemName,
      'inventory_item_name_search': inventoryItemNameSearch,
      'inventory_item_type': inventoryItemType,
      'category_name': categoryName,
      'unit_name': unitName,
      'inventory_account': inventoryAccount,
      'cogs_account': cogsAccount,
      'revenue_account': revenueAccount,
      'cost_method': costMethod,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'vat_rate': vatRate,
      'minimum_stock': minimumStock,
      'maximum_stock': maximumStock,
      'is_follow_serial': isFollowSerial,
      'is_follow_lot': isFollowLot,
      'is_inactive': isInactive,
      'on_hand_quantity': onHandQuantity,
      'inventory_amount': inventoryAmount,
    };
  }

  factory InventoryItemModel.fromMap(Map<String, dynamic> map) {
    return InventoryItemModel(
      inventoryItemId: map['inventory_item_id'] ?? '',
      inventoryItemCode: map['inventory_item_code'] ?? '',
      inventoryItemName: map['inventory_item_name'] ?? '',
      inventoryItemNameSearch: map['inventory_item_name_search'],
      inventoryItemType: map['inventory_item_type'] ?? AppConstants.itemTypeProduct,
      categoryName: map['category_name'] ?? 'Hàng hóa thông dụng',
      unitName: map['unit_name'] ?? 'Cái',
      inventoryAccount: map['inventory_account'] ?? AppConstants.accMerchandise,
      cogsAccount: map['cogs_account'] ?? AppConstants.accCOGS,
      revenueAccount: map['revenue_account'] ?? AppConstants.accRevenue,
      costMethod: map['cost_method'] ?? AppConstants.costMethodMovingAverage,
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (map['sale_price'] as num?)?.toDouble() ?? 0.0,
      vatRate: (map['vat_rate'] as num?)?.toDouble() ?? 10.0,
      minimumStock: (map['minimum_stock'] as num?)?.toDouble() ?? 5.0,
      maximumStock: (map['maximum_stock'] as num?)?.toDouble() ?? 1000.0,
      isFollowSerial: map['is_follow_serial'] ?? false,
      isFollowLot: map['is_follow_lot'] ?? false,
      isInactive: map['is_inactive'] ?? false,
      onHandQuantity: (map['on_hand_quantity'] as num?)?.toDouble() ?? 0.0,
      inventoryAmount: (map['inventory_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
