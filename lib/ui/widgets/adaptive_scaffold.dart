import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';

/// Adaptive Scaffold supporting both Desktop (PC Windows) and Mobile (Android)
class AdaptiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.body,
    required this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (isDesktop) {
      // Giao diện PC Desktop (.exe)
      return Scaffold(
        body: Row(
          children: [
            // Sidebar Navigation Menu (Phong cách MISA ERP)
            Container(
              width: 250,
              color: const Color(0xFF0F172A), // Dark Slate Sidebar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo & Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.account_balance, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BizOne ERP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Tài Chính Kế Toán (FAD)',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu Category Label
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'PHÂN HỆ KHO (INVENTORY)',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        _buildSidebarItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Tổng Quan (Dashboard)'),
                        _buildSidebarItem(1, Icons.inventory_2_outlined, Icons.inventory_2, 'Danh Mục VTHH'),
                        _buildSidebarItem(2, Icons.arrow_downward_rounded, Icons.arrow_downward_rounded, 'Phiếu Nhập Kho (NK)'),
                        _buildSidebarItem(3, Icons.arrow_upward_rounded, Icons.arrow_upward_rounded, 'Phiếu Xuất Kho (XK)'),
                        _buildSidebarItem(4, Icons.swap_horiz_rounded, Icons.swap_horiz_rounded, 'Điều Chuyển Kho'),
                        _buildSidebarItem(5, Icons.fact_check_outlined, Icons.fact_check, 'Kiểm Kê Kho'),
                        _buildSidebarItem(6, Icons.calculate_outlined, Icons.calculate, 'Tính Giá Xuất Kho'),
                        _buildSidebarItem(7, Icons.assessment_outlined, Icons.assessment, 'Báo Cáo Nhập-Xuất-Tồn'),
                      ],
                    ),
                  ),

                  // Bottom Company & System Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFF334155),
                          child: Icon(Icons.person, size: 16, color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kế toán trưởng',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text('Chi nhánh Hà Nội', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Desktop Top App Bar
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: AppTheme.border)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                        ),
                        const Spacer(),
                        if (actions != null) ...actions!,
                        const SizedBox(width: 8),
                        Chip(
                          avatar: const Icon(Icons.verified, size: 16, color: AppTheme.success),
                          label: const Text('TT 200 & TT 133', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: const Color(0xFFF0FDF4),
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    } else {
      // Giao diện Mobile Android (.apk)
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primary),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.account_balance, color: Colors.white, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'BizOne ERP - FAD',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Phân Hệ Quản Lý Kho Chuẩn MISA', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              _buildDrawerItem(0, Icons.dashboard, 'Tổng Quan (Dashboard)'),
              _buildDrawerItem(1, Icons.inventory_2, 'Danh Mục VTHH'),
              _buildDrawerItem(2, Icons.arrow_downward, 'Phiếu Nhập Kho (NK)'),
              _buildDrawerItem(3, Icons.arrow_upward, 'Phiếu Xuất Kho (XK)'),
              _buildDrawerItem(4, Icons.swap_horiz, 'Điều Chuyển Kho'),
              _buildDrawerItem(5, Icons.fact_check, 'Kiểm Kê Kho'),
              _buildDrawerItem(6, Icons.calculate, 'Tính Giá Xuất Kho'),
              _buildDrawerItem(7, Icons.assessment, 'Báo Cáo Nhập-Xuất-Tồn'),
            ],
          ),
        ),
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex > 4 ? 0 : currentIndex,
          onTap: onNavigationChanged,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'VTHH'),
            BottomNavigationBarItem(icon: Icon(Icons.arrow_downward), label: 'Nhập kho'),
            BottomNavigationBarItem(icon: Icon(Icons.arrow_upward), label: 'Xuất kho'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Báo cáo'),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }
  }

  Widget _buildSidebarItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => onNavigationChanged(index),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        onNavigationChanged(index);
      },
    );
  }
}
