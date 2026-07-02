import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../analytics/presentation/analytics_screen.dart';
import '../../auth/providers/app_auth_provider.dart';
import '../../inventory/presentation/inventory_screen.dart';
import '../../pos/presentation/pos_screen.dart';
import '../../products/presentation/products_screen.dart';
import '../../sales/presentation/sales_history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await context.read<AppAuthProvider>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market POS'),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            tooltip: 'خروج',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppAuthProvider>().loadCurrentUser(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user?.name ?? 'Loading user...'),
                subtitle: Text(user == null ? '...' : 'Role: ${user.role}'),
              ),
            ),
            const SizedBox(height: 16),
            _DashboardGrid(
              isAdmin: user?.isAdmin ?? true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  final bool isAdmin;

  const _DashboardGrid({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final items = <_DashboardItem>[
      _DashboardItem(
        title: 'الكاشير POS',
        icon: Icons.point_of_sale,
        screen: const PosScreen(),
      ),
      _DashboardItem(
        title: 'المبيعات',
        icon: Icons.receipt_long,
        screen: const SalesHistoryScreen(),
      ),
      if (isAdmin)
        _DashboardItem(
          title: 'المنتجات',
          icon: Icons.inventory_2,
          screen: const ProductsScreen(),
        ),
      if (isAdmin)
        _DashboardItem(
          title: 'المخزون',
          icon: Icons.warning_amber,
          screen: const InventoryScreen(),
        ),
      if (isAdmin)
        _DashboardItem(
          title: 'التحليلات',
          icon: Icons.analytics,
          screen: const AnalyticsScreen(),
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => item.screen),
          ),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 48),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Widget screen;

  const _DashboardItem({
    required this.title,
    required this.icon,
    required this.screen,
  });
}
