import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'database/local_database.dart';
import 'services/inventory_service.dart';
import 'ui/screens/audit_voucher_screen.dart';
import 'ui/screens/cost_calculation_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/inventory_items_screen.dart';
import 'ui/screens/inventory_reports_screen.dart';
import 'ui/screens/inward_voucher_screen.dart';
import 'ui/screens/outward_voucher_screen.dart';
import 'ui/screens/transfer_voucher_screen.dart';
import 'ui/widgets/adaptive_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo cơ sở dữ liệu local & nạp dữ liệu mẫu MISA
  final localDb = LocalDatabase();
  localDb.initialize();

  runApp(const BizOneERPApp());
}

class BizOneERPApp extends StatelessWidget {
  const BizOneERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BizOne ERP - FAD (Phân Hệ Kho & Kế Toán Kho)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  final InventoryService _inventoryService = InventoryService();
  int _currentIndex = 0;

  final List<String> _screenTitles = [
    'Tổng Quan Phân Hệ Kho & Kế Toán (Dashboard)',
    'Danh Mục Vật Tư Hàng Hóa (DI_INVENTORY_ITEM)',
    'Phiếu Nhập Kho (IN_INWARD)',
    'Phiếu Xuất Kho (IN_OUTWARD)',
    'Điều Chuyển Kho (IN_TRANSFER)',
    'Kiểm Kê Kho (IN_AUDITWARD)',
    'Tính Giá Xuất Kho (IN_CALCULATE_PRICE)',
    'Bảng Tổng Hợp Nhập - Xuất - Tồn (Mẫu S11-DN)',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(
        inventoryService: _inventoryService,
        onNavigate: (idx) => setState(() => _currentIndex = idx),
      ),
      InventoryItemsScreen(inventoryService: _inventoryService),
      InwardVoucherScreen(inventoryService: _inventoryService),
      OutwardVoucherScreen(inventoryService: _inventoryService),
      TransferVoucherScreen(inventoryService: _inventoryService),
      AuditVoucherScreen(inventoryService: _inventoryService),
      CostCalculationScreen(inventoryService: _inventoryService),
      InventoryReportsScreen(inventoryService: _inventoryService),
    ];

    return AdaptiveScaffold(
      currentIndex: _currentIndex,
      onNavigationChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      title: _screenTitles[_currentIndex],
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
    );
  }
}
