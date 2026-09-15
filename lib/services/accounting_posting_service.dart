import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../models/inward_voucher_model.dart';
import '../models/outward_voucher_model.dart';
import '../models/transfer_voucher_model.dart';
import '../models/gl_posting_model.dart';

/// Accounting Posting Service (Quy tắc định khoản Kế toán Kho TT 200 & TT 133)
class AccountingPostingService {
  final Uuid _uuid = const Uuid();

  /// Sinh bút toán Sổ Cái từ Phiếu Nhập Kho (IN_INWARD)
  List<GLPostingModel> generateInwardPostings(InwardVoucherModel voucher) {
    final postings = <GLPostingModel>[];

    for (final detail in voucher.details) {
      // Bút toán giá trị hàng nhập kho (Nợ TK Kho 1561/152/155 - Có TK 331/1111/1121/154...)
      postings.add(
        GLPostingModel(
          postingId: _uuid.v4(),
          voucherId: voucher.inwardId,
          voucherNo: voucher.voucherNo,
          voucherType: 'IN_INWARD',
          voucherDate: voucher.voucherDate,
          postedDate: voucher.postedDate,
          debitAccount: detail.debitAccount,
          creditAccount: detail.creditAccount,
          amount: detail.amount,
          accountObjectId: voucher.accountObjectId,
          accountObjectName: voucher.accountObjectName,
          stockId: voucher.stockId,
          stockName: voucher.stockName,
          inventoryItemId: detail.inventoryItemId,
          inventoryItemName: detail.inventoryItemName,
          journalMemo: voucher.journalMemo,
        ),
      );

      // Bút toán Thuế GTGT đầu vào khấu trừ (nếu có): Nợ 1331 / Có 331
      if (detail.vatAmount > 0) {
        postings.add(
          GLPostingModel(
            postingId: _uuid.v4(),
            voucherId: voucher.inwardId,
            voucherNo: voucher.voucherNo,
            voucherType: 'IN_INWARD',
            voucherDate: voucher.voucherDate,
            postedDate: voucher.postedDate,
            debitAccount: AppConstants.accInputVAT,
            creditAccount: detail.creditAccount,
            amount: detail.vatAmount,
            accountObjectId: voucher.accountObjectId,
            accountObjectName: voucher.accountObjectName,
            stockId: voucher.stockId,
            stockName: voucher.stockName,
            inventoryItemId: detail.inventoryItemId,
            inventoryItemName: detail.inventoryItemName,
            journalMemo: 'Thuế GTGT đầu vào - ${voucher.voucherNo}',
          ),
        );
      }
    }

    return postings;
  }

  /// Sinh bút toán Sổ Cái từ Phiếu Xuất Kho (IN_OUTWARD)
  List<GLPostingModel> generateOutwardPostings(OutwardVoucherModel voucher) {
    final postings = <GLPostingModel>[];

    for (final detail in voucher.details) {
      // 1. Bút toán Giá Vốn Xuất Kho: Nợ TK 632/621/242/331/1381 - Có TK Kho 1561/152/155
      if (detail.costAmount > 0) {
        postings.add(
          GLPostingModel(
            postingId: _uuid.v4(),
            voucherId: voucher.outwardId,
            voucherNo: voucher.voucherNo,
            voucherType: 'IN_OUTWARD',
            voucherDate: voucher.voucherDate,
            postedDate: voucher.postedDate,
            debitAccount: detail.debitAccount,
            creditAccount: detail.creditAccount,
            amount: detail.costAmount,
            accountObjectId: voucher.accountObjectId,
            accountObjectName: voucher.accountObjectName,
            stockId: voucher.stockId,
            stockName: voucher.stockName,
            inventoryItemId: detail.inventoryItemId,
            inventoryItemName: detail.inventoryItemName,
            journalMemo: 'Giá vốn xuất kho - ${voucher.voucherNo}',
          ),
        );
      }

      // 2. Bút toán Doanh Thu Bán Hàng (nếu phiếu xuất kiêm hóa đơn bán hàng): Nợ 131/111 - Có 5111
      if (detail.saleAmount > 0 && voucher.voucherType == AppConstants.outwardSale) {
        postings.add(
          GLPostingModel(
            postingId: _uuid.v4(),
            voucherId: voucher.outwardId,
            voucherNo: voucher.voucherNo,
            voucherType: 'IN_OUTWARD',
            voucherDate: voucher.voucherDate,
            postedDate: voucher.postedDate,
            debitAccount: AppConstants.accAR,
            creditAccount: AppConstants.accRevenue,
            amount: detail.saleAmount,
            accountObjectId: voucher.accountObjectId,
            accountObjectName: voucher.accountObjectName,
            stockId: voucher.stockId,
            stockName: voucher.stockName,
            inventoryItemId: detail.inventoryItemId,
            inventoryItemName: detail.inventoryItemName,
            journalMemo: 'Doanh thu bán hàng - ${voucher.voucherNo}',
          ),
        );
      }
    }

    return postings;
  }

  /// Sinh bút toán Sổ Cái từ Phiếu Điều Chuyển Kho (IN_TRANSFER)
  List<GLPostingModel> generateTransferPostings(TransferVoucherModel voucher) {
    final postings = <GLPostingModel>[];

    for (final detail in voucher.details) {
      if (voucher.isInTransit) {
        // Chuyển qua hàng đi đường (TK 157)
        // Bước xuất: Nợ 157 / Có 156 (Kho xuất)
        postings.add(
          GLPostingModel(
            postingId: _uuid.v4(),
            voucherId: voucher.transferId,
            voucherNo: voucher.voucherNo,
            voucherType: 'IN_TRANSFER',
            voucherDate: voucher.voucherDate,
            postedDate: voucher.postedDate,
            debitAccount: AppConstants.accGoodsInTransit,
            creditAccount: AppConstants.accMerchandise,
            amount: detail.amount,
            stockId: voucher.fromStockId,
            stockName: voucher.fromStockName,
            inventoryItemId: detail.inventoryItemId,
            inventoryItemName: detail.inventoryItemName,
            journalMemo: 'Xuất hàng chuyển kho đi trên đường: ${voucher.fromStockName} -> ${voucher.toStockName}',
          ),
        );
      } else {
        // Chuyển trực tiếp giữa các kho nội bộ: Nợ 156 (Kho nhập) / Có 156 (Kho xuất)
        postings.add(
          GLPostingModel(
            postingId: _uuid.v4(),
            voucherId: voucher.transferId,
            voucherNo: voucher.voucherNo,
            voucherType: 'IN_TRANSFER',
            voucherDate: voucher.voucherDate,
            postedDate: voucher.postedDate,
            debitAccount: AppConstants.accMerchandise,
            creditAccount: AppConstants.accMerchandise,
            amount: detail.amount,
            stockId: voucher.toStockId,
            stockName: voucher.toStockName,
            inventoryItemId: detail.inventoryItemId,
            inventoryItemName: detail.inventoryItemName,
            journalMemo: 'Điều chuyển kho trực tiếp: ${voucher.fromStockName} -> ${voucher.toStockName}',
          ),
        );
      }
    }

    return postings;
  }
}
