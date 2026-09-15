import 'package:flutter_test/flutter_test.dart';
import 'package:bizone_fad/core/constants.dart';
import 'package:bizone_fad/database/local_database.dart';
import 'package:bizone_fad/models/inventory_item_model.dart';
import 'package:bizone_fad/models/inward_voucher_model.dart';
import 'package:bizone_fad/models/outward_voucher_model.dart';
import 'package:bizone_fad/models/unit_convert_model.dart';
import 'package:bizone_fad/services/accounting_posting_service.dart';
import 'package:bizone_fad/services/cost_calculation_service.dart';
import 'package:bizone_fad/services/inventory_report_service.dart';
import 'package:bizone_fad/services/inventory_service.dart';

void main() {
  group('Kiểm thử Nghiệp Vụ Kho & Hạch Toán Kế Toán FAD Chuẩn MISA', () {
    late InventoryService inventoryService;
    late AccountingPostingService postingService;
    late CostCalculationService costService;
    late InventoryReportService reportService;

    setUp(() {
      final db = LocalDatabase();
      db.initialize();
      inventoryService = InventoryService();
      postingService = AccountingPostingService();
      costService = CostCalculationService();
      reportService = InventoryReportService();
    });

    test('1. Kiểm thử Đơn vị tính quy đổi (Multi-UOM conversion)', () {
      final unitConvert = UnitConvertModel(
        convertId: 'conv_1',
        inventoryItemId: 'item_1',
        unitName: 'Thùng',
        convertRate: 24.0, // 1 Thùng = 24 Chai
        operator: 1, // Phép nhân
      );

      final baseQty = unitConvert.toBaseQuantity(5.0); // 5 Thùng
      expect(baseQty, equals(120.0)); // 120 Chai
    });

    test('2. Kiểm thử Tính giá xuất kho Bình quân tức thời (Moving Average)', () {
      final item = InventoryItemModel(
        inventoryItemId: 'item_test',
        inventoryItemCode: 'TEST01',
        inventoryItemName: 'Hàng thử nghiệm',
        purchasePrice: 100000.0,
      );

      // Tồn trước xuất: 10 cái, tổng tiền 1,200,000 đ -> Đơn giá BQ = 120,000 đ
      final unitCost = costService.calculateMovingAverageCost(
        item: item,
        currentStockQty: 10.0,
        currentStockAmount: 1200000.0,
        outwardQty: 3.0,
      );

      expect(unitCost, equals(120000.0));
    });

    test('3. Kiểm thử Sinh bút toán Sổ Cái Kế toán Nhập kho (Nợ 1561 / Có 331)', () {
      final inward = InwardVoucherModel(
        inwardId: 'in_test',
        voucherNo: 'NK9999',
        voucherDate: DateTime.now(),
        postedDate: DateTime.now(),
        stockId: 'stock_hn',
        stockName: 'Kho Tổng',
        accountObjectName: 'Công ty MISA',
        details: [
          InwardDetailModel(
            detailId: 'd_1',
            inwardId: 'in_test',
            inventoryItemId: 'item_1',
            inventoryItemCode: 'MH01',
            inventoryItemName: 'Màn hình',
            unitName: 'Chiếc',
            quantity: 5.0,
            unitPrice: 4000000.0,
            amount: 20000000.0,
            debitAccount: AppConstants.accMerchandise, // 1561
            creditAccount: AppConstants.accAP, // 331
          ),
        ],
      );

      final postings = postingService.generateInwardPostings(inward);
      expect(postings.length, equals(1));
      expect(postings.first.debitAccount, equals('1561'));
      expect(postings.first.creditAccount, equals('331'));
      expect(postings.first.amount, equals(20000000.0));
    });

    test('4. Kiểm thử Sinh bút toán Giá vốn Xuất kho (Nợ 632 / Có 1561)', () {
      final outward = OutwardVoucherModel(
        outwardId: 'out_test',
        voucherNo: 'XK9999',
        voucherDate: DateTime.now(),
        postedDate: DateTime.now(),
        stockId: 'stock_hn',
        stockName: 'Kho Tổng',
        accountObjectName: 'Khách lẻ Shopee',
        details: [
          OutwardDetailModel(
            detailId: 'd_2',
            outwardId: 'out_test',
            inventoryItemId: 'item_1',
            inventoryItemCode: 'MH01',
            inventoryItemName: 'Màn hình',
            unitName: 'Chiếc',
            quantity: 2.0,
            costPrice: 4000000.0,
            costAmount: 8000000.0,
            salePrice: 5500000.0,
            saleAmount: 11000000.0,
            debitAccount: AppConstants.accCOGS, // 632
            creditAccount: AppConstants.accMerchandise, // 1561
          ),
        ],
      );

      final postings = postingService.generateOutwardPostings(outward);
      // Có 2 bút toán: Giá vốn (Nợ 632 / Có 1561) và Doanh thu (Nợ 131 / Có 5111)
      expect(postings.length, equals(2));

      final cogsPosting = postings.firstWhere((p) => p.debitAccount == '632');
      expect(cogsPosting.creditAccount, equals('1561'));
      expect(cogsPosting.amount, equals(8000000.0));

      final revPosting = postings.firstWhere((p) => p.debitAccount == '131');
      expect(revPosting.creditAccount, equals('5111'));
      expect(revPosting.amount, equals(11000000.0));
    });

    test('5. Kiểm thử Bảng Tổng Hợp Nhập - Xuất - Tồn (Mẫu S11-DN)', () {
      final db = inventoryService.db;
      final report = reportService.generateInventorySummaryReport(
        items: db.items,
        inwards: db.inwards,
        outwards: db.outwards,
        openingQuantities: db.openingQuantities,
        openingAmounts: db.openingAmounts,
      );

      expect(report.isNotEmpty, isTrue);
      for (final row in report) {
        // Công thức bảo toàn: Tồn cuối kỳ = Tồn đầu kỳ + Nhập trong kỳ - Xuất trong kỳ
        final expectedClosingQty = row.openingQty + row.inwardQty - row.outwardQty;
        expect(row.closingQty, equals(expectedClosingQty));
      }
    });
  });
}
