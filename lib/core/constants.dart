/// Application and Inventory Constants for BizOne ERP (FAD)
class AppConstants {
  static const String appName = 'BizOne ERP - FAD';
  static const String appSubtitle = 'Phân Hệ Tài Chính Kế Toán & Quản Lý Kho';
  static const String appVersion = 'v1.0.0 (MISA SME/AMIS Model)';

  // Inventory Cost Methods (Phương pháp tính giá xuất kho)
  static const int costMethodMovingAverage = 1;    // Bình quân tức thời
  static const int costMethodPeriodicAverage = 2;  // Bình quân cuối kỳ
  static const int costMethodFIFO = 3;             // Nhập trước xuất trước
  static const int costMethodSpecific = 4;         // Đích danh

  // Inventory Item Types (Loại VTHH)
  static const int itemTypeProduct = 1;      // Hàng hóa
  static const int itemTypeRawMaterial = 2;  // Nguyên vật liệu
  static const int itemTypeFinishedGood = 3; // Thành phẩm
  static const int itemTypeTool = 4;         // Công cụ dụng cụ
  static const int itemTypeService = 5;      // Dịch vụ

  // Voucher Types - Inward (Loại phiếu nhập kho)
  static const int inwardPurchaseDomestic = 1; // Nhập kho mua hàng trong nước
  static const int inwardPurchaseImport = 2;   // Nhập kho mua hàng nhập khẩu
  static const int inwardProduction = 3;       // Nhập kho thành phẩm sản xuất
  static const int inwardSalesReturn = 4;      // Nhập kho hàng bán bị trả lại
  static const int inwardTransfer = 5;         // Nhập kho điều chuyển nội bộ
  static const int inwardSurplusAudit = 6;     // Nhập kho thừa sau kiểm kê
  static const int inwardOther = 7;            // Nhập kho khác

  // Voucher Types - Outward (Loại phiếu xuất kho)
  static const int outwardSale = 1;            // Xuất kho bán hàng (TMĐT/bán buôn/bán lẻ)
  static const int outwardProduction = 2;      // Xuất kho sản xuất (xuất NVL)
  static const int outwardVendorReturn = 3;    // Xuất kho trả lại nhà cung cấp
  static const int outwardInternalTransfer = 4;// Xuất kho điều chuyển nội bộ
  static const int outwardInternalUse = 5;     // Xuất kho tiêu dùng nội bộ / khuyến mại
  static const int outwardDeficitAudit = 6;    // Xuất kho hao hụt / mất mát sau kiểm kê
  static const int outwardOther = 7;           // Xuất kho khác

  // Standard Accounting Accounts (Hệ thống TK Kế toán TT200 / TT133)
  static const String accCash = '1111';            // Tiền mặt VND
  static const String accBank = '1121';            // Tiền gửi ngân hàng VND
  static const String accAR = '131';               // Phải thu khách hàng
  static const String accInputVAT = '1331';        // Thuế GTGT đầu vào được khấu trừ
  static const String accClaimSuspense = '1381';   // Tài sản thiếu chờ xử lý
  static const String accRawMaterial = '152';      // Nguyên liệu, vật liệu
  static const String accTools = '153';            // Công cụ, dụng cụ
  static const String accWIP = '154';              // Chi phí sản xuất, kinh doanh dở dang
  static const String accFinishedGoods = '155';    // Thành phẩm
  static const String accMerchandise = '1561';     // Giá mua hàng hóa
  static const String accGoodsInTransit = '157';   // Hàng gửi đi bán / Hàng đi đường
  static const String accPrepaidExpenses = '242';  // Chi phí trả trước
  static const String accAP = '331';               // Phải trả người bán
  static const String accOutputVAT = '33311';      // Thuế GTGT đầu ra
  static const String accSurplusSuspense = '3381'; // Tài sản thừa chờ giải quyết
  static const String accRevenue = '5111';         // Doanh thu bán hàng hóa
  static const String accDirectMaterials = '621';  // Chi phí NVL trực tiếp (TT 200)
  static const String accCOGS = '632';             // Giá vốn hàng bán
  static const String accSellingExpense = '641';   // Chi phí bán hàng
  static const String accAdminExpense = '642';     // Chi phí quản lý doanh nghiệp
  static const String accOtherIncome = '711';      // Thu nhập khác
  static const String accOtherExpense = '811';     // Chi phí khác
}
