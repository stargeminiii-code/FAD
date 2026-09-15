# BizOne ERP - Phân Hệ Tài Chính Kế Toán (FAD) & Quản Lý Kho Chuẩn MISA

Dự án phần mềm **BizOne ERP - FAD (Financial & Accounting Department)** được thiết kế và xây dựng theo chuẩn mực kiến trúc của **MISA SME / MISA AMIS**, tuân thủ Chế độ Kế toán Doanh nghiệp Việt Nam (**Thông tư 200/2014/TT-BTC** và **Thông tư 133/2016/TT-BTC**).

Hệ thống được phát triển bằng công nghệ **Flutter (Dart Framework)** hỗ trợ xuất đồng thời ra:
- **File `.exe` cho máy tính PC (Windows)**: Giao diện bảng biểu kế toán (DataGrid), hỗ trợ phím tắt nghiệp vụ (F2, F3, F8, F9), in ấn biểu mẫu A4/A5/phiếu nhiệt.
- **File `.apk` cho điện thoại di động (Android)**: Giao diện cảm ứng tối ưu hóa, quét mã Barcode/QR Code qua Camera điện thoại, kiểm kê và xem báo cáo tồn kho di động.

---

## 🚀 Các Tính Năng Đã Hoàn Thiện (Phân Hệ Kho - Inventory)

1. **Danh Mục Vật Tư Hàng Hóa (`DI_INVENTORY_ITEM`)**:
   - Quản lý mã SKU, tên hàng, đơn vị tính chính, nhóm mặt hàng.
   - Thiết lập tài khoản kế toán ngầm định (TK 1561/152/155, TK giá vốn 632, TK doanh thu 511).
   - Đơn vị tính quy đổi đa cấp (Multi-UOM: Thùng -> Hộp -> Gói -> Lon).
   - Cảnh báo tồn kho tối thiểu / tồn kho tối đa.

2. **Phiếu Nhập Kho (`IN_INWARD`)**:
   - Nhập mua hàng trong nước / nhập khẩu, nhập thành phẩm sản xuất, nhập hàng bán bị trả lại, nhập thừa kiểm kê.
   - Tự động sinh bút toán Sổ Cái Kế toán: **Nợ TK 1561 / Có TK 331, 1111, 1121**.
   - Cơ chế ghi sổ / bỏ ghi sổ (F9).

3. **Phiếu Xuất Kho (`IN_OUTWARD`)**:
   - Xuất bán hàng (Shopee, TikTok, Lazada, bán lẻ/bán buôn), xuất sản xuất, xuất trả nhà cung cấp.
   - Kiểm tra số lượng tồn tức thời trước khi xuất.
   - Tự động sinh bút toán Giá Vốn: **Nợ TK 632 / Có TK 1561** và Doanh thu: **Nợ TK 131 / Có TK 5111**.

4. **Điều Chuyển Kho Nội Bộ (`IN_TRANSFER`)**:
   - Hỗ trợ Chuyển trực tiếp (**Nợ 156 Kho nhận / Có 156 Kho xuất**).
   - Hỗ trợ Chuyển qua hàng đi đường (**Nợ 157 / Có 156**).

5. **Biên Bản Kiểm Kê Kho (`IN_AUDITWARD`)**:
   - Tự động lấy số lượng tồn trên sổ sách kế toán.
   - Nhập số lượng thực tế kiểm kê tại kho.
   - Tự động tính chênh lệch Thừa / Thiếu và giá trị tiền tương ứng.
   - **Nút 1-click**: Tự động sinh Phiếu Nhập Hàng Thừa (**TK 3381**) và Phiếu Xuất Hàng Thiếu (**TK 1381**).

6. **Tính Giá Xuất Kho Kỳ Kế Toán (`IN_CALCULATE_PRICE`)**:
   - Phương pháp **Bình quân gia quyền cuối kỳ** (Periodic Average).
   - Phương pháp **Bình quân gia quyền tức thời** (Moving Average).
   - Phương pháp **Nhập trước - Xuất trước** (FIFO).
   - Tự động quét và cập nhật lại toàn bộ đơn giá vốn trên phiếu xuất và đồng bộ lại Sổ Cái.

7. **Báo Cáo Kế Toán Kho Chuẩn Bộ Tài Chính**:
   - **Bảng Tổng Hợp Nhập - Xuất - Tồn (Mẫu S11-DN)** đầy đủ Lượng & Tiền.
   - Sổ Chi Tiết Vật Tư Hàng Hóa (Mẫu S10-DN).
   - Hỗ trợ in ấn biểu mẫu và xuất file Excel.

---

## 🛠 Hướng Dẫn Biên Dịch Xuất File `.exe` và `.apk`

### 1. Xuất file `.apk` (Android Mobile)
Trên máy tính đã cài đặt Flutter SDK và Android SDK, chạy lệnh:
```bash
flutter build apk --release
```
File APK thành phẩm nằm tại:
`build/app/outputs/flutter-apk/app-release.apk`

### 2. Xuất file `.exe` (PC Windows)
Do máy tính phát triển là macOS, bạn có 2 cách xuất file `.exe`:

- **Cách 1: Tự động hóa qua GitHub Actions (Khuyến nghị)**:
  Tập tin `.github/workflows/build_app.yml` đã được cấu hình sẵn. Khi bạn đẩy mã nguồn lên GitHub (hoặc tạo Release), máy chủ Windows của GitHub sẽ tự động biên dịch và tạo sẵn file `BizOne_FAD_Windows_x64.zip` chứa file `bizone_fad.exe` để bạn tải về ngay.
- **Cách 2: Chép sang máy Windows**:
  Chép thư mục dự án sang máy tính Windows đã cài Flutter và Visual Studio C++, mở Terminal và chạy:
  ```powershell
  flutter config --enable-windows-desktop
  flutter build windows --release
  ```
  File EXE thành phẩm nằm tại:
  `build\windows\x64\runner\Release\bizone_fad.exe`

---

## 🧪 Chạy Kiểm Thử Nghiệp Vụ (Unit Tests)
```bash
flutter test
```
Bộ kiểm thử bao gồm kiểm tra:
1. Quy đổi đơn vị tính (Multi-UOM).
2. Tính giá xuất kho bình quân tức thời.
3. Sinh bút toán nhập kho (Nợ 1561 / Có 331).
4. Sinh bút toán xuất kho (Nợ 632 / Có 1561).
5. Bảng Nhập Xuất Tồn S11-DN (Bảo toàn số lượng Tồn cuối kỳ = Đầu kỳ + Nhập - Xuất).
