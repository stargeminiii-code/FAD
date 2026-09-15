import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../models/stock_model.dart';
import '../models/inventory_item_model.dart';
import '../models/inward_voucher_model.dart';
import '../models/outward_voucher_model.dart';
import '../models/transfer_voucher_model.dart';
import '../models/audit_voucher_model.dart';
import '../models/gl_posting_model.dart';

/// Local Database Engine & Sample Data Seeder for BizOne ERP FAD
class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  final Uuid _uuid = const Uuid();

  final List<StockModel> stocks = [];
  final List<InventoryItemModel> items = [];
  final List<InwardVoucherModel> inwards = [];
  final List<OutwardVoucherModel> outwards = [];
  final List<TransferVoucherModel> transfers = [];
  final List<AuditVoucherModel> audits = [];
  final List<GLPostingModel> glPostings = [];

  final Map<String, double> openingQuantities = {};
  final Map<String, double> openingAmounts = {};

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    _seedMasterData();
    _seedTransactions();
    _recalculateAllBalances();
    _isInitialized = true;
  }

  void _seedMasterData() {
    // 1. Kho hàng (Stocks)
    stocks.addAll([
      StockModel(
        stockId: 'stock_hn',
        stockCode: 'KHO_HN',
        stockName: 'Kho Tổng Hà Nội',
        accountId: AppConstants.accMerchandise,
        address: 'Tầng 1, Tòa nhà BizOne, Cầu Giấy, Hà Nội',
        keeperName: 'Nguyễn Văn An (Thủ kho)',
      ),
      StockModel(
        stockId: 'stock_hcm',
        stockCode: 'KHO_HCM',
        stockName: 'Kho Trung Tâm TP.HCM',
        accountId: AppConstants.accMerchandise,
        address: 'Quận 7, TP. Hồ Chí Minh',
        keeperName: 'Trần Thị Bình (Thủ kho)',
      ),
      StockModel(
        stockId: 'stock_bh',
        stockCode: 'KHO_BH',
        stockName: 'Kho Hàng Lỗi / Bảo Hành',
        accountId: AppConstants.accMerchandise,
        address: 'Khu vực kỹ thuật, Kho Tổng HN',
        keeperName: 'Lê Hoàng Cường (Kỹ thuật viên)',
      ),
    ]);

    // 2. Danh mục Vật tư Hàng hóa (Items - Trích xuất từ thực tế MISA)
    items.addAll([
      InventoryItemModel(
        inventoryItemId: 'item_mh27',
        inventoryItemCode: 'MHHTCC01',
        inventoryItemName: 'Màn hình máy tính cao cấp 27 inch 2K 165Hz',
        categoryName: 'Thiết bị hiển thị',
        unitName: 'Chiếc',
        inventoryAccount: AppConstants.accMerchandise,
        cogsAccount: AppConstants.accCOGS,
        revenueAccount: AppConstants.accRevenue,
        costMethod: AppConstants.costMethodMovingAverage,
        purchasePrice: 4200000.0,
        salePrice: 5800000.0,
        vatRate: 10.0,
        minimumStock: 10.0,
        maximumStock: 200.0,
      ),
      InventoryItemModel(
        inventoryItemId: 'item_bp_co',
        inventoryItemCode: 'BP_CO_RGB',
        inventoryItemName: 'Bàn phím cơ không dây Bluetooth RGB',
        categoryName: 'Phụ kiện máy tính',
        unitName: 'Chiếc',
        inventoryAccount: AppConstants.accMerchandise,
        cogsAccount: AppConstants.accCOGS,
        revenueAccount: AppConstants.accRevenue,
        costMethod: AppConstants.costMethodMovingAverage,
        purchasePrice: 650000.0,
        salePrice: 990000.0,
        vatRate: 10.0,
        minimumStock: 15.0,
        maximumStock: 300.0,
      ),
      InventoryItemModel(
        inventoryItemId: 'item_chuot_wl',
        inventoryItemCode: 'CHUOT_WL01',
        inventoryItemName: 'Chuột không dây công thái học Ergonomic',
        categoryName: 'Phụ kiện máy tính',
        unitName: 'Chiếc',
        inventoryAccount: AppConstants.accMerchandise,
        cogsAccount: AppConstants.accCOGS,
        revenueAccount: AppConstants.accRevenue,
        costMethod: AppConstants.costMethodMovingAverage,
        purchasePrice: 280000.0,
        salePrice: 450000.0,
        vatRate: 10.0,
        minimumStock: 20.0,
        maximumStock: 500.0,
      ),
      InventoryItemModel(
        inventoryItemId: 'item_ram16',
        inventoryItemCode: 'RAM_DDR5_16G',
        inventoryItemName: 'Thanh RAM DDR5 16GB Bus 5600MHz',
        categoryName: 'Linh kiện máy tính',
        unitName: 'Thanh',
        inventoryAccount: AppConstants.accMerchandise,
        cogsAccount: AppConstants.accCOGS,
        revenueAccount: AppConstants.accRevenue,
        costMethod: AppConstants.costMethodMovingAverage,
        purchasePrice: 1150000.0,
        salePrice: 1550000.0,
        vatRate: 10.0,
        minimumStock: 8.0,
        maximumStock: 150.0,
      ),
      InventoryItemModel(
        inventoryItemId: 'item_ssd1t',
        inventoryItemCode: 'SSD_NVME_1TB',
        inventoryItemName: 'Ổ cứng SSD NVMe M.2 1TB Gen 4x4',
        categoryName: 'Linh kiện máy tính',
        unitName: 'Chiếc',
        inventoryAccount: AppConstants.accMerchandise,
        cogsAccount: AppConstants.accCOGS,
        revenueAccount: AppConstants.accRevenue,
        costMethod: AppConstants.costMethodMovingAverage,
        purchasePrice: 1600000.0,
        salePrice: 2200000.0,
        vatRate: 10.0,
        minimumStock: 5.0,
        maximumStock: 100.0,
      ),
    ]);

    // 3. Số dư đầu kỳ (Opening Balances)
    openingQuantities['item_mh27'] = 25.0;
    openingAmounts['item_mh27'] = 105000000.0; // 25 * 4,200,000

    openingQuantities['item_bp_co'] = 50.0;
    openingAmounts['item_bp_co'] = 32500000.0; // 50 * 650,000

    openingQuantities['item_chuot_wl'] = 40.0;
    openingAmounts['item_chuot_wl'] = 11200000.0; // 40 * 280,000

    openingQuantities['item_ram16'] = 15.0;
    openingAmounts['item_ram16'] = 17250000.0; // 15 * 1,150,000

    openingQuantities['item_ssd1t'] = 4.0; // Cận mức tối thiểu để test cảnh báo
    openingAmounts['item_ssd1t'] = 6400000.0;
  }

  void _seedTransactions() {
    // Phiếu nhập kho NK00001 (Nhập mua hàng từ CÔNG TY CỔ PHẦN MISA)
    final nk1 = InwardVoucherModel(
      inwardId: 'inward_01',
      voucherNo: 'NK00001',
      voucherDate: DateTime(2026, 8, 1, 9, 30),
      postedDate: DateTime(2026, 8, 1, 9, 30),
      voucherType: AppConstants.inwardPurchaseDomestic,
      accountObjectId: 'misa_corp',
      accountObjectName: 'CÔNG TY CỔ PHẦN MISA',
      deliverer: 'Lê Minh Tuấn',
      stockId: 'stock_hn',
      stockName: 'Kho Tổng Hà Nội',
      journalMemo: 'Nhập mua màn hình và linh kiện máy tính',
      isPosted: true,
      details: [
        InwardDetailModel(
          detailId: _uuid.v4(),
          inwardId: 'inward_01',
          inventoryItemId: 'item_mh27',
          inventoryItemCode: 'MHHTCC01',
          inventoryItemName: 'Màn hình máy tính cao cấp 27 inch 2K 165Hz',
          unitName: 'Chiếc',
          quantity: 20.0,
          unitPrice: 4200000.0,
          vatRate: 10.0,
        ),
        InwardDetailModel(
          detailId: _uuid.v4(),
          inwardId: 'inward_01',
          inventoryItemId: 'item_ssd1t',
          inventoryItemCode: 'SSD_NVME_1TB',
          inventoryItemName: 'Ổ cứng SSD NVMe M.2 1TB Gen 4x4',
          unitName: 'Chiếc',
          quantity: 15.0,
          unitPrice: 1600000.0,
          vatRate: 10.0,
        ),
      ],
    );
    inwards.add(nk1);

    // Phiếu xuất kho XK00001 (Xuất bán cho Khách lẻ Shopee)
    final xk1 = OutwardVoucherModel(
      outwardId: 'outward_01',
      voucherNo: 'XK00001',
      voucherDate: DateTime(2026, 8, 5, 14, 20),
      postedDate: DateTime(2026, 8, 5, 14, 20),
      voucherType: AppConstants.outwardSale,
      accountObjectId: 'shopee_client',
      accountObjectName: 'Khách lẻ Shopee',
      receiver: 'Trần Văn Hùng (Giao vận Shopee Express)',
      stockId: 'stock_hn',
      stockName: 'Kho Tổng Hà Nội',
      journalMemo: 'Xuất kho bán hàng đơn Shopee #SP998231',
      isPosted: true,
      isCalculatedCost: true,
      details: [
        OutwardDetailModel(
          detailId: _uuid.v4(),
          outwardId: 'outward_01',
          inventoryItemId: 'item_mh27',
          inventoryItemCode: 'MHHTCC01',
          inventoryItemName: 'Màn hình máy tính cao cấp 27 inch 2K 165Hz',
          unitName: 'Chiếc',
          quantity: 5.0,
          costPrice: 4200000.0,
          salePrice: 5800000.0,
        ),
        OutwardDetailModel(
          detailId: _uuid.v4(),
          outwardId: 'outward_01',
          inventoryItemId: 'item_bp_co',
          inventoryItemCode: 'BP_CO_RGB',
          inventoryItemName: 'Bàn phím cơ không dây Bluetooth RGB',
          unitName: 'Chiếc',
          quantity: 10.0,
          costPrice: 650000.0,
          salePrice: 990000.0,
        ),
      ],
    );
    outwards.add(xk1);

    // Phiếu xuất kho XK00002 (Xuất bán cho Khách lẻ TikTokShop)
    final xk2 = OutwardVoucherModel(
      outwardId: 'outward_02',
      voucherNo: 'XK00002',
      voucherDate: DateTime(2026, 8, 10, 16, 45),
      postedDate: DateTime(2026, 8, 10, 16, 45),
      voucherType: AppConstants.outwardSale,
      accountObjectId: 'tiktok_client',
      accountObjectName: 'Khách lẻ TikTokShop',
      receiver: 'NinjaVan Shipper',
      stockId: 'stock_hn',
      stockName: 'Kho Tổng Hà Nội',
      journalMemo: 'Xuất bán Livestream TikTok #TTK8823',
      isPosted: true,
      isCalculatedCost: true,
      details: [
        OutwardDetailModel(
          detailId: _uuid.v4(),
          outwardId: 'outward_02',
          inventoryItemId: 'item_chuot_wl',
          inventoryItemCode: 'CHUOT_WL01',
          inventoryItemName: 'Chuột không dây công thái học Ergonomic',
          unitName: 'Chiếc',
          quantity: 12.0,
          costPrice: 280000.0,
          salePrice: 450000.0,
        ),
      ],
    );
    outwards.add(xk2);

    // Phiếu điều chuyển kho CK00001 (Kho HN -> Kho HCM)
    final ck1 = TransferVoucherModel(
      transferId: 'transfer_01',
      voucherNo: 'CK00001',
      voucherDate: DateTime(2026, 8, 12, 10, 00),
      postedDate: DateTime(2026, 8, 12, 10, 00),
      fromStockId: 'stock_hn',
      fromStockName: 'Kho Tổng Hà Nội',
      toStockId: 'stock_hcm',
      toStockName: 'Kho Trung Tâm TP.HCM',
      isInTransit: false,
      transporter: 'Viettel Post Liên Tỉnh',
      journalMemo: 'Điều chuyển hàng bổ sung tồn cho Kho HCM',
      isPosted: true,
      details: [
        TransferDetailModel(
          detailId: _uuid.v4(),
          transferId: 'transfer_01',
          inventoryItemId: 'item_mh27',
          inventoryItemCode: 'MHHTCC01',
          inventoryItemName: 'Màn hình máy tính cao cấp 27 inch 2K 165Hz',
          unitName: 'Chiếc',
          quantity: 5.0,
          unitPrice: 4200000.0,
        ),
      ],
    );
    transfers.add(ck1);
  }

  /// Tính lại tồn kho tức thời (On-Hand Quantity & Inventory Amount)
  void _recalculateAllBalances() {
    for (final item in items) {
      final id = item.inventoryItemId;
      double qty = openingQuantities[id] ?? 0.0;
      double amt = openingAmounts[id] ?? 0.0;

      for (final inV in inwards) {
        if (!inV.isPosted) continue;
        for (final d in inV.details) {
          if (d.inventoryItemId == id) {
            qty += d.baseQuantity;
            amt += d.amount;
          }
        }
      }

      for (final outV in outwards) {
        if (!outV.isPosted) continue;
        for (final d in outV.details) {
          if (d.inventoryItemId == id) {
            qty -= d.baseQuantity;
            amt -= d.costAmount;
          }
        }
      }

      item.onHandQuantity = qty;
      item.inventoryAmount = amt;
    }
  }

  void refreshBalances() {
    _recalculateAllBalances();
  }
}
