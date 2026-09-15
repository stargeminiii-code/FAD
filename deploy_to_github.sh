#!/bin/bash
# Script tự động đẩy mã nguồn lên GitHub để kích hoạt Build .exe và .apk

echo "=========================================================="
echo "  BIZONE ERP - TỰ ĐỘNG XUẤT FILE .EXE VÀ .APK QUA GITHUB"
echo "=========================================================="

REPO_URL=$1

if [ -z "$REPO_URL" ]; then
  echo ""
  echo "Vui lòng nhập đường dẫn kho GitHub (Repository URL) của bạn:"
  read -p "URL: " REPO_URL
fi

if [ -z "$REPO_URL" ]; then
  echo "Lỗi: Bạn chưa nhập URL kho GitHub!"
  exit 1
fi

echo ""
echo ">>> Đang kết nối với GitHub: $REPO_URL ..."
git remote remove origin 2>/dev/null
git remote add origin "$REPO_URL"
git branch -M main

echo ">>> Đang đẩy mã nguồn lên GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
  echo ""
  echo "=========================================================="
  echo "  THÀNH CÔNG! HỆ THỐNG ĐÃ KÍCH HOẠT QUY TRÌNH BUILD TỰ ĐỘNG"
  echo "=========================================================="
  echo "Bây giờ bạn hãy làm theo các bước sau để tải file:"
  echo "1. Mở trình duyệt và truy cập vào repository của bạn:"
  echo "   $REPO_URL"
  echo "2. Bấm vào tab 'Actions' ở thanh menu trên cùng."
  echo "3. Bạn sẽ thấy quy trình 'Build BizOne ERP (Windows .exe & Android .apk)' đang chạy."
  echo "4. Chờ khoảng 3 - 5 phút khi có dấu tích xanh (✓), bấm vào tiến trình đó."
  echo "5. Kéo xuống mục 'Artifacts' ở cuối trang và tải về 2 file:"
  echo "   - BizOne_FAD_Windows_x64.zip (giải nén có file bizone_fad.exe)"
  echo "   - BizOne_FAD_Android_v1.0.apk"
  echo "=========================================================="
else
  echo ""
  echo "Lỗi khi đẩy mã nguồn lên GitHub. Vui lòng kiểm tra lại quyền truy cập hoặc tài khoản GitHub!"
fi
